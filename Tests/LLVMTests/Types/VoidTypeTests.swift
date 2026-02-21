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
    let t: any IRType = m.void.unsafePointee
    XCTAssertNotNil(VoidType(t))
    let u: any IRType = m.integerType(64).unsafePointee
    XCTAssertNil(VoidType(u))
  }

  func testEquality() {
    var m = Module("foo")
    let t = m.void
    let u = m.void
    XCTAssertEqual(t, u)
  }

}
