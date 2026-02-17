import SwiftyLLVM
import XCTest

final class PointerTypeTests: XCTestCase {

  func testDefaultAddressSpace() {
    var m = Module("foo")
    XCTAssertEqual(m.types[m.pointerType()].addressSpace, .default)
    XCTAssertEqual(m.types[m.ptr].addressSpace, .default)
  }

  func testConversion() {
    var m = Module("foo")
    let t: any IRType = m.types[m.pointerType()]
    XCTAssertNotNil(PointerType(t))
    let u: any IRType = m.types[m.integerType(64)]
    XCTAssertNil(PointerType(u))
  }

  func testEquality() {
    var m = Module("foo")
    let t = m.types[m.pointerType()]
    let u = m.types[m.pointerType()]
    XCTAssertEqual(t, u)
  }

}
