import XCTest

@testable import SwiftyLLVM

final class UndefinedTests: XCTestCase {

  func testConversion() {
    var m = Module("foo")
    let t: any IRValue = m.undefinedValue(of: m.float).unsafePointee
    XCTAssertNotNil(Undefined(t))
    let u: any IRValue = m.i64.unsafePointee.zero.unsafePointee
    XCTAssertNil(Undefined(u))
  }

  func testEquality() {
    var m = Module("foo")
    let t = m.undefinedValue(of: m.double)
    let u = m.undefinedValue(of: m.double)
    XCTAssertEqual(t, u)

    let v = m.undefinedValue(of: m.float)
    XCTAssertNotEqual(t, v)
  }

}
