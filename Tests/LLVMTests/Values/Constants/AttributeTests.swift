@testable import SwiftyLLVM
import XCTest

final class AttributeTests: XCTestCase {

  func testEquality() {
    var m = Module("foo")
    let a = m.functionAttribute(.cold)
    let b = m.functionAttribute(.cold)
    XCTAssertEqual(a, b)

    let c = m.functionAttribute(.hot)
    XCTAssertNotEqual(a, c)
  }

  func testValue() {
    var m = Module("foo")
    let a = m.parameterAttribute(.dereferenceable_or_null, 64)
    XCTAssertEqual(m.attributes[a].value, 64)
  }

}
