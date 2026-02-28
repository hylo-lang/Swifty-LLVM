import SwiftyLLVM
import XCTest

final class StructTypeTests: XCTestCase {

  func testInlineStruct() {
    var m = Module("foo")
    let t = m.integerType(64)
    let s = m.structType((t, t)).unsafePointee
    XCTAssert(s.isLiteral)
    XCTAssertFalse(s.isPacked)
    XCTAssertFalse(s.isOpaque)
    XCTAssertNil(s.name)
  }

  func testNamedStruct() {
    var m = Module("foo")
    let t = m.integerType(64)
    let s = m.structType(named: "S", (t, t)).unsafePointee
    XCTAssertFalse(s.isLiteral)
    XCTAssertFalse(s.isPacked)
    XCTAssertFalse(s.isOpaque)
    XCTAssertEqual(s.name, "S")
  }

  func testPackedStruct() {
    var m = Module("foo")
    let t = m.integerType(64)
    XCTAssert(m.structType((t, t), packed: true).unsafePointee.isPacked)
    XCTAssert(m.structType(named: "S", (t, t), packed: true).unsafePointee.isPacked)
  }

  func testFields() {
    var m = Module("foo")
    let t = m.integerType(64)
    let u = m.integerType(32)
    
    let s0 = m.structType([])
    XCTAssertEqual(s0.unsafePointee.fields.count, 0)

    let s1 = m.structType((t))
    XCTAssertEqual(s1.unsafePointee.fields.count, 1)
    XCTAssert(s1.unsafePointee.fields[0] == t)

    let s2 = m.structType((t, u))
    XCTAssertEqual(s2.unsafePointee.fields.count, 2)
    XCTAssert(s2.unsafePointee.fields[0] == t)
    XCTAssert(s2.unsafePointee.fields[1] == u)
  }

  func testConversion() {
    var m = Module("foo")
    
    let t = m.structType([])
    XCTAssertNotNil(StructType.Reference(t.erased))

    let u = m.integerType(64)
    XCTAssertNil(StructType.Reference(u.erased))
  }

  func testEquality() {
    var m = Module("foo")
    let t = m.integerType(64)
    let u = m.integerType(32)

    let s0 = m.structType((t, u)).unsafePointee
    let s1 = m.structType((t, u)).unsafePointee
    XCTAssertEqual(s0, s1)
    let s2 = m.structType((u, t)).unsafePointee
    XCTAssertNotEqual(s0, s2)
  }

}
