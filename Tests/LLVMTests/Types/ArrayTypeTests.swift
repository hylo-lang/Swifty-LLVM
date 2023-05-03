import LLVM
import XCTest

final class ArrayTypeTests: XCTestCase {

  func testCount() {
    var m = Module("foo")
    let i16 = IntegerType(16, in: &m)
    XCTAssertEqual(ArrayType(8, i16, in: &m).count, 8)
  }

  func testElement() {
    var m = Module("foo")
    let i16 = IntegerType(16, in: &m)
    XCTAssertEqual(IntegerType(ArrayType(8, i16, in: &m).element), i16)
  }

  func testConversion() {
    var m = Module("foo")
    let i16 = IntegerType(16, in: &m)
    let t: IRType = ArrayType(8, i16, in: &m)
    XCTAssertNotNil(ArrayType(t))
    let u: IRType = IntegerType(64, in: &m)
    XCTAssertNil(ArrayType(u))
  }

  func testEquality() {
    var m = Module("foo")
    let i16 = IntegerType(16, in: &m)

    let t = ArrayType(8, i16, in: &m)
    let u = ArrayType(8, i16, in: &m)
    XCTAssertEqual(t, u)

    let v = ArrayType(16, i16, in: &m)
    XCTAssertNotEqual(t, v)
  }

}
