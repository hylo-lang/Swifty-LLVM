import SwiftyLLVM
import XCTest

final class FloatingPointTypeTests: XCTestCase {

  func testConversion() {
    Context.withNew { (llvm) in
      let t0: IRType = FloatingPointType.half(in: &llvm)
      let t1: IRType = FloatingPointType.float(in: &llvm)
      let t2: IRType = FloatingPointType.double(in: &llvm)
      let t3: IRType = FloatingPointType.fp128(in: &llvm)
      for t in [t0, t1, t2, t3] {
        XCTAssertNotNil(FloatingPointType(t))
      }

      let u: IRType = IntegerType(64, in: &llvm)
      XCTAssertNil(FloatingPointType(u))
    }
  }

  func testCallSyntax() {
    Context.withNew { (llvm) in
      let double = FloatingPointType.double(in: &llvm)
      XCTAssertEqual(double(1).value.value, 1, accuracy: .ulpOfOne)
    }
  }

  func testEquality() {
    Context.withNew { (llvm) in
      let t = FloatingPointType.double(in: &llvm)
      let u = FloatingPointType.double(in: &llvm)
      XCTAssertEqual(t, u)

      let v = FloatingPointType.float(in: &llvm)
      XCTAssertNotEqual(t, v)
    }
  }

}
