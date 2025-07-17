#!/usr/bin/env bash
set -e
set -o pipefail

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

libs=()
for x in -L$(llvm-config --libdir) $(llvm-config --system-libs --libs analysis bitwriter core native passes target); do
    libs+=($(printf '%q' "$x"))
done
cflags=()
for x in $(llvm-config --cxxflags); do
    cflags+=($(printf '%q' "$x"))
done

echo Name: LLVM > $filename
echo Description: Low-level Virtual Machine compiler framework >> $filename
echo Version: $(echo ${version} | sed 's/\([0-9.]\+\).*/\1/') >> $filename
echo URL: http://www.llvm.org/ >> $filename
echo Libs: ${libs[@]} >> $filename
echo Cflags: ${cflags[@]} >> $filename

echo "$filename written:"
cat $filename
