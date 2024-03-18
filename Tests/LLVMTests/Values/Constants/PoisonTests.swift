import SwiftyLLVM
import XCTest

final class PoisonTests: XCTestCase {

  func testConversion() {
    Context.withNew { (llvm) in
      let t: IRValue = Poison(of: FloatingPointType.float(in: &llvm))
      XCTAssertNotNil(Poison(t))
      let u: IRValue = IntegerType(64, in: &llvm).zero
      XCTAssertNil(Poison(u))
    }
  }

  func testEquality() {
    Context.withNew { (llvm) in
      let t = Poison(of: FloatingPointType.double(in: &llvm))
      let u = Poison(of: FloatingPointType.double(in: &llvm))
      XCTAssertEqual(t, u)

      let v = Poison(of: FloatingPointType.float(in: &llvm))
      XCTAssertNotEqual(t, v)
    }
  }

}
