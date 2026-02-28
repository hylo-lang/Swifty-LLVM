import SwiftyLLVM
import XCTest

final class ArrayConstantTests: XCTestCase {

  func testInit() {
    var m = Module("foo")
    let i32 = m.integerType(32)

    let a = m.arrayConstant(of: i32, containing: (0 ..< 5).map({ i32.pointee.constant($0).erased }))
    XCTAssertEqual(a.pointee.count, 5)
    XCTAssertEqual(IntegerConstant.UnsafeReference(a.pointee[1]), i32.pointee.constant(1))
    XCTAssertEqual(IntegerConstant.UnsafeReference(a.pointee[2]), i32.pointee.constant(2))
  }

  func testInitTuple() {
    var m = Module("foo")

    let a = m.arrayConstant(
      of: m.i32,
      containing: (m.i32.pointee.constant(1), m.i32.pointee.constant(2)))

    XCTAssertEqual(a.pointee.count, 2)
    XCTAssertEqual(IntegerConstant.UnsafeReference(a.pointee[0]), m.i32.pointee.constant(1))
    XCTAssertEqual(IntegerConstant.UnsafeReference(a.pointee[1]), m.i32.pointee.constant(2))
  }

  func testInitFromBytes() {
    var m = Module("foo")

    let i8 = m.integerType(8)
    let a = m.arrayConstant(bytes: [0, 1, 2, 3, 4])
    XCTAssertEqual(a.pointee.count, 5)
    XCTAssertEqual(IntegerConstant.UnsafeReference(a.pointee[1]), i8.pointee.constant(1))
    XCTAssertEqual(IntegerConstant.UnsafeReference(a.pointee[2]), i8.pointee.constant(2))
  }

  func testEquality() {
    var m = Module("foo")
    let i32 = m.integerType(32)

    let a = m.arrayConstant(of: i32, containing: (0 ..< 5).map({ i32.pointee.constant($0).erased }))
    let b = m.arrayConstant(of: i32, containing: (0 ..< 5).map({ i32.pointee.constant($0).erased }))
    XCTAssertEqual(a, b)

    let c = m.arrayConstant(of: i32, containing: (0 ..< 5).map({ i32.pointee.constant($0 + 1).erased }))
    XCTAssertNotEqual(a, c)
  }

}
