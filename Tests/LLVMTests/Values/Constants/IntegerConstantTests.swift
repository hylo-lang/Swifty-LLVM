import XCTest

@testable import SwiftyLLVM

final class IntegerConstantTests: XCTestCase {

  func testZero() {
    var m = Module("foo")
    let x = m.integerType(64).pointee.zero.pointee
    XCTAssertEqual(x.sext, 0)
    XCTAssertEqual(x.zext, 0)
  }

  func testInitWithBitPattern() {
    var m = Module("foo")
    let x = m.integerType(8).pointee.constant(255).pointee
    XCTAssertEqual(x.sext, -1)
    XCTAssertEqual(x.zext, 255)
  }

  func testInitWithSignedValue() {
    var m = Module("foo")
    let x = m.integerType(8).pointee.constant(-128).pointee
    XCTAssertEqual(x.sext, -128)
    XCTAssertEqual(x.zext, 128)
  }

  func testInitWithWords() {
    var m = Module("foo")
    let x = m.integerType(8).pointee.constant(words: [255]).pointee
    XCTAssertEqual(x.sext, -1)
    XCTAssertEqual(x.zext, 255)
  }

  func testInitWithText() {
    var m = Module("foo")
    let x = m.integerType(8).pointee.constant(parsing: "11111111", radix: 2).pointee
    XCTAssertEqual(x.sext, -1)
    XCTAssertEqual(x.zext, 255)
  }

  func testConversion() {
    var m = Module("foo")
    let i64 = m.integerType(64)
    let t = i64.pointee.zero
    XCTAssertNotNil(IntegerConstant.UnsafeReference(t.erased))

    let ft = FloatingPointType.float(in: &m)
    let ty = ft.pointee
    let u = ty.zero
    XCTAssertNil(IntegerConstant.UnsafeReference(u.erased))
  }

  func testEquality() {
    var m = Module("foo")
    let i64 = m.integerType(64).pointee
    let t = i64.zero
    let u = i64.zero
    XCTAssertEqual(t, u)

    let v = i64.constant(255)
    XCTAssertNotEqual(t, v)
  }

}
