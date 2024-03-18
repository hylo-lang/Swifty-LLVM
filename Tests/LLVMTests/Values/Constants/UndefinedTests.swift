import SwiftyLLVM
import XCTest

final class UndefinedTests: XCTestCase {

  func testConversion() {
    Context.withNew { (llvm) in
      let t: IRValue = Undefined(of: FloatingPointType.float(in: &llvm))
      XCTAssertNotNil(Undefined(t))
      let u: IRValue = IntegerType(64, in: &llvm).zero
      XCTAssertNil(Undefined(u))
    }
  }

  func testEquality() {
    Context.withNew { (llvm) in
      let t = Undefined(of: FloatingPointType.double(in: &llvm))
      let u = Undefined(of: FloatingPointType.double(in: &llvm))
      XCTAssertEqual(t, u)

      let v = Undefined(of: FloatingPointType.float(in: &llvm))
      XCTAssertNotEqual(t, v)
    }
  }

}
