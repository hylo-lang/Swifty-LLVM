#!/usr/bin/env bash
set -e
set -o pipefail

echo "Hylo LLVM build type: $HYLO_LLVM_BUILD_TYPE"
echo

export PATH="/opt/llvm-$HYLO_LLVM_BUILD_TYPE/bin:$PATH"
./Tools/make-pkgconfig.sh /usr/local/lib/pkgconfig/llvm.pc > /dev/null
