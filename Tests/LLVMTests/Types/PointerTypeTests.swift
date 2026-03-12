import SwiftyLLVM
import XCTest

final class PointerTypeTests: XCTestCase {

  func testDefaultAddressSpace() throws {
    var m = try Module("foo")
    XCTAssertEqual(m.pointerType().unsafe[].addressSpace, .default)
    XCTAssertEqual(m.ptr.unsafe[].addressSpace, .default)
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
    let t = m.pointerType().unsafe[]
    let u = m.pointerType().unsafe[]
    XCTAssertEqual(t, u)
  }

}
