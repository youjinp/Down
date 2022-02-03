#!/bin/bash

# variables
MD4C_TEMP=md4c-temp
MD4C=Sources/libmd4c

BUILD_TEMP=md4c-build

# clone
rm -rf $MD4C_TEMP
git clone -b $MD4C_VERSION --depth 1 https://github.com/mity/md4c.git $MD4C_TEMP

# copy
mkdir -p $MD4C
cp -R $MD4C_TEMP/ $MD4C/

# cmake
rm -rf $BUILD_TEMP
mkdir -p $BUILD_TEMP
pushd $BUILD_TEMP
cmake ../$MD4C_TEMP
popd

# Delete any files that aren't source files
find $MD4C -not -name '*.c' -type f -not -name '*.h' -type f -delete

# Delete any test files
rm -rf $MD4C/md2html
rm -rf $MD4C/test

# Delete any empty folders
find $MD4C -type d -empty -delete

# clean
rm -rf $MD4C_TEMP
rm -rf $BUILD_TEMP