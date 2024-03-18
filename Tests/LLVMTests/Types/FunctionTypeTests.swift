import SwiftyLLVM
import XCTest

final class FunctionTypeTests: XCTestCase {

  func testDefaultReturnType() {
    Context.withNew { (llvm) in
      XCTAssert(FunctionType(from: [], in: &llvm).returnType == VoidType(in: &llvm))
    }
  }

  func testReturnType() {
    Context.withNew { (llvm) in
      let t = IntegerType(64, in: &llvm)
      XCTAssert(FunctionType(from: [], to: t, in: &llvm).returnType == t)
    }
  }

  func testParameters() {
    Context.withNew { (llvm) in
      let t = IntegerType(64, in: &llvm)
      let u = IntegerType(32, in: &llvm)

      let f0 = FunctionType(from: [], in: &llvm)
      XCTAssertEqual(f0.parameters.count, 0)

      let f1 = FunctionType(from: [t], in: &llvm)
      XCTAssertEqual(f1.parameters.count, 1)
      XCTAssert(f1.parameters[0] == t)

      let f2 = FunctionType(from: [t, u], in: &llvm)
      XCTAssertEqual(f2.parameters.count, 2)
      XCTAssert(f2.parameters[0] == t)
      XCTAssert(f2.parameters[1] == u)
    }
  }

  func testConversion() {
    Context.withNew { (llvm) in
      let t: IRType = FunctionType(from: [], in: &llvm)
      XCTAssertNotNil(FunctionType(t))
      let u: IRType = IntegerType(64, in: &llvm)
      XCTAssertNil(FunctionType(u))
    }
  }

  func testEquality() {
    Context.withNew { (llvm) in
      let t = IntegerType(64, in: &llvm)
      let u = IntegerType(32, in: &llvm)

      let f0 = FunctionType(from: [t, u], in: &llvm)
      let f1 = FunctionType(from: [t, u], in: &llvm)
      XCTAssertEqual(f0, f1)

      let f2 = FunctionType(from: [u, t], in: &llvm)
      XCTAssertNotEqual(f0, f2)
    }
  }

}
