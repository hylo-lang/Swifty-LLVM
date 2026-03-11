@testable import SwiftyLLVM
import XCTest

final class AttributeTests: XCTestCase {

  func testEquality() throws {
    var m = try Module("foo")
    let a = m.functionAttribute(.cold)
    let b = m.functionAttribute(.cold)
    XCTAssertEqual(a, b)

    let c = m.functionAttribute(.hot)
    XCTAssertNotEqual(a, c)
  }

  func testValue() throws {
    var m = try Module("foo")
    let a = m.parameterAttribute(.dereferenceable_or_null, 64)
    XCTAssertEqual(a.pointee.value, 64)
  }

}
