import SwiftyLLVM
import XCTest

final class StructTypeTests: XCTestCase {

  func testInlineStruct() {
    var m = Module("foo")
    let t = m.integerType(64)
    let s = m.types[m.structType([t.erased, t.erased])]
    XCTAssert(s.isLiteral)
    XCTAssertFalse(s.isPacked)
    XCTAssertFalse(s.isOpaque)
    XCTAssertNil(s.name)
  }

  func testNamedStruct() {
    var m = Module("foo")
    let t = m.integerType(64)
    let s = m.types[m.structType(named: "S", [t.erased, t.erased])]
    XCTAssertFalse(s.isLiteral)
    XCTAssertFalse(s.isPacked)
    XCTAssertFalse(s.isOpaque)
    XCTAssertEqual(s.name, "S")
  }

  func testPackedStruct() {
    var m = Module("foo")
    let t = m.integerType(64)
    XCTAssert(m.types[m.structType([t.erased, t.erased], packed: true)].isPacked)
    XCTAssert(m.types[m.structType(named: "S", [t.erased, t.erased], packed: true)].isPacked)
  }

  func testFields() {
    var m = Module("foo")
    let t = m.integerType(64)
    let u = m.integerType(32)
    let tType = m.types[t]
    let uType = m.types[u]

    let s0 = m.types[m.structType([])]
    XCTAssertEqual(s0.fields.count, 0)

    let s1 = m.types[m.structType([t.erased])]
    XCTAssertEqual(s1.fields.count, 1)
    XCTAssert(s1.fields[0] == tType)

    let s2 = m.types[m.structType([t.erased, u.erased])]
    XCTAssertEqual(s2.fields.count, 2)
    XCTAssert(s2.fields[0] == tType)
    XCTAssert(s2.fields[1] == uType)
  }

  func testConversion() {
    var m = Module("foo")
    let t: any IRType = m.types[m.structType([])]
    XCTAssertNotNil(StructType(t))
    let u: any IRType = m.types[m.integerType(64)]
    XCTAssertNil(StructType(u))
  }

  func testEquality() {
    var m = Module("foo")
    let t = m.integerType(64)
    let u = m.integerType(32)

    let s0 = m.types[m.structType([t.erased, u.erased])]
    let s1 = m.types[m.structType([t.erased, u.erased])]
    XCTAssertEqual(s0, s1)
    let s2 = m.types[m.structType([u.erased, t.erased])]
    XCTAssertNotEqual(s0, s2)
  }

}
