import SwiftyLLVM
import XCTest

final class StructConstantTests: XCTestCase {

  func testInitNamed() {
    var m = Module("foo")
    let i32 = m.integerType(32)

    let t = m.structType((i32, i32))
    let a = m.structConstant(
      of: t, aggregating: (i32.unsafePointee.constant(4), i32.unsafePointee.constant(2)))
    XCTAssertEqual(a.unsafePointee.count, 2)
    XCTAssertEqual(StructType.Reference(a.unsafePointee.type), t)
    XCTAssertEqual(IntegerConstant.Reference(a.unsafePointee[0]), i32.unsafePointee.constant(4))
    XCTAssertEqual(IntegerConstant.Reference(a.unsafePointee[1]), i32.unsafePointee.constant(2))
  }

  func testInitFromValues() throws {
    var m = Module("foo")
    let i32 = m.integerType(32)
    
    let a = m.structConstant(aggregating: (i32.unsafePointee.constant(4), i32.unsafePointee.constant(2)))
    XCTAssertEqual(a.unsafePointee.count, 2)
    XCTAssertEqual(try XCTUnwrap(StructType.Reference(a.unsafePointee.type)).unsafePointee.isPacked, false)
    XCTAssertEqual(IntegerConstant.Reference(a.unsafePointee[0]), i32.unsafePointee.constant(4))
    XCTAssertEqual(IntegerConstant.Reference(a.unsafePointee[1]), i32.unsafePointee.constant(2))
  }

  func testInitFromValuesPacked() throws {
    var m = Module("foo")
    let i32 = m.integerType(32)
    
    let a = m.structConstant(aggregating: (i32.unsafePointee.constant(4), i32.unsafePointee.constant(2)), packed: true)
    XCTAssertEqual(a.unsafePointee.count, 2)
    XCTAssertEqual(try XCTUnwrap(StructType.Reference(a.unsafePointee.type)).unsafePointee.isPacked, true)
    XCTAssertEqual(IntegerConstant.Reference(a.unsafePointee[0]), i32.unsafePointee.constant(4))
    XCTAssertEqual(IntegerConstant.Reference(a.unsafePointee[1]), i32.unsafePointee.constant(2))
  }

  func testEquality() {
    var m = Module("foo")
    let i32 = m.integerType(32)
    
    let a = m.structConstant(aggregating: (i32.unsafePointee.constant(4), i32.unsafePointee.constant(2)))
    let b = m.structConstant(aggregating: (i32.unsafePointee.constant(4), i32.unsafePointee.constant(2)))
    XCTAssertEqual(a, b)

    let c = m.structConstant(aggregating: (i32.unsafePointee.constant(2), i32.unsafePointee.constant(4)))
    XCTAssertNotEqual(a, c)
  }

}
