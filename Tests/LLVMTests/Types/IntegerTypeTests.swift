@testable import SwiftyLLVM
import XCTest

final class IntegerTypeTests: XCTestCase {

  func testBitWidth() {
    var m = Module("foo")
    let i64 = IntegerType.create(64, in: &m)
    let i32 = IntegerType.create(32, in: &m)
    XCTAssertEqual(m.types[i64].bitWidth, 64)
    XCTAssertEqual(m.types[i32].bitWidth, 32)
  }

  func testCallSyntax() {
    var m = Module("foo")
    let i64 = IntegerType.create(64, in: &m)
    let t = m.types[i64]
    XCTAssertEqual(t(1).sext, 1)
  }

  func testConversion() {
    var m = Module("foo")
    let i64 = IntegerType.create(64, in: &m)
    let t: any IRType = m.types[i64]
    XCTAssertNotNil(IntegerType(t))
    let float = FloatingPointType.float(in: &m)
    let u: any IRType = m.types[float]
    XCTAssertNil(IntegerType(u))
  }

  func testEquality() {
    var m = Module("foo")
    let i64 = IntegerType.create(64, in: &m)
    let t = m.types[i64]
    let u = m.types[i64]
    XCTAssertEqual(t, u)

    let i32 = IntegerType.create(32, in: &m)
    let v = m.types[i32]
    XCTAssertNotEqual(t, v)
  }

}
