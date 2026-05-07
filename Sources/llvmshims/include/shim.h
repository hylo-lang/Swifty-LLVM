#ifndef SWIFTYLLVM_LLVMSHIMS_H
#define SWIFTYLLVM_LLVMSHIMS_H

#include "llvm-c/ExternC.h"
#include "llvm-c/Target.h"
#include "llvm-c/TargetMachine.h"
#include <stdbool.h>

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

/// Runs the default module passes on the given module, using the given target
/// machine and optimization level.
void SwiftyLLVMRunDefaultModulePasses(
    LLVMModuleRef self, LLVMTargetMachineRef t,
    SwiftyLLVMPassOptimizationLevel optimization);

/// Returns the index of the given argument, or -1 if the value is not an
/// argument.
long SwiftyLLVMGetArgumentIndex(LLVMValueRef argument);

/// Returns the address space of function pointers in the given data layout.
unsigned int SwiftyLLVMGetProgramAddressSpace(LLVMTargetDataRef dataLayout);

/// Returns true iff `cpu` is a recognised CPU name for the given target and
/// triple, or `cpu` is empty (meaning generic).
///
/// Preconditions:
///  - `target` must be non-null.
///  - `triple` must be non-null and form a valid triple corresponding to
///    `target`.
///  - `cpu` must be non-null.
bool SwiftyLLVMIsCPUValid(LLVMTargetRef target, const char *triple,
                          const char *cpu);

/// Returns the first unrecognised feature name (without the +/- prefix) in `features` for the given
/// target and triple, or NULL if all features are valid.
///
/// `features` is a comma-separated list of "+feature" or "-feature" entries.
/// The returned string must be freed with `LLVMDisposeMessage`.
///
/// Preconditions:
///  - `target` must be non-null.
///  - `triple` must be non-null and form a valid triple corresponding to `target`.
///  - `features` must be non-null.
char *SwiftyLLVMGetFirstInvalidFeature(LLVMTargetRef target, const char *triple,
                                       const char *features);

LLVM_C_EXTERN_C_END

#endif
