import SwiftyLLVM
import XCTest

final class StructTypeTests: XCTestCase {

  func testInlineStruct() {
    var m = Module("foo")
    let t = m.integerType(64)
    let s = m.structType([t.erased, t.erased]).unsafePointee
    XCTAssert(s.isLiteral)
    XCTAssertFalse(s.isPacked)
    XCTAssertFalse(s.isOpaque)
    XCTAssertNil(s.name)
  }

  func testNamedStruct() {
    var m = Module("foo")
    let t = m.integerType(64)
    let s = m.structType(named: "S", [t.erased, t.erased]).unsafePointee
    XCTAssertFalse(s.isLiteral)
    XCTAssertFalse(s.isPacked)
    XCTAssertFalse(s.isOpaque)
    XCTAssertEqual(s.name, "S")
  }

  func testPackedStruct() {
    var m = Module("foo")
    let t = m.integerType(64)
    XCTAssert(m.structType([t.erased, t.erased], packed: true).unsafePointee.isPacked)
    XCTAssert(m.structType(named: "S", [t.erased, t.erased], packed: true).unsafePointee.isPacked)
  }

  func testFields() {
    var m = Module("foo")
    let t = m.integerType(64)
    let u = m.integerType(32)
    let tType = t.unsafePointee
    let uType = u.unsafePointee

    let s0 = m.structType([]).unsafePointee
    XCTAssertEqual(s0.fields.count, 0)

    let s1 = m.structType([t.erased]).unsafePointee
    XCTAssertEqual(s1.fields.count, 1)
    XCTAssert(s1.fields[0].unsafePointee == tType)

    let s2 = m.structType([t.erased, u.erased]).unsafePointee
    XCTAssertEqual(s2.fields.count, 2)
    XCTAssert(s2.fields[0].unsafePointee == tType)
    XCTAssert(s2.fields[1].unsafePointee == uType)
  }

  func testConversion() {
    var m = Module("foo")
    let t: any IRType = m.structType([]).unsafePointee
    XCTAssertNotNil(StructType(t))
    let u: any IRType = m.integerType(64).unsafePointee
    XCTAssertNil(StructType(u))
  }

  func testEquality() {
    var m = Module("foo")
    let t = m.integerType(64)
    let u = m.integerType(32)

    let s0 = m.structType([t.erased, u.erased]).unsafePointee
    let s1 = m.structType([t.erased, u.erased]).unsafePointee
    XCTAssertEqual(s0, s1)
    let s2 = m.structType([u.erased, t.erased]).unsafePointee
    XCTAssertNotEqual(s0, s2)
  }

}
