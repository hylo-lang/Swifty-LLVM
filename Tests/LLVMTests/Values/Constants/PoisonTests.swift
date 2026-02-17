@testable import SwiftyLLVM
import XCTest

final class PoisonTests: XCTestCase {

  func testConversion() {
    var m = Module("foo")
    let t: any IRValue = m.values[m.poisonValue(of: m.float)]

    XCTAssertNotNil(Poison(t))
    let i64 = m.integerType(64)
    let u: any IRValue = m.types[i64].zero
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
