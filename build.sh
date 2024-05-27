#!/bin/env bash

set -e

if ! test -d haiku;then
	git clone --depth=1 --filter=blob:none --sparse https://github.com/haiku/haiku.git
fi

(cd haiku && git sparse-checkout set --cone \
	docs/user \
	headers/os \
	headers/posix \
	headers/private \
	src/kits/game)

rm -rf haiku/generated

mkdir haiku/generated

sed -i haiku/docs/user/Doxyfile \
	-e 's,DISABLE_INDEX          = NO,DISABLE_INDEX          = YES,' \
	-e 's,SEARCHENGINE           = YES,SEARCHENGINE           = NO,' \
	-e 's,HIDE_UNDOC_MEMBERS     = YES,HIDE_UNDOC_MEMBERS     = NO,' \
	-e 's,HIDE_UNDOC_CLASSES     = YES,HIDE_UNDOC_CLASSES     = NO,' \
	-e 's,ENABLED_SECTIONS       =,ENABLED_SECTIONS       = INTERNAL,'

echo
echo "Running doxygen..."

(cd haiku/docs/user && doxygen) > doxygen.log 2>&1

echo
echo "Running doxygen2docset..."

rm -rf org.haiku.HaikuBook.docset
doxygen2docset --doxygen haiku/generated/doxygen/html --docset . > d2d.log

echo
echo "Copying docset metadata..."

cp -af meta.json icon*.png org.haiku.HaikuBook.docset

DB_PATH=org.haiku.HaikuBook.docset/Contents/Resources/docSet.dsidx
## Database columns in each line: id|name|type|path

echo
echo "Applying manual docset index changes..."

sqlite3 $DB_PATH < static.sql

echo
echo "Applying automated docset index changes..."

echo "BEGIN TRANSACTION;" > modifyindex.sql

## regexes to extract fully qualifiied name
## will also need pattern substitution to replace '_1' with ':', like ${BASH_REMATCH[1]//_1/:}
## and convert double underscore to single, like ${foo//__/_}
classRegex="class(\w+)\.html"
structRegex="struct(\w+)\.html"
namespaceRegex="namespace(\w+).html"

IFS='|'

## prefix methods, variables, and templates with class or struct and namespace
while read -r -a line; do
	if [[ "${line[3]}" =~ $namespaceRegex || "${line[3]}" =~ $classRegex || "${line[3]}" =~ $structRegex ]];then
		newName="${BASH_REMATCH[1]//_1/:}"
		echo "UPDATE searchIndex SET name = '${newName//__/_}::${line[1]}' WHERE id = ${line[0]};" >> modifyindex.sql
	fi
done <<< $(sqlite3 $DB_PATH "SELECT * FROM searchIndex WHERE \
	(type = 'Method' OR type = 'Type' OR type = 'Variable' OR type = 'Function') \
	AND (path like 'namespace%' OR path like 'class%' OR path like 'struct%');")

## prefix namespaced classes and namespaces
while read -r -a line; do
	if [[ "${line[3]}" =~ $classRegex || "${line[3]}" =~ $namespaceRegex ]];then
		newName="${BASH_REMATCH[1]//_1/:}"
		echo "UPDATE searchIndex SET name = '${newName//__/_}' WHERE id = ${line[0]};" >> modifyindex.sql
	fi
done <<< $(sqlite3 $DB_PATH "SELECT * FROM searchIndex WHERE \
	(type = 'Class' AND path like 'class%\_1\_1%' ESCAPE '\') \
	OR type = 'Namespace';")

## prefix 'Class' structs and reset type to 'Struct'
while read -r -a line; do
	if [[ "${line[3]}" =~ $structRegex ]];then
		newName="${BASH_REMATCH[1]//_1/:}"
		echo "UPDATE searchIndex SET type = 'Struct', name = '${newName//__/_}' WHERE id = ${line[0]};" >> modifyindex.sql
	fi
done <<< $(sqlite3 $DB_PATH "SELECT * FROM searchIndex WHERE type = 'Class' AND path like 'struct%';")

## prefix namespaced enums and reset type if needed
while read -r -a line; do
	if [[ "${line[3]}" =~ $namespaceRegex || "${line[3]}" =~ $classRegex ]];then
		newName="${BASH_REMATCH[1]//_1/:}"
		echo "UPDATE searchIndex SET type = 'Enum', name = '${newName//__/_}::${line[1]}' WHERE id = ${line[0]};" >> modifyindex.sql
	fi
done <<< $(sqlite3 $DB_PATH "SELECT * FROM searchIndex WHERE \
	(type = 'Data' OR type = 'Enum') \
	AND (path like 'namespace%' OR path like 'class%');")

echo "COMMIT;" >> modifyindex.sql

sqlite3 $DB_PATH < modifyindex.sql

rm -f modifyindex.sql doxygen.log d2d.log
