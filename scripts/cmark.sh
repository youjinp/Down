#!/bin/bash

# variables
CMARK_TEMP=cmark-temp
CMARK=Sources/libcmark 

# clone
rm -rf $CMARK_TEMP
git clone -b $VERSION --depth 1 https://github.com/commonmark/cmark.git $CMARK_TEMP

# copy
mkdir -p $CMARK
cp -R $CMARK_TEMP/ $CMARK/

# make
pushd $CMARK_TEMP
make all
popd

# copy cmark_export.h, cmark_version.h and config.h
cp $CMARK_TEMP/build/src/cmark_export.h $CMARK/src/cmark_export.h
cp $CMARK_TEMP/build/src/cmark_version.h $CMARK/src/cmark_version.h
cp $CMARK_TEMP/build/src/config.h $CMARK/src/config.h

# Delete any files that aren't source files
find $CMARK -not -name '*.c' -type f -not -name '*.h' -type f -not -name 'entities.inc' -type f -not -name 'case_fold_switch.inc' -type f -delete

# Delete any test files
rm -rf $CMARK/api_test
rm -rf $CMARK/test

# Delete any empty folders
find $CMARK -type d -empty -delete

# delete main
rm -rf $CMARK/src/main.c

# update cmark.h to use quoted includes
# - https://github.com/apple/swift-cmark/commit/cb76c8ba66b4de453df1168d9cd93e8ace719b1c
# https://stackoverflow.com/questions/21242932/sed-i-may-not-be-used-with-stdin-on-mac-os-x/21243084
sed -i '' 's/<\(cmark[ -~]*\)>/"\1"/g' $CMARK/src/cmark.h

# clean
rm -rf $CMARK_TEMP