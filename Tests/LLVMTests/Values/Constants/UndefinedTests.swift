import XCTest

@testable import SwiftyLLVM

final class UndefinedTests: XCTestCase {

  func testConversion() {
    var m = Module("foo")

    let t = m.undefinedValue(of: m.float)
    XCTAssertNotNil(Undefined.Reference(t.erased))

    let u = m.i64.unsafePointee.zero
    XCTAssertNil(Undefined.Reference(u.erased))
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
