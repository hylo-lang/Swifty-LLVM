@testable import SwiftyLLVM
import XCTest

final class PoisonTests: XCTestCase {

  func testConversion() {
    var m = Module("foo")
    
    let t = m.poisonValue(of: m.float)
    XCTAssertNotNil(Poison.UnsafeReference(t.erased))

    let u = m.i64.pointee.zero
    XCTAssertNil(Poison.UnsafeReference(u.erased))
  }

  func testEquality() {
    var m = Module("foo")
    let t = m.poisonValue(of: m.double)
    let u = m.poisonValue(of: m.double)
    XCTAssertEqual(t, u)

    let v = m.poisonValue(of: m.float)
    XCTAssertNotEqual(t, v)
  }

  func testIsConstant() {
    var m = Module("foo")
    
    let t = m.poisonValue(of: m.float)
    XCTAssertTrue(t.with{ p in p.isConstant})
  }

}
