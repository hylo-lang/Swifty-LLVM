import LLVM
import XCTest

final class IntegerConstantTests: XCTestCase {

  func testZero() {
    var m = Module("foo")
    let x = IntegerType(64, in: &m).zero
    XCTAssertEqual(x.sext, 0)
    XCTAssertEqual(x.zext, 0)
  }

  func testInitWithBitPattern() {
    var m = Module("foo")
    let x = IntegerType(8, in: &m).constant(255)
    XCTAssertEqual(x.sext, -1)
    XCTAssertEqual(x.zext, 255)
  }

  func testInitWithSignedValue() {
    var m = Module("foo")
    let x = IntegerType(8, in: &m).constant(-128)
    XCTAssertEqual(x.sext, -128)
    XCTAssertEqual(x.zext, 128)
  }

  func testInitWithWords() {
    var m = Module("foo")
    let x = IntegerType(8, in: &m).constant(words: [255])
    XCTAssertEqual(x.sext, -1)
    XCTAssertEqual(x.zext, 255)
  }

  func testInitWithText() {
    var m = Module("foo")
    let x = IntegerType(8, in: &m).constant(parsing: "11111111", radix: 2)
    XCTAssertEqual(x.sext, -1)
    XCTAssertEqual(x.zext, 255)
  }

  func testConversion() {
    var m = Module("foo")
    let t: IRValue = IntegerType(64, in: &m).zero
    XCTAssertNotNil(IntegerConstant(t))
    let u: IRValue = FloatingPointType.float(in: &m).zero
    XCTAssertNil(IntegerConstant(u))
  }

  func testEquality() {
    var m = Module("foo")
    let t = IntegerType(64, in: &m).zero
    let u = IntegerType(64, in: &m).zero
    XCTAssertEqual(t, u)

    let v = IntegerType(64, in: &m).constant(255)
    XCTAssertNotEqual(t, v)
  }

}
