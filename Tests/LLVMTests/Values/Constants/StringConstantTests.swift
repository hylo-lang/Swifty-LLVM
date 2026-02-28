import SwiftyLLVM
import XCTest

final class StringConstantTests: XCTestCase {

  func testInit() {
    var m = Module("foo")
    let t = m.stringConstant("Bonjour!")
    XCTAssertEqual(t.unsafePointee.value, "Bonjour!")
  }

  func testInitWithoutNullTerminator() {
    var m = Module("foo")
    let t = m.stringConstant("Bonjour!", nullTerminated: false)
    XCTAssertEqual(t.unsafePointee.value, "Bonjour!")
  }

  func testConversion() {
    var m = Module("foo")

    let t = m.stringConstant("Bonjour!")
    XCTAssertNotNil(StringConstant.Reference(t.erased))

    let u = m.i64.unsafePointee.zero
    XCTAssertNil(StringConstant.Reference(u.erased))
  }

  func testEquality() {
    var m = Module("foo")

    let t = m.stringConstant("Bonjour!")
    let u = m.stringConstant("Bonjour!")
    XCTAssertEqual(t, u)

    let v = m.stringConstant("Guten Tag!")
    XCTAssertNotEqual(t, v)
  }

}
