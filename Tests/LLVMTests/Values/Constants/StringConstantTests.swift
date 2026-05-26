import SwiftyLLVM
import XCTest

final class StringConstantTests: XCTestCase {

  func testInit() throws {
    var m = try Module("foo", targetMachine: .host())
    let t = m.stringConstant("Bonjour!")
    XCTAssertEqual(t.unsafe[].value, "Bonjour!")
  }

  func testInitWithoutNullTerminator() throws {
    var m = try Module("foo", targetMachine: .host())
    let t = m.stringConstant("Bonjour!", nullTerminated: false)
    XCTAssertEqual(t.unsafe[].value, "Bonjour!")
  }

  func testConversion() throws {
    var m = try Module("foo", targetMachine: .host())

    let t = m.stringConstant("Bonjour!")
    XCTAssertNotNil(StringConstant.UnsafeReference(t.asAnyValue))

    let u = m.i64.unsafe[].zero
    XCTAssertNil(StringConstant.UnsafeReference(u.asAnyValue))
  }

  func testEquality() throws {
    var m = try Module("foo", targetMachine: .host())

    let t = m.stringConstant("Bonjour!")
    let u = m.stringConstant("Bonjour!")
    XCTAssertEqual(t, u)

    let v = m.stringConstant("Guten Tag!")
    XCTAssertNotEqual(t, v)
  }

}
