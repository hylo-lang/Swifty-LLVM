import SwiftyLLVM
import XCTest

final class ArrayConstantTests: XCTestCase {

  func testInit() throws {
    var m = try Module("foo")
    let i32 = m.integerType(32)

    let a = m.arrayConstant(of: i32, containing: (0 ..< 5).map({ i32.unsafe[].constant($0).erased }))
    XCTAssertEqual(a.unsafe[].count, 5)
    XCTAssertEqual(IntegerConstant.UnsafeReference(a.unsafe[][1]), i32.unsafe[].constant(1))
    XCTAssertEqual(IntegerConstant.UnsafeReference(a.unsafe[][2]), i32.unsafe[].constant(2))
  }

  func testInitTuple() throws {
    var m = try Module("foo")

    let a = m.arrayConstant(
      of: m.i32,
      containing: (m.i32.unsafe[].constant(1), m.i32.unsafe[].constant(2)))

    XCTAssertEqual(a.unsafe[].count, 2)
    XCTAssertEqual(IntegerConstant.UnsafeReference(a.unsafe[][0]), m.i32.unsafe[].constant(1))
    XCTAssertEqual(IntegerConstant.UnsafeReference(a.unsafe[][1]), m.i32.unsafe[].constant(2))
  }

  func testInitFromBytes() throws {
    var m = try Module("foo")

    let i8 = m.integerType(8)
    let a = m.arrayConstant(bytes: [0, 1, 2, 3, 4])
    XCTAssertEqual(a.unsafe[].count, 5)
    XCTAssertEqual(IntegerConstant.UnsafeReference(a.unsafe[][1]), i8.unsafe[].constant(1))
    XCTAssertEqual(IntegerConstant.UnsafeReference(a.unsafe[][2]), i8.unsafe[].constant(2))
  }

  func testEquality() throws {
    var m = try Module("foo")
    let i32 = m.integerType(32)

    let a = m.arrayConstant(of: i32, containing: (0 ..< 5).map({ i32.unsafe[].constant($0).erased }))
    let b = m.arrayConstant(of: i32, containing: (0 ..< 5).map({ i32.unsafe[].constant($0).erased }))
    XCTAssertEqual(a, b)

    let c = m.arrayConstant(of: i32, containing: (0 ..< 5).map({ i32.unsafe[].constant($0 + 1).erased }))
    XCTAssertNotEqual(a, c)
  }

}
