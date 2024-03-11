import SwiftyLLVM
import XCTest

final class VoidTypeTests: XCTestCase {

  func testBitWidth() {
    Context.withNew { (llvm) in
      XCTAssertEqual(IntegerType(64, in: &llvm).bitWidth, 64)
      XCTAssertEqual(IntegerType(32, in: &llvm).bitWidth, 32)
    }
  }

  func testConversion() {
    Context.withNew { (llvm) in
      let t: IRType = VoidType(in: &llvm)
      XCTAssertNotNil(VoidType(t))
      let u: IRType = IntegerType(64, in: &llvm)
      XCTAssertNil(VoidType(u))
    }
  }

  func testEquality() {
    Context.withNew { (llvm) in
      let t = VoidType(in: &llvm)
      let u = VoidType(in: &llvm)
      XCTAssertEqual(t, u)
    }
  }

}
