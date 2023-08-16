import LLVM
import XCTest

final class ArrayConstantTests: XCTestCase {

  func testInit() {
    var m = Module("foo")
    let i32 = IntegerType(32, in: &m)

    let a = ArrayConstant(
      of: i32, containing: (0 ..< 5).map({ i32.constant($0) }), in: &m)
    XCTAssertEqual(a.count, 5)
    XCTAssertEqual(IntegerConstant(a[1]), i32.constant(1))
    XCTAssertEqual(IntegerConstant(a[2]), i32.constant(2))
  }

  func testInitFromBytes() {
    var m = Module("foo")

    let i8 = IntegerType(8, in: &m)
    let a = ArrayConstant(bytes: [0, 1, 2, 3, 4], in: &m)
    XCTAssertEqual(a.count, 5)
    XCTAssertEqual(IntegerConstant(a[1]), i8.constant(1))
    XCTAssertEqual(IntegerConstant(a[2]), i8.constant(2))
  }

  func testEquality() {
    var m = Module("foo")
    let i32 = IntegerType(32, in: &m)

    let a = ArrayConstant(
      of: i32, containing: (0 ..< 5).map({ i32.constant($0) }), in: &m)
    let b = ArrayConstant(
      of: i32, containing: (0 ..< 5).map({ i32.constant($0) }), in: &m)
    XCTAssertEqual(a, b)

    let c = ArrayConstant(
      of: i32, containing: (0 ..< 5).map({ i32.constant($0 + 1) }), in: &m)
    XCTAssertNotEqual(a, c)
  }

}
