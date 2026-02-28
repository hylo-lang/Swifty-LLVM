// Minimal reproducer for variadic pack function signature

public protocol IRType {
  associatedtype Identity
}

public struct LLVMIdentity<T> {
  public var erased: Int = 0
  public init(_ value: Int = 0) { self.erased = value }
}

public struct FunctionType {
  public struct Identity {}
  public static func create(from: [Any], to: Any, in m: inout Module) -> Identity {
    return Identity()
  }
}

public struct Module {
  // Replicate the variadic-pack function signature from the project
  public mutating func functionType<each T: IRType, R: IRType>(
    from parameters: (repeat LLVMIdentity<(each T)>), to returnType: R.Identity
  ) -> FunctionType.Identity {
    var erased = [Any]()
    // Map variadic tuple to array
    for p in repeat each parameters {
      erased.append(p.erased)
    }

    return FunctionType.create(from: erased, to: returnType, in: &self)
  }
}

// Provide concrete types and a call site so the compiler instantiates the generic
struct MyType: IRType { typealias Identity = Int }
struct RetType: IRType { typealias Identity = Int }

@main
struct Runner {
  static func main() {
    var m = Module()
    // Call with a two-element pack
    _ = m.functionType(from: (LLVMIdentity<MyType>(1), LLVMIdentity<MyType>(2)), to: 0)
    print("done")
  }
}
