import SwiftyLLVM
import XCTest

final class VoidTypeTests: XCTestCase {

  func testConversion() throws {
    var m = try Module("foo")

    let t: VoidType.UnsafeReference = m.void
    XCTAssertNotNil(VoidType.UnsafeReference(t.erased))
    
    let u = m.integerType(64)
    XCTAssertNil(VoidType.UnsafeReference(u.erased))
  }

  func testEquality() throws {
    let m = try Module("foo")
    let t = m.void
    let u = m.void
    XCTAssertEqual(t, u)
  }

}
