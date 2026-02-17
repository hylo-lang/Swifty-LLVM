import SwiftyLLVM
import XCTest

final class ArrayTypeTests: XCTestCase {

  func testCount() {
    var m = Module("foo")
    let i16 = m.integerType(16)
    XCTAssertEqual(m.types[m.arrayType(8, i16)].count, 8)
  }

  func testElement() {
    var m = Module("foo")
    let i16 = m.integerType(16)
    XCTAssertEqual(IntegerType(m.types[m.arrayType(8, i16)].element), m.types[i16])
  }

  func testConversion() {
    var m = Module("foo")
    let i16 = m.integerType(16)
    let t: any IRType = m.types[m.arrayType(8, i16)]
    XCTAssertNotNil(ArrayType(t))
    let u: any IRType = m.types[m.integerType(64)]
    XCTAssertNil(ArrayType(u))
  }

  func testEquality() {
    var m = Module("foo")
    let i16 = m.integerType(16)

    let t = m.types[m.arrayType(8, i16)]
    let u = m.types[m.arrayType(8, i16)]
    XCTAssertEqual(t, u)

    let v = m.types[m.arrayType(16, i16)]
    XCTAssertNotEqual(t, v)
  }

}
