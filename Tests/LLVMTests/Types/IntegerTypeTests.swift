import SwiftyLLVM
import XCTest

final class IntegerTypeTests: XCTestCase {

  func testBitWidth() {
    Context.withNew { (llvm) in
      XCTAssertEqual(IntegerType(64, in: &llvm).bitWidth, 64)
      XCTAssertEqual(IntegerType(32, in: &llvm).bitWidth, 32)
    }
  }

  func testCallSyntax() {
    Context.withNew { (llvm) in
      let i64 = IntegerType(64, in: &llvm)
      XCTAssertEqual(i64(1).sext, 1)
    }
  }

  func testConversion() {
    Context.withNew { (llvm) in
      let t: IRType = IntegerType(64, in: &llvm)
      XCTAssertNotNil(IntegerType(t))
      let u: IRType = FloatingPointType.float(in: &llvm)
      XCTAssertNil(IntegerType(u))
    }
  }

  func testEquality() {
    Context.withNew { (llvm) in
      let t = IntegerType(64, in: &llvm)
      let u = IntegerType(64, in: &llvm)
      XCTAssertEqual(t, u)

      let v = IntegerType(32, in: &llvm)
      XCTAssertNotEqual(t, v)
    }
  }

}
