import SwiftyLLVM
import XCTest

final class StringConstantTests: XCTestCase {

  func testInit() {
    var m = Module("foo")
    let t = StringConstant("Bonjour!", in: &m)
    XCTAssertEqual(t.value, "Bonjour!")
  }

  func testInitWithoutNullTerminator() {
    var m = Module("foo")
    let t = StringConstant("Bonjour!", nullTerminated: false, in: &m)
    XCTAssertEqual(t.value, "Bonjour!")
  }

  func testConversion() {
    var m = Module("foo")
    let t: IRValue = StringConstant("Bonjour!", in: &m)
    XCTAssertNotNil(StringConstant(t))
    let u: IRValue = IntegerType(64, in: &m).zero
    XCTAssertNil(StringConstant(u))
  }

  func testEquality() {
    var m = Module("foo")
    let t = StringConstant("Bonjour!", in: &m)
    let u = StringConstant("Bonjour!", in: &m)
    XCTAssertEqual(t, u)

    let v = StringConstant("Guten Tag!", in: &m)
    XCTAssertNotEqual(t, v)
  }

}
