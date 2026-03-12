@testable import SwiftyLLVM
import XCTest

final class PoisonTests: XCTestCase {

  func testConversion() throws {
    var m = try Module("foo")
    
    let t = m.poisonValue(of: m.float)
    XCTAssertNotNil(Poison.UnsafeReference(t.erased))

    let u = m.i64.unsafe[].zero
    XCTAssertNil(Poison.UnsafeReference(u.erased))
  }

  func testEquality() throws {
    var m = try Module("foo")
    let t = m.poisonValue(of: m.double)
    let u = m.poisonValue(of: m.double)
    XCTAssertEqual(t, u)

    let v = m.poisonValue(of: m.float)
    XCTAssertNotEqual(t, v)
  }

  func testIsConstant() throws {
    var m = try Module("foo")
    
    let t = m.poisonValue(of: m.float)
    XCTAssertTrue(t.unsafe[].isConstant)
  }

}
