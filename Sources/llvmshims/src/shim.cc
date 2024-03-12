#ifdef _MSC_VER
#pragma warning(push)
#pragma warning(disable: 4624 4244)
#endif

#include "llvm-c/TargetMachine.h"
#include "llvm-c/Transforms/PassBuilder.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/StandardInstrumentations.h"
#include "shim.h"
#ifdef _MSC_VER
#pragma warning(pop)
#endif

// Used to create a fatal error in this file. Must follow all other #includes
#undef NDEBUG
#include <cassert>
// Used to create a fatal error in this file. Must follow all other #includes

using namespace llvm;

template<typename T, typename U>
T* unsafe_as(U* s) {
  return static_cast<T*>(static_cast<void*>(s));
}

llvm::OptimizationLevel as_llvm(SwiftyLLVMPassOptimizationLevel x) {
  switch (x) {
  case SwiftyLLVMPassOptimizationLevelO0:
    return llvm::OptimizationLevel::O0;
  case SwiftyLLVMPassOptimizationLevelO1:
    return llvm::OptimizationLevel::O1;
  case SwiftyLLVMPassOptimizationLevelO2:
    return llvm::OptimizationLevel::O2;
  case SwiftyLLVMPassOptimizationLevelO3:
    return llvm::OptimizationLevel::O3;
  case SwiftyLLVMPassOptimizationLevelOs:
    return llvm::OptimizationLevel::Os;
  case SwiftyLLVMPassOptimizationLevelOz:
    return llvm::OptimizationLevel::Oz;
  default:
    assert(!"fatal error: unhandled optimization level");
    return llvm::OptimizationLevel::O0;
  }
}

extern "C" {

  void SwiftyLLVMRunDefaultModulePasses(
    LLVMModuleRef self,
    LLVMTargetMachineRef t,
    SwiftyLLVMPassOptimizationLevel optimization
  ) {
    // Create the analysis managers.
    LoopAnalysisManager lam;
    FunctionAnalysisManager fam;
    CGSCCAnalysisManager cgam;
    ModuleAnalysisManager mam;

    // Create a new pass manager builder.
    PassBuilder p(unsafe_as<llvm::TargetMachine>(t));

    // Register all the basic analyses with the managers.
    p.registerModuleAnalyses(mam);
    p.registerCGSCCAnalyses(cgam);
    p.registerFunctionAnalyses(fam);
    p.registerLoopAnalyses(lam);
    p.crossRegisterProxies(lam, fam, cgam, mam);

    ModulePassManager mpm;
    if (optimization == SwiftyLLVMPassOptimizationLevelO0) {
      mpm = p.buildO0DefaultPipeline(OptimizationLevel::O0);
    } else {
      mpm = p.buildPerModuleDefaultPipeline(as_llvm(optimization));
    }

    // Run the passes.
    mpm.run(*unwrap(self), mam);
  }

}
