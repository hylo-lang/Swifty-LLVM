#ifdef _MSC_VER
#pragma warning(push)
#pragma warning(disable : 4624 4244)

#endif

// Used to create a fatal error in this file. Must preceed all other #includes

#ifdef NDEBUG
#define SWIFTY_LLVM_NDEBUG_BACKUP
#undef NDEBUG
#endif
#include <cassert> // Must be the first include, otherwise it may get included transitively.
// Restore NDEBUG if it was defined before this file.
#ifdef SWIFTY_LLVM_NDEBUG_BACKUP
#define NDEBUG
#undef SWIFTY_LLVM_NDEBUG_BACKUP
#endif

// Used to create a fatal error in this file. Must preceed all other #includes

#include "shim.h"
#include "llvm-c/Core.h"
#include "llvm-c/TargetMachine.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/TargetParser/SubtargetFeature.h"

#ifdef _MSC_VER
#pragma warning(pop)
#endif

using namespace llvm;

template <typename T, typename U> T *unsafe_as(U *s) {
  return static_cast<T *>(static_cast<void *>(s));
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
    LLVMModuleRef self, LLVMTargetMachineRef t,
    SwiftyLLVMPassOptimizationLevel optimization) {
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

long SwiftyLLVMGetArgumentIndex(LLVMValueRef argument) {
  llvm::Value *v = llvm::unwrap(argument);

  if (llvm::Argument *Arg = llvm::dyn_cast<llvm::Argument>(v)) {
    return Arg->getArgNo();
  }

  return -1;
}

unsigned int SwiftyLLVMGetProgramAddressSpace(LLVMTargetDataRef dataLayout) {
  llvm::DataLayout *td = llvm::unwrap(dataLayout);
  return td->getProgramAddressSpace();
}

bool SwiftyLLVMIsCPUValid(LLVMTargetRef target, const char *triple,
                          const char *cpu) {
  assert(target && "target must not be null");
  assert(triple && "triple must not be null");
  assert(cpu && "cpu must not be null");

  if (cpu[0] == '\0')
    return 1;

  auto *llvmTarget = reinterpret_cast<const llvm::Target *>(target);
  std::unique_ptr<llvm::MCSubtargetInfo> i(
      llvmTarget->createMCSubtargetInfo(triple, "", ""));
  assert(
      i &&
      "invalid triple: failed to create MCSubtargetInfo for validated triple");

  return i->isCPUStringValid(cpu) ? 1 : 0;
}

char *SwiftyLLVMGetFirstInvalidFeature(LLVMTargetRef target, const char *triple,
                                       const char *features) {
  assert(target && "target must not be null");
  assert(triple && "triple must not be null");
  assert(features && "features must not be null");

  if (features[0] == '\0')
    return nullptr;

  const auto *llvmTarget = reinterpret_cast<const llvm::Target *>(target);
  const auto subtarget = std::unique_ptr<llvm::MCSubtargetInfo>(
      llvmTarget->createMCSubtargetInfo(triple, "", ""));
  assert(subtarget && "failed to create MCSubtargetInfo for validated triple");

  auto knownFeatures = subtarget->getAllProcessorFeatures();

  std::vector<std::string> parts;
  llvm::SubtargetFeatures::Split(parts, features);

  auto it = llvm::find_if_not(parts, [&](const std::string &entry) {
    const auto name = llvm::SubtargetFeatures::StripFlag(entry);
    return llvm::any_of(knownFeatures, [&](const llvm::SubtargetFeatureKV &kv) {
      return llvm::StringRef(kv.Key) == name;
    });
  });

  if (it == parts.end())
    return nullptr;

  return LLVMCreateMessage(llvm::SubtargetFeatures::StripFlag(*it).str().c_str());
}
}
