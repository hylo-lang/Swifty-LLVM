#ifndef SWIFTYLLVM_LLVMSHIMS_H
#define SWIFTYLLVM_LLVMSHIMS_H

#include "llvm-c/Transforms/PassBuilder.h"

void SwiftyLLVMRunDefaultModulePasses(LLVMModuleRef m);

#endif
