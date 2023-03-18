import LLVM
import XCTest

final class AttributeTests: XCTestCase {

  func testEquality() {
    var m = Module("foo")
    let a = Function.Attribute(.cold, in: &m)
    let b = Function.Attribute(.cold, in: &m)
    XCTAssertEqual(a, b)

    let c = Function.Attribute(.hot, in: &m)
    XCTAssertNotEqual(a, c)
  }

  func testValue() {
    var m = Module("foo")
    XCTAssertEqual(Parameter.Attribute(.dereferenceable_or_null, 64, in: &m).value, 64)
  }

}
