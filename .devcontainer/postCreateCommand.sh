#!/usr/bin/env bash
set -e
set -o pipefail

echo "Hylo LLVM build type: $HYLO_LLVM_BUILD_TYPE"
echo

ln -s /opt/llvm-*-$(uname -m)-*-Debug /opt/llvm-Debug
ln -s /opt/llvm-*-$(uname -m)-*-MinSizeRel /opt/llvm-MinSizeRel

export PATH="/opt/llvm-$HYLO_LLVM_BUILD_TYPE/bin:$PATH"
./Tools/make-pkgconfig.sh /usr/local/lib/pkgconfig/llvm.pc
