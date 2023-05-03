#include "llvm-c/Core.h"
#include "llvm/IR/Instructions.h"

extern "C" {

  void LLVMSetAllocaAlignment(LLVMValueRef a) {
    // llvm::unwrap<llvm::AllocaInst>(a)->setAlignment();
  }

}
