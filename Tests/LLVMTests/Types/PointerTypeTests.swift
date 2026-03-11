import SwiftyLLVM
import XCTest

final class PointerTypeTests: XCTestCase {

  func testDefaultAddressSpace() throws {
    var m = try Module("foo")
    XCTAssertEqual(m.pointerType().pointee.addressSpace, .default)
    XCTAssertEqual(m.ptr.pointee.addressSpace, .default)
  }

  func testConversion() throws {
    var m = try Module("foo")
    
    let t = m.pointerType()
    XCTAssertNotNil(PointerType.UnsafeReference(t.erased))
    
    let u = m.integerType(64)
    XCTAssertNil(PointerType.UnsafeReference(u.erased))
  }

  func testEquality() throws {
    var m = try Module("foo")
    let t = m.pointerType().pointee
    let u = m.pointerType().pointee
    XCTAssertEqual(t, u)
  }

}
