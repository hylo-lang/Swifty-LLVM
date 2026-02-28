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
    let i16 = m.i16
    XCTAssertEqual(IntegerType.Reference(m.arrayType(8, i16).unsafePointee.element), i16)
  }

  func testConversion() {
    var m = Module("foo")
    let i16 = m.integerType(16)
    
    let t = m.arrayType(8, i16)
    XCTAssertNotNil(ArrayType.Reference(t.erased))
    
    let u = m.integerType(64)
    XCTAssertNil(ArrayType.Reference(u.erased))
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
