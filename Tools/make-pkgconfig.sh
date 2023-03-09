#!/usr/bin/env bash

# filename=/usr/local/lib/pkgconfig/llvm.pc
filename=koala.pc
llvmconfig=$(which llvm-config)

echo $llvmconfig
version=$(/home/runner/work/Swifty-LLVM/Swifty-LLVM/llvm/bin/llvm-config --version)
machine="$(uname -s)"
case "${machine}" in
    Linux*)   libs="-L/usr/lib -lc++";;
    Darwin*)  libs="-lc++";;
    *)        libs=""
esac

echo Name: LLVM > $filename
echo Description: Low-level Virtual Machine compiler framework >> $filename
echo Version: $(echo ${version} | sed 's/\([0-9.]\+\).*/\1/') >> $filename
echo URL: http://www.llvm.org/ >> $filename
echo Libs: ${libs} -L$(${llvmconfig} --libdir --system-libs --libs core analysis) >> $filename
echo Cflags: -I$(${llvmconfig} --includedir) >> $filename
