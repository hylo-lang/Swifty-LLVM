import SwiftyLLVM
import XCTest

final class PointerTypeTests: XCTestCase {

  func testDefaultAddressSpace() {
    var m = Module("foo")
    XCTAssertEqual(m.types[PointerType.create(in: &m)].addressSpace, .default)
  }

  func testConversion() {
    var m = Module("foo")
    let t: any IRType = m.types[PointerType.create(in: &m)]
    XCTAssertNotNil(PointerType(t))
    let u: any IRType = m.types[IntegerType.create(64, in: &m)]
    XCTAssertNil(PointerType(u))
  }

  func testEquality() {
    var m = Module("foo")
    let t = m.types[PointerType.create(in: &m)]
    let u = m.types[PointerType.create(in: &m)]
    XCTAssertEqual(t, u)
  }

}
