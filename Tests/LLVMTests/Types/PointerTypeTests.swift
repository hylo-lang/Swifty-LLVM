import SwiftyLLVM
import XCTest

final class PointerTypeTests: XCTestCase {

  func testDefaultAddressSpace() {
    var m = Module("foo")
    XCTAssertEqual(m.pointerType().unsafePointee.addressSpace, .default)
    XCTAssertEqual(m.ptr.unsafePointee.addressSpace, .default)
  }

  func testConversion() {
    var m = Module("foo")
    let t: any IRType = m.pointerType().unsafePointee
    XCTAssertNotNil(PointerType(t))
    let u: any IRType = m.integerType(64).unsafePointee
    XCTAssertNil(PointerType(u))
  }

  func testEquality() {
    var m = Module("foo")
    let t = m.pointerType().unsafePointee
    let u = m.pointerType().unsafePointee
    XCTAssertEqual(t, u)
  }

}
