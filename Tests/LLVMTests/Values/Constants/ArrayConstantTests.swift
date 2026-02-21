import SwiftyLLVM
import XCTest

final class ArrayConstantTests: XCTestCase {

  func testInit() {
    var m = Module("foo")
    let i32 = m.integerType(32)

    let a = m.arrayConstant(of: i32, containing: (0 ..< 5).map({ i32.unsafePointee.constant($0).erased }))
    XCTAssertEqual(a.unsafePointee.count, 5)
    XCTAssertEqual(IntegerConstant(a.unsafePointee[1].unsafePointee), i32.unsafePointee.constant(1).unsafePointee)
    XCTAssertEqual(IntegerConstant(a.unsafePointee[2].unsafePointee), i32.unsafePointee.constant(2).unsafePointee)
  }

  func testInitFromBytes() {
    var m = Module("foo")

    let i8 = m.integerType(8)
    let a = m.arrayConstant(bytes: [0, 1, 2, 3, 4])
    XCTAssertEqual(a.unsafePointee.count, 5)
    XCTAssertEqual(IntegerConstant(a.unsafePointee[1].unsafePointee), i8.unsafePointee.constant(1).unsafePointee)
    XCTAssertEqual(IntegerConstant(a.unsafePointee[2].unsafePointee), i8.unsafePointee.constant(2).unsafePointee)
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
