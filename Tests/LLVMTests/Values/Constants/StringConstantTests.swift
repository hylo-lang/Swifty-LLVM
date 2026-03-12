import SwiftyLLVM
import XCTest

final class StringConstantTests: XCTestCase {

  func testInit() throws {
    var m = try Module("foo")
    let t = m.stringConstant("Bonjour!")
    XCTAssertEqual(t.unsafe[].value, "Bonjour!")
  }

  func testInitWithoutNullTerminator() throws {
    var m = try Module("foo")
    let t = m.stringConstant("Bonjour!", nullTerminated: false)
    XCTAssertEqual(t.unsafe[].value, "Bonjour!")
  }

  func testConversion() throws {
    var m = try Module("foo")

    let t = m.stringConstant("Bonjour!")
    XCTAssertNotNil(StringConstant.UnsafeReference(t.erased))

    let u = m.i64.unsafe[].zero
    XCTAssertNil(StringConstant.UnsafeReference(u.erased))
  }

  func testEquality() throws {
    var m = try Module("foo")

    let t = m.stringConstant("Bonjour!")
    let u = m.stringConstant("Bonjour!")
    XCTAssertEqual(t, u)

    let v = m.stringConstant("Guten Tag!")
    XCTAssertNotEqual(t, v)
  }

}
