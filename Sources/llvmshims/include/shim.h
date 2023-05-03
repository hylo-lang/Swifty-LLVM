#ifndef SWIFTYLLVM_LLVMSHIMS_H
#define SWIFTYLLVM_LLVMSHIMS_H

#include "llvm-c/Transforms/PassBuilder.h"
#include "llvm-c/ExternC.h"

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

void SwiftyLLVMRunDefaultModulePasses(
  LLVMModuleRef self,
  LLVMTargetMachineRef t,
  SwiftyLLVMPassOptimizationLevel optimization);

LLVM_C_EXTERN_C_END

#endif
