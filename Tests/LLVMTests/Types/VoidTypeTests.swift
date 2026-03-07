import SwiftyLLVM
import XCTest

final class VoidTypeTests: XCTestCase {

  func testBitWidth() {
    var m = Module("foo")
    XCTAssertEqual(m.integerType(64).pointee.bitWidth, 64)
    XCTAssertEqual(m.integerType(32).pointee.bitWidth, 32)
  }

  func testConversion() {
    var m = Module("foo")

    let t: VoidType.UnsafeReference = m.void
    XCTAssertNotNil(VoidType.UnsafeReference(t.erased))
    
    let u = m.integerType(64)
    XCTAssertNil(VoidType.UnsafeReference(u.erased))
  }

  func testEquality() {
    var m = Module("foo")
    let t = m.void
    let u = m.void
    XCTAssertEqual(t, u)
  }

}
