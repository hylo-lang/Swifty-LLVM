import XCTest

@testable import SwiftyLLVM

final class UndefinedTests: XCTestCase {

  func testConversion() throws {
    var m = try Module("foo", targetMachine: .host())

    let t = m.undefinedValue(of: m.float)
    XCTAssertNotNil(Undefined.UnsafeReference(t.asAnyValue))

    let u = m.i64.unsafe[].zero
    XCTAssertNil(Undefined.UnsafeReference(u.asAnyValue))
  }

  func testEquality() throws {
    var m = try Module("foo", targetMachine: .host())
    let t = m.undefinedValue(of: m.double)
    let u = m.undefinedValue(of: m.double)
    XCTAssertEqual(t, u)

    let v = m.undefinedValue(of: m.float)
    XCTAssertNotEqual(t, v)
  }

}
