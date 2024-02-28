#!/usr/bin/env bash
set -e
set -o pipefail
set -x
# Work around https://github.com/hylo-lang/llvm-build/issues/8
zstd_dash_L="$(pkg-config --libs-only-L libzstd)"
export DYLD_LIBRARY_PATH="${zstd_dash_L#-L}:$DYLD_LIBRARY_PATH"

version=$(llvm-config --version)
filename=$1

mkdir -p `dirname $filename`
touch $filename

# REVISIT(nickpdemarco):
# Why does macos need the standard library explicitly linked, while linux does not?
# This does not feel like the correct place for this logic.
machine="$(uname -s)"
case "${machine}" in
  Darwin*)  libs="-lc++";;
  *)        libs=""
esac

echo Name: LLVM > $filename
echo Description: Low-level Virtual Machine compiler framework >> $filename
echo Version: $(echo ${version} | sed 's/\([0-9.]\+\).*/\1/') >> $filename
echo URL: http://www.llvm.org/ >> $filename
echo Libs: -L$(llvm-config --libdir) ${zstd_dash_L} ${libs} $(llvm-config --system-libs --libs analysis bitwriter core native passes target) >> $filename
echo Cflags: -I$(llvm-config --includedir) >> $filename

echo "$filename written:"
cat $filename
