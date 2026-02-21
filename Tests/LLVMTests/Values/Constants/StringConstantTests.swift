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
    let t: any IRValue = m.stringConstant("Bonjour!").unsafePointee
    XCTAssertNotNil(StringConstant(t))
    let u: any IRValue = m.i64.unsafePointee.zero.unsafePointee
    XCTAssertNil(StringConstant(u))
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
