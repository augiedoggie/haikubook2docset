#!/bin/env bash

if ! test -d haiku;then
	git clone --depth=1 --filter=blob:none --sparse https://github.com/haiku/haiku.git
fi

cd haiku

git sparse-checkout set docs/user headers --cone

rm -rf generated

mkdir -pv generated

cd docs/user

sed -i Doxyfile \
	-e 's,DISABLE_INDEX          = NO,DISABLE_INDEX          = YES,' \
	-e 's,SEARCHENGINE           = YES,SEARCHENGINE           = NO,' \
	-e 's,HIDE_UNDOC_MEMBERS     = YES,HIDE_UNDOC_MEMBERS     = NO,' \
	-e 's,HIDE_UNDOC_CLASSES     = YES,HIDE_UNDOC_CLASSES     = NO,' \
	-e 's,ENABLED_SECTIONS       =,ENABLED_SECTIONS       = INTERNAL,'

doxygen

cd ../../..

doxygen2docset --doxygen haiku/generated/doxygen/html --docset .

cp -afv meta.json icon*.png org.haiku.HaikuBook.docset

## Modify sqlite index with namespace/class prefix for methods

echo
echo "Rewriting docset index. On Linux this only takes a minute"
echo "When running this script on Haiku it may take several minutes..."

DB_PATH=org.haiku.HaikuBook.docset/Contents/Resources/docSet.dsidx

echo "BEGIN TRANSACTION;" > modifyindex.sql

IFS='|'
while read -r -a line; do
	name="${line[1]}"
	class=$(echo "${line[3]}" | sed -E -e 's,class(\w+)\.html.+,\1,' -e 's,_1,:,g')
	echo "UPDATE searchIndex SET name='${class}::${name}' WHERE id=${line[0]};" >> modifyindex.sql
done <<< $(sqlite3 $DB_PATH "SELECT * FROM searchIndex WHERE Type='Method'")

echo "COMMIT;" >> modifyindex.sql

sqlite3 $DB_PATH < modifyindex.sql

rm -f modifyindex.sql
