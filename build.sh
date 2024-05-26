#!/bin/env bash

set -e

if ! test -d haiku;then
	git clone --depth=1 --filter=blob:none --sparse https://github.com/haiku/haiku.git
fi

cd haiku

git sparse-checkout set --cone \
	docs/user \
	headers/os \
	headers/posix \
	headers/private \
	src/kits/game

rm -rf generated

mkdir -v generated

cd docs/user

sed -i Doxyfile \
	-e 's,DISABLE_INDEX          = NO,DISABLE_INDEX          = YES,' \
	-e 's,SEARCHENGINE           = YES,SEARCHENGINE           = NO,' \
	-e 's,HIDE_UNDOC_MEMBERS     = YES,HIDE_UNDOC_MEMBERS     = NO,' \
	-e 's,HIDE_UNDOC_CLASSES     = YES,HIDE_UNDOC_CLASSES     = NO,' \
	-e 's,ENABLED_SECTIONS       =,ENABLED_SECTIONS       = INTERNAL,'

doxygen

cd ../../..

rm -rf org.haiku.HaikuBook.docset

echo
echo "Creating docset..."

doxygen2docset --doxygen haiku/generated/doxygen/html --docset .

echo
echo "Copying docset metadata..."

cp -afv meta.json icon*.png org.haiku.HaikuBook.docset

## Modify sqlite index with namespace/class prefix for methods
echo
echo "Rewriting docset index..."

DB_PATH=org.haiku.HaikuBook.docset/Contents/Resources/docSet.dsidx
## Database columns in each line: id|name|type|path

echo "BEGIN TRANSACTION;" > modifyindex.sql

## Miscellaneous sorting and cleanup
echo "UPDATE searchIndex SET type = 'Category' WHERE type = 'Data' and path like 'group\_%.html#' ESCAPE '\';" >> modifyindex.sql
echo "UPDATE searchIndex SET type = 'Guide' WHERE type = 'Data' AND name like '%\_intro' ESCAPE '\';" >> modifyindex.sql

IFS='|'
classRegex="class(\w+)\.html"

## prefix methods and templates with class and namespace
while read -r -a line; do
	## extract fully qualified class name from html file
	if [[ "${line[3]}" =~ $classRegex ]];then
		## also substitute _1_1 in namespaces
		echo "UPDATE searchIndex SET name='${BASH_REMATCH[1]//_1/:}::${line[1]}' WHERE id=${line[0]};" >> modifyindex.sql
	fi
done <<< $(sqlite3 $DB_PATH "SELECT * FROM searchIndex WHERE type='Method' OR type = 'Type' AND path like 'class%'")

## prefix namespaced classes
while read -r -a line; do
	## extract fully qualified class name from html file
	if [[ "${line[3]}" =~ $classRegex ]];then
		## also substitute _1_1 in namespaces
		echo "UPDATE searchIndex SET name='${BASH_REMATCH[1]//_1/:}' WHERE id=${line[0]};" >> modifyindex.sql
	fi
done <<< $(sqlite3 $DB_PATH "SELECT * FROM searchIndex WHERE type = 'Class' AND path like 'class%\_1\_1%' ESCAPE '\';")

echo "COMMIT;" >> modifyindex.sql

sqlite3 $DB_PATH < modifyindex.sql

rm -f modifyindex.sql
