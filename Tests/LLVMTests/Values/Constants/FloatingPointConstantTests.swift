import SwiftyLLVM
import XCTest

final class FloatingPointConstantTests: XCTestCase {

  func testZero() {
    Context.withNew { (llvm) in
      let x = FloatingPointType.double(in: &llvm).zero
      XCTAssertEqual(x.value.value, 0.0, accuracy: .ulpOfOne)
    }
  }

  func testInitWithDouble() {
    Context.withNew { (llvm) in
      let x = FloatingPointType.double(in: &llvm).constant(4.2)
      XCTAssertEqual(x.value.value, 4.2, accuracy: .ulpOfOne)
    }
  }

  func testInitWithText() {
    Context.withNew { (llvm) in
      let x = FloatingPointType.double(in: &llvm).constant(parsing: "4.2")
      XCTAssertEqual(x.value.value, 4.2, accuracy: .ulpOfOne)
    }
  }

  func testConversion() {
    Context.withNew { (llvm) in
      let t: IRValue = FloatingPointType.float(in: &llvm).zero
      XCTAssertNotNil(FloatingPointConstant(t))
      let u: IRValue = IntegerType(64, in: &llvm).zero
      XCTAssertNil(FloatingPointConstant(u))
    }
  }

  func testEquality() {
    Context.withNew { (llvm) in
      let t = FloatingPointType.double(in: &llvm).zero
      let u = FloatingPointType.double(in: &llvm).zero
      XCTAssertEqual(t, u)

      let v = FloatingPointType.double(in: &llvm).constant(4.2)
      XCTAssertNotEqual(t, v)
    }
  }

}
