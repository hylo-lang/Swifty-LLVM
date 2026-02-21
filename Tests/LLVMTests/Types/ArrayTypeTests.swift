import SwiftyLLVM
import XCTest

final class ArrayTypeTests: XCTestCase {

  func testCount() {
    var m = Module("foo")
    let i16 = m.integerType(16)
    XCTAssertEqual(m.arrayType(8, i16).unsafePointee.count, 8)
  }

  func testElement() {
    var m = Module("foo")
    let i16 = m.integerType(16)
    XCTAssertEqual(IntegerType(m.arrayType(8, i16).unsafePointee.element.unsafePointee), i16.unsafePointee)
  }

  func testConversion() {
    var m = Module("foo")
    let i16 = m.integerType(16)
    let t: any IRType = m.arrayType(8, i16).unsafePointee
    XCTAssertNotNil(ArrayType(t))
    let u: any IRType = m.integerType(64).unsafePointee
    XCTAssertNil(ArrayType(u))
  }

  func testEquality() {
    var m = Module("foo")
    let i16 = m.integerType(16)

    let t = m.arrayType(8, i16).unsafePointee
    let u = m.arrayType(8, i16).unsafePointee
    XCTAssertEqual(t, u)

    let v = m.arrayType(16, i16).unsafePointee
    XCTAssertNotEqual(t, v)
  }

}
