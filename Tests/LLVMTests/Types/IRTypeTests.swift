import SwiftyLLVM
import XCTest

final class IRTypeTests: XCTestCase {

  func testIsSized() {
    Context.withNew { (llvm) in
      XCTAssert(IntegerType(64, in: &llvm).isSized)
      XCTAssertFalse(FunctionType(from: [], in: &llvm).isSized)
    }
  }

  func testEqualty() {
    Context.withNew { (llvm) in
      let t = IntegerType(64, in: &llvm)
      let u = IntegerType(32, in: &llvm)

      XCTAssert(t == (t as IRType))
      XCTAssert((t as IRType) == t)
      XCTAssert((t as IRType) == (t as IRType))

      XCTAssert(t != (u as IRType))
      XCTAssert((t as IRType) != u)
      XCTAssert((t as IRType) != (u as IRType))
    }
  }

  func testStringConvertible() {
    Context.withNew { (llvm) in
      let t = IntegerType(64, in: &llvm)
      XCTAssertEqual("\(t)", "\(t)", "Unstable string representation!")
    }
  }

}
