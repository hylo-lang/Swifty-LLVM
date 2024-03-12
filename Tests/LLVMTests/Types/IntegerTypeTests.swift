import SwiftyLLVM
import XCTest

final class IntegerTypeTests: XCTestCase {

  func testBitWidth() {
    var m = Module("foo")
    XCTAssertEqual(IntegerType(64, in: &m).bitWidth, 64)
    XCTAssertEqual(IntegerType(32, in: &m).bitWidth, 32)
  }

  func testCallSyntax() {
    var m = Module("foo")
    let i64 = IntegerType(64, in: &m)
    XCTAssertEqual(i64(1).sext, 1)
  }

  func testConversion() {
    var m = Module("foo")
    let t: IRType = IntegerType(64, in: &m)
    XCTAssertNotNil(IntegerType(t))
    let u: IRType = FloatingPointType.float(in: &m)
    XCTAssertNil(IntegerType(u))
  }

  func testEquality() {
    var m = Module("foo")
    let t = IntegerType(64, in: &m)
    let u = IntegerType(64, in: &m)
    XCTAssertEqual(t, u)

    let v = IntegerType(32, in: &m)
    XCTAssertNotEqual(t, v)
  }

}
