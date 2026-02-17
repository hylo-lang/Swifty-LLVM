import SwiftyLLVM
import XCTest

final class VoidTypeTests: XCTestCase {

  func testBitWidth() {
    var m = Module("foo")
    XCTAssertEqual(m.types[IntegerType.create(64, in: &m)].bitWidth, 64)
    XCTAssertEqual(m.types[IntegerType.create(32, in: &m)].bitWidth, 32)
  }

  func testConversion() {
    var m = Module("foo")
    let t: any IRType = m.types[VoidType.create(in: &m)]
    XCTAssertNotNil(VoidType(t))
    let u: any IRType = m.types[IntegerType.create(64, in: &m)]
    XCTAssertNil(VoidType(u))
  }

  func testEquality() {
    var m = Module("foo")
    let t = m.types[VoidType.create(in: &m)]
    let u = m.types[VoidType.create(in: &m)]
    XCTAssertEqual(t, u)
  }

}
