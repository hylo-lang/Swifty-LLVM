import SwiftyLLVM
import XCTest

final class PointerTypeTests: XCTestCase {

  func testDefaultAddressSpace() {
    Context.withNew { (llvm) in
      XCTAssertEqual(PointerType(in: &llvm).addressSpace, .default)
    }
  }

  func testConversion() {
    Context.withNew { (llvm) in
      let t: IRType = PointerType(in: &llvm)
      XCTAssertNotNil(PointerType(t))
      let u: IRType = IntegerType(64, in: &llvm)
      XCTAssertNil(PointerType(u))
    }
  }

  func testEquality() {
    Context.withNew { (llvm) in
      let t = PointerType(in: &llvm)
      let u = PointerType(in: &llvm)
      XCTAssertEqual(t, u)
    }
  }

}
