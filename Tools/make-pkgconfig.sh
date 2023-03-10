#!/usr/bin/env bash

version=$(llvm-config --version)
filename=/usr/local/lib/pkgconfig/llvm.pc

mkdir -p `dirname $filename`
touch $filename

echo Name: LLVM > $filename
echo Description: Low-level Virtual Machine compiler framework >> $filename
echo Version: $(echo ${version} | sed 's/\([0-9.]\+\).*/\1/') >> $filename
echo URL: http://www.llvm.org/ >> $filename
echo Libs: -L$(llvm-config --libdir --system-libs --libs core analysis) >> $filename
echo Cflags: -I$(llvm-config --includedir) >> $filename
