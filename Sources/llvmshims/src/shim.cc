#include "llvm-c/Transforms/PassBuilder.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/StandardInstrumentations.h"
#include "llvm/Support/CBindingWrapping.h"

using namespace llvm;

extern "C" {

  void SwiftyLLVMRunDefaultModulePasses(LLVMModuleRef m, unsigned int opt) {
    // Create the analysis managers.
    LoopAnalysisManager lam;
    FunctionAnalysisManager fam;
    CGSCCAnalysisManager cgam;
    ModuleAnalysisManager mam;

    // Create the new pass manager builder.
    // Take a look at the PassBuilder constructor parameters for more
    // customization, e.g. specifying a TargetMachine or various debugging
    // options.
    PassBuilder p;

    // Register all the basic analyses with the managers.
    p.registerModuleAnalyses(mam);
    p.registerCGSCCAnalyses(cgam);
    p.registerFunctionAnalyses(fam);
    p.registerLoopAnalyses(lam);
    p.crossRegisterProxies(lam, fam, cgam, mam);

    // Create the pass manager.
    OptimizationLevel o;
    switch (opt) {
    case 0:
      o = OptimizationLevel::O0;
    case 1:
      o = OptimizationLevel::O1;
    case 2:
      o = OptimizationLevel::O2;
    case 3:
      o = OptimizationLevel::O3;
    }
    ModulePassManager mpm = p.buildPerModuleDefaultPipeline(o);

    // Optimize the IR!
    Module *mod = unwrap(m);
    mpm.run(*mod, mam);
  }

}
