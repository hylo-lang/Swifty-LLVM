import SwiftyLLVM
import XCTest

final class IntegerConstantTests: XCTestCase {

  func testZero() {
    Context.withNew { (llvm) in
      let x = IntegerType(64, in: &llvm).zero
      XCTAssertEqual(x.sext, 0)
      XCTAssertEqual(x.zext, 0)
    }
  }

  func testInitWithBitPattern() {
    Context.withNew { (llvm) in
      let x = IntegerType(8, in: &llvm).constant(255)
      XCTAssertEqual(x.sext, -1)
      XCTAssertEqual(x.zext, 255)
    }
  }

  func testInitWithSignedValue() {
    Context.withNew { (llvm) in
      let x = IntegerType(8, in: &llvm).constant(-128)
      XCTAssertEqual(x.sext, -128)
      XCTAssertEqual(x.zext, 128)
    }
  }

  func testInitWithWords() {
    Context.withNew { (llvm) in
      let x = IntegerType(8, in: &llvm).constant(words: [255])
      XCTAssertEqual(x.sext, -1)
      XCTAssertEqual(x.zext, 255)
    }
  }

  func testInitWithText() {
    Context.withNew { (llvm) in
      let x = IntegerType(8, in: &llvm).constant(parsing: "11111111", radix: 2)
      XCTAssertEqual(x.sext, -1)
      XCTAssertEqual(x.zext, 255)
    }
  }

  func testConversion() {
    Context.withNew { (llvm) in
      let t: IRValue = IntegerType(64, in: &llvm).zero
      XCTAssertNotNil(IntegerConstant(t))
      let u: IRValue = FloatingPointType.float(in: &llvm).zero
      XCTAssertNil(IntegerConstant(u))
    }
  }

  func testEquality() {
    Context.withNew { (llvm) in
      let t = IntegerType(64, in: &llvm).zero
      let u = IntegerType(64, in: &llvm).zero
      XCTAssertEqual(t, u)

      let v = IntegerType(64, in: &llvm).constant(255)
      XCTAssertNotEqual(t, v)
    }
  }

}
