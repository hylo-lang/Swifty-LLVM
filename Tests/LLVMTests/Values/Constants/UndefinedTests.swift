@testable import SwiftyLLVM
import XCTest

final class UndefinedTests: XCTestCase {

  func testConversion() {
    var m = Module("foo")
    let t: any IRValue = m.values[m.undefinedValue(of: m.float)]
    XCTAssertNotNil(Undefined(t))
    let u: any IRValue = m.types[m.i64].zero
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
