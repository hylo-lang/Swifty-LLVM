@testable import SwiftyLLVM
import XCTest

final class PoisonTests: XCTestCase {

  func testConversion() {
    var m = Module("foo")
    let t: any IRValue = m.poisonValue(of: m.float).unsafePointee

    XCTAssertNotNil(Poison(t))
    let i64 = m.integerType(64)
    let u: any IRValue = i64.unsafePointee.zero.unsafePointee
    XCTAssertNil(Poison(u))
  }

  func testEquality() {
    var m = Module("foo")
    let t = m.poisonValue(of: m.double)
    let u = m.poisonValue(of: m.double)
    XCTAssertEqual(t, u)

    let v = m.poisonValue(of: m.float)
    XCTAssertNotEqual(t, v)
  }

}
