import SwiftyLLVM
import XCTest

final class ArrayConstantTests: XCTestCase {

  func testInit() {
    var m = Module("foo")
    let i32 = m.integerType(32)

    let a = m.arrayConstant(of: i32, containing: (0 ..< 5).map({ i32.unsafePointee.constant($0).erased }))
    XCTAssertEqual(a.unsafePointee.count, 5)
    XCTAssertEqual(IntegerConstant.Reference(a.unsafePointee[1]), i32.unsafePointee.constant(1))
    XCTAssertEqual(IntegerConstant.Reference(a.unsafePointee[2]), i32.unsafePointee.constant(2))
  }

  func testInitTuple() {
    var m = Module("foo")

    let a = m.arrayConstant(
      of: m.i32,
      containing: (m.i32.unsafePointee.constant(1), m.i32.unsafePointee.constant(2)))

    XCTAssertEqual(a.unsafePointee.count, 2)
    XCTAssertEqual(IntegerConstant.Reference(a.unsafePointee[0]), m.i32.unsafePointee.constant(1))
    XCTAssertEqual(IntegerConstant.Reference(a.unsafePointee[1]), m.i32.unsafePointee.constant(2))
  }

  func testInitFromBytes() {
    var m = Module("foo")

    let i8 = m.integerType(8)
    let a = m.arrayConstant(bytes: [0, 1, 2, 3, 4])
    XCTAssertEqual(a.unsafePointee.count, 5)
    XCTAssertEqual(IntegerConstant.Reference(a.unsafePointee[1]), i8.unsafePointee.constant(1))
    XCTAssertEqual(IntegerConstant.Reference(a.unsafePointee[2]), i8.unsafePointee.constant(2))
  }

  func testEquality() {
    var m = Module("foo")
    let i32 = m.integerType(32)

    let a = m.arrayConstant(of: i32, containing: (0 ..< 5).map({ i32.unsafePointee.constant($0).erased }))
    let b = m.arrayConstant(of: i32, containing: (0 ..< 5).map({ i32.unsafePointee.constant($0).erased }))
    XCTAssertEqual(a, b)

    let c = m.arrayConstant(of: i32, containing: (0 ..< 5).map({ i32.unsafePointee.constant($0 + 1).erased }))
    XCTAssertNotEqual(a, c)
  }

}
