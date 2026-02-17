@testable import SwiftyLLVM
import XCTest

final class IntegerConstantTests: XCTestCase {

  func testZero() {
    var m = Module("foo")
    let x = m.types[IntegerType.create(64, in: &m)].zero
    XCTAssertEqual(x.sext, 0)
    XCTAssertEqual(x.zext, 0)
  }

  func testInitWithBitPattern() {
    var m = Module("foo")
    let x = m.types[IntegerType.create(8, in: &m)].constant(255)
    XCTAssertEqual(x.sext, -1)
    XCTAssertEqual(x.zext, 255)
  }

  func testInitWithSignedValue() {
    var m = Module("foo")
    let x = m.types[IntegerType.create(8, in: &m)].constant(-128)
    XCTAssertEqual(x.sext, -128)
    XCTAssertEqual(x.zext, 128)
  }

  func testInitWithWords() {
    var m = Module("foo")
    let x = m.types[IntegerType.create(8, in: &m)].constant(words: [255])
    XCTAssertEqual(x.sext, -1)
    XCTAssertEqual(x.zext, 255)
  }

  func testInitWithText() {
    var m = Module("foo")
    let x = m.types[IntegerType.create(8, in: &m)].constant(parsing: "11111111", radix: 2)
    XCTAssertEqual(x.sext, -1)
    XCTAssertEqual(x.zext, 255)
  }

  func testConversion() {
    var m = Module("foo")
    let t: any IRValue = m.types[IntegerType.create(64, in: &m)].zero
    XCTAssertNotNil(IntegerConstant(t))
    let ft = FloatingPointType.float(in: &m)
    let ty = m.types[ft]
    let u: any IRValue = m.values[ty.zero(in: &m)]
    XCTAssertNil(IntegerConstant(u))
  }

  func testEquality() {
    var m = Module("foo")
    let i64 = m.types[IntegerType.create(64, in: &m)]
    let t = i64.zero
    let u = i64.zero
    XCTAssertEqual(t, u)

    let v = i64.constant(255)
    XCTAssertNotEqual(t, v)
  }

}
