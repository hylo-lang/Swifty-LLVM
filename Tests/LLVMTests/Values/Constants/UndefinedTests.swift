import SwiftyLLVM
import XCTest

final class UndefinedTests: XCTestCase {

  func testConversion() {
    var m = Module("foo")
    let t: IRValue = Undefined(of: FloatingPointType.float(in: &m))
    XCTAssertNotNil(Undefined(t))
    let u: IRValue = IntegerType(64, in: &m).zero
    XCTAssertNil(Undefined(u))
  }

  func testEquality() {
    var m = Module("foo")
    let t = Undefined(of: FloatingPointType.double(in: &m))
    let u = Undefined(of: FloatingPointType.double(in: &m))
    XCTAssertEqual(t, u)

    let v = Undefined(of: FloatingPointType.float(in: &m))
    XCTAssertNotEqual(t, v)
  }

}
