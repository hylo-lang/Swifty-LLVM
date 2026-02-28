import XCTest

@testable import SwiftyLLVM

final class IntegerConstantTests: XCTestCase {

  func testZero() {
    var m = Module("foo")
    let x = m.integerType(64).unsafePointee.zero.unsafePointee
    XCTAssertEqual(x.sext, 0)
    XCTAssertEqual(x.zext, 0)
  }

  func testInitWithBitPattern() {
    var m = Module("foo")
    let x = m.integerType(8).unsafePointee.constant(255).unsafePointee
    XCTAssertEqual(x.sext, -1)
    XCTAssertEqual(x.zext, 255)
  }

  func testInitWithSignedValue() {
    var m = Module("foo")
    let x = m.integerType(8).unsafePointee.constant(-128).unsafePointee
    XCTAssertEqual(x.sext, -128)
    XCTAssertEqual(x.zext, 128)
  }

  func testInitWithWords() {
    var m = Module("foo")
    let x = m.integerType(8).unsafePointee.constant(words: [255]).unsafePointee
    XCTAssertEqual(x.sext, -1)
    XCTAssertEqual(x.zext, 255)
  }

  func testInitWithText() {
    var m = Module("foo")
    let x = m.integerType(8).unsafePointee.constant(parsing: "11111111", radix: 2).unsafePointee
    XCTAssertEqual(x.sext, -1)
    XCTAssertEqual(x.zext, 255)
  }

  func testConversion() {
    var m = Module("foo")
    let i64 = m.integerType(64)
    let t = i64.unsafePointee.zero
    XCTAssertNotNil(IntegerConstant.Reference(t.erased))

    let ft = FloatingPointType.float(in: &m)
    let ty = ft.unsafePointee
    let u = ty.zero
    XCTAssertNil(IntegerConstant.Reference(u.erased))
  }

  func testEquality() {
    var m = Module("foo")
    let i64 = m.integerType(64).unsafePointee
    let t = i64.zero
    let u = i64.zero
    XCTAssertEqual(t, u)

    let v = i64.constant(255)
    XCTAssertNotEqual(t, v)
  }

}
