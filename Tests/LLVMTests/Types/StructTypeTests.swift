import SwiftyLLVM
import XCTest

final class StructTypeTests: XCTestCase {

  func testInlineStruct() {
    var m = Module("foo")
    let t = IntegerType.create(64, in: &m)
    let s = m.types[StructType.create([t.erased, t.erased], in: &m)]
    XCTAssert(s.isLiteral)
    XCTAssertFalse(s.isPacked)
    XCTAssertFalse(s.isOpaque)
    XCTAssertNil(s.name)
  }

  func testNamedStruct() {
    var m = Module("foo")
    let t = IntegerType.create(64, in: &m)
    let s = m.types[StructType.create(named: "S", [t.erased, t.erased], in: &m)]
    XCTAssertFalse(s.isLiteral)
    XCTAssertFalse(s.isPacked)
    XCTAssertFalse(s.isOpaque)
    XCTAssertEqual(s.name, "S")
  }

  func testPackedStruct() {
    var m = Module("foo")
    let t = IntegerType.create(64, in: &m)
    XCTAssert(m.types[StructType.create([t.erased, t.erased], packed: true, in: &m)].isPacked)
    XCTAssert(m.types[StructType.create(named: "S", [t.erased, t.erased], packed: true, in: &m)].isPacked)
  }

  func testFields() {
    var m = Module("foo")
    let t = IntegerType.create(64, in: &m)
    let u = IntegerType.create(32, in: &m)
    let tType = m.types[t]
    let uType = m.types[u]

    let s0 = m.types[StructType.create([], in: &m)]
    XCTAssertEqual(s0.fields.count, 0)

    let s1 = m.types[StructType.create([t.erased], in: &m)]
    XCTAssertEqual(s1.fields.count, 1)
    XCTAssert(s1.fields[0] == tType)

    let s2 = m.types[StructType.create([t.erased, u.erased], in: &m)]
    XCTAssertEqual(s2.fields.count, 2)
    XCTAssert(s2.fields[0] == tType)
    XCTAssert(s2.fields[1] == uType)
  }

  func testConversion() {
    var m = Module("foo")
    let t: any IRType = m.types[StructType.create([], in: &m)]
    XCTAssertNotNil(StructType(t))
    let u: any IRType = m.types[IntegerType.create(64, in: &m)]
    XCTAssertNil(StructType(u))
  }

  func testEquality() {
    var m = Module("foo")
    let t = IntegerType.create(64, in: &m)
    let u = IntegerType.create(32, in: &m)

    let s0 = m.types[StructType.create([t.erased, u.erased], in: &m)]
    let s1 = m.types[StructType.create([t.erased, u.erased], in: &m)]
    XCTAssertEqual(s0, s1)

    let s2 = m.types[StructType.create([u.erased, t.erased], in: &m)]
    XCTAssertNotEqual(s0, s2)
  }

}
