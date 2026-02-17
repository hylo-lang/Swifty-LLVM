import SwiftyLLVM
import XCTest

final class ArrayTypeTests: XCTestCase {

  func testCount() {
    var m = Module("foo")
    let i16 = m.types[IntegerType.create(16, in: &m)]
    XCTAssertEqual(m.types[ArrayType.create(8, i16, in: &m)].count, 8)
  }

  func testElement() {
    var m = Module("foo")
    let i16 = m.types[IntegerType.create(16, in: &m)]
    XCTAssertEqual(IntegerType(m.types[ArrayType.create(8, i16, in: &m)].element), i16)
  }

  func testConversion() {
    var m = Module("foo")
    let i16 = m.types[IntegerType.create(16, in: &m)]
    let t: any IRType = m.types[ArrayType.create(8, i16, in: &m)]
    XCTAssertNotNil(ArrayType(t))
    let u: any IRType = m.types[IntegerType.create(64, in: &m)]
    XCTAssertNil(ArrayType(u))
  }

  func testEquality() {
    var m = Module("foo")
    let i16 = m.types[IntegerType.create(16, in: &m)]

    let t = m.types[ArrayType.create(8, i16, in: &m)]
    let u = m.types[ArrayType.create(8, i16, in: &m)]
    XCTAssertEqual(t, u)

    let v = m.types[ArrayType.create(16, i16, in: &m)]
    XCTAssertNotEqual(t, v)
  }

}
