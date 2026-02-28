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
    
    let t = m.pointerType()
    XCTAssertNotNil(PointerType.Reference(t.erased))
    
    let u = m.integerType(64)
    XCTAssertNil(PointerType.Reference(u.erased))
  }

  func testEquality() {
    var m = Module("foo")
    let t = m.pointerType().unsafePointee
    let u = m.pointerType().unsafePointee
    XCTAssertEqual(t, u)
  }

}
