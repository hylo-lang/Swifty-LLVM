internal import llvmc
import Foundation

/// An LLVM type reference.
public struct TypeRef: Hashable {

  /// The underlying LLVM value.
  let raw: llvmc.LLVMTypeRef

  /// An instance whose underlying value is `raw`.
  init(_ raw: llvmc.LLVMTypeRef) { self.raw = raw }

}

/// An LLVM value reference.
public struct ValueRef: Hashable {

  /// The underlying LLVM value; not exposed to avoid rexporting llvmc
  let raw: llvmc.LLVMValueRef

  /// An instance whose underlying value is `raw`.
  init(_ raw: llvmc.LLVMValueRef) { self.raw = raw }

}

/// An LLVM basic block reference.
public struct BasicBlockRef: Hashable {

  /// The underlying LLVM value; not exposed to avoid rexporting llvmc
  let raw: llvmc.LLVMBasicBlockRef

  /// An instance whose underlying value is `raw`.
  init(_ raw: llvmc.LLVMBasicBlockRef) { self.raw = raw }

}

/// An LLVM module reference.
public struct ModuleRef: Hashable {

  /// The underlying LLVM value; not exposed to avoid rexporting llvmc
  let raw: llvmc.LLVMModuleRef

  /// An instance whose underlying value is `raw`.
  init(_ raw: llvmc.LLVMModuleRef) { self.raw = raw }

}

/// An LLVM attribute reference.
public struct AttributeRef: Hashable {

  /// The underlying LLVM value; not exposed to avoid rexporting llvmc
  let raw: llvmc.LLVMAttributeRef

  /// An instance whose underlying value is `raw`.
  init(_ raw: llvmc.LLVMAttributeRef) { self.raw = raw }

}
