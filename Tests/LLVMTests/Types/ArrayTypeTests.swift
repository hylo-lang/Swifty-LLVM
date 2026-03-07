import SwiftyLLVM
import XCTest

final class ArrayTypeTests: XCTestCase {

  func testCount() {
    var m = Module("foo")
    let i16 = m.integerType(16)
    XCTAssertEqual(m.arrayType(8, i16).pointee.count, 8)
  }

  func testElement() {
    var m = Module("foo")
    let i16 = m.i16
    XCTAssertEqual(IntegerType.UnsafeReference(m.arrayType(8, i16).pointee.element), i16)
  }

  func testConversion() {
    var m = Module("foo")
    let i16 = m.integerType(16)
    
    let t = m.arrayType(8, i16)
    XCTAssertNotNil(ArrayType.UnsafeReference(t.erased))
    
    let u = m.integerType(64)
    XCTAssertNil(ArrayType.UnsafeReference(u.erased))
  }

  func testEquality() {
    var m = Module("foo")
    let i16 = m.integerType(16)

    let t = m.arrayType(8, i16).pointee
    let u = m.arrayType(8, i16).pointee
    XCTAssertEqual(t, u)

    let v = m.arrayType(16, i16).pointee
    XCTAssertNotEqual(t, v)
  }

}
