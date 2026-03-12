import SwiftyLLVM
import XCTest

final class VoidTypeTests: XCTestCase {

  func testBitWidth() throws {
    var m = try Module("foo")
    XCTAssertEqual(m.integerType(64).unsafe[].bitWidth, 64)
    XCTAssertEqual(m.integerType(32).unsafe[].bitWidth, 32)
  }

  func testConversion() throws {
    var m = try Module("foo")

    let t: VoidType.UnsafeReference = m.void
    XCTAssertNotNil(VoidType.UnsafeReference(t.erased))
    
    let u = m.integerType(64)
    XCTAssertNil(VoidType.UnsafeReference(u.erased))
  }

  func testEquality() throws {
    var m = try Module("foo")
    let t = m.void
    let u = m.void
    XCTAssertEqual(t, u)
  }

}
