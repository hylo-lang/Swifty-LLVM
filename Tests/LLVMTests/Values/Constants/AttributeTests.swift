@testable import SwiftyLLVM
import XCTest

final class AttributeTests: XCTestCase {

  func testEquality() {
    var m = Module("foo")
    let a = m.createFunctionAttribute(.cold)
    let b = m.createFunctionAttribute(.cold)
    XCTAssertEqual(a, b)

    let c = m.createFunctionAttribute(.hot)
    XCTAssertNotEqual(a, c)
  }

  func testValue() {
    var m = Module("foo")
    let a = m.createParameterAttribute(.dereferenceable_or_null, 64)
    XCTAssertEqual(m.attributes[a].value, 64)
  }

}
