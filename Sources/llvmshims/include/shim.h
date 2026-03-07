#ifndef SWIFTYLLVM_LLVMSHIMS_H
#define SWIFTYLLVM_LLVMSHIMS_H

#include "llvm-c/ExternC.h"
#include "llvm-c/TargetMachine.h"

LLVM_C_EXTERN_C_BEGIN

/// Optimization level of a pass.
///
/// - See: llvm::OptimizationLevel
typedef enum {
  SwiftyLLVMPassOptimizationLevelO0,
  SwiftyLLVMPassOptimizationLevelO1,
  SwiftyLLVMPassOptimizationLevelO2,
  SwiftyLLVMPassOptimizationLevelO3,
  SwiftyLLVMPassOptimizationLevelOs,
  SwiftyLLVMPassOptimizationLevelOz,
} SwiftyLLVMPassOptimizationLevel;

/// Runs the default module passes on the given module, using the given target machine and optimization level.
void SwiftyLLVMRunDefaultModulePasses(
    LLVMModuleRef self, LLVMTargetMachineRef t,
    SwiftyLLVMPassOptimizationLevel optimization);

/// Returns the index of the given argument, or -1 if the value is not an argument.
long  SwiftyLLVMGetArgumentIndex(LLVMValueRef argument);

LLVM_C_EXTERN_C_END

#endif
