import XCTest

@testable import SwiftyLLVM

final class IntegerConstantTests: XCTestCase {

  func testZero() throws {
    var m = try Module("foo")
    let x = m.integerType(64).unsafe[].zero.unsafe[]
    XCTAssertEqual(x.sext, 0)
    XCTAssertEqual(x.zext, 0)
  }

  func testInitWithBitPattern() throws {
    var m = try Module("foo")
    let x = m.integerType(8).unsafe[].constant(255).unsafe[]
    XCTAssertEqual(x.sext, -1)
    XCTAssertEqual(x.zext, 255)
  }

  func testInitWithSignedValue() throws {
    var m = try Module("foo")
    let x = m.integerType(8).unsafe[].constant(-128).unsafe[]
    XCTAssertEqual(x.sext, -128)
    XCTAssertEqual(x.zext, 128)
  }

  func testInitWithWords() throws {
    var m = try Module("foo")
    let x = m.integerType(8).unsafe[].constant(words: [255]).unsafe[]
    XCTAssertEqual(x.sext, -1)
    XCTAssertEqual(x.zext, 255)
  }

  func testInitWithText() throws {
    var m = try Module("foo")
    let x = m.integerType(8).unsafe[].constant(parsing: "11111111", radix: 2).unsafe[]
    XCTAssertEqual(x.sext, -1)
    XCTAssertEqual(x.zext, 255)
  }

  func testConversion() throws {
    var m = try Module("foo")
    let i64 = m.integerType(64)
    let t = i64.unsafe[].zero
    XCTAssertNotNil(IntegerConstant.UnsafeReference(t.erased))

    let ft = FloatingPointType.float(in: &m)
    let ty = ft.unsafe[]
    let u = ty.zero
    XCTAssertNil(IntegerConstant.UnsafeReference(u.erased))
  }

  func testEquality() throws {
    var m = try Module("foo")
    let i64 = m.integerType(64).unsafe[]
    let t = i64.zero
    let u = i64.zero
    XCTAssertEqual(t, u)

    let v = i64.constant(255)
    XCTAssertNotEqual(t, v)
  }

}
