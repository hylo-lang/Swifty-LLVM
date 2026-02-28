import SwiftyLLVM
import XCTest

final class VoidTypeTests: XCTestCase {

  func testBitWidth() {
    var m = Module("foo")
    XCTAssertEqual(m.integerType(64).unsafePointee.bitWidth, 64)
    XCTAssertEqual(m.integerType(32).unsafePointee.bitWidth, 32)
  }

  func testConversion() {
    var m = Module("foo")

    let t: VoidType.Reference = m.void
    XCTAssertNotNil(VoidType.Reference(t.erased))
    
    let u = m.integerType(64)
    XCTAssertNil(VoidType.Reference(u.erased))
  }

  func testEquality() {
    var m = Module("foo")
    let t = m.void
    let u = m.void
    XCTAssertEqual(t, u)
  }

}
