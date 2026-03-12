import XCTest

@testable import SwiftyLLVM

final class StructTypeTests: XCTestCase {

  func testInlineStruct() throws {
    var m = try Module("foo")
    let t = m.integerType(64)
    let s = m.structType((t, t)).unsafe[]
    XCTAssert(s.isLiteral)
    XCTAssertFalse(s.isPacked)
    XCTAssertFalse(s.isOpaque)
    XCTAssertNil(s.name)
  }

  func testNamedStruct() throws {
    var m = try Module("foo")
    let t = m.integerType(64)
    let s = m.structType(named: "S", (t, t)).unsafe[]
    XCTAssertFalse(s.isLiteral)
    XCTAssertFalse(s.isPacked)
    XCTAssertFalse(s.isOpaque)
    XCTAssertEqual(s.name, "S")
  }

  func testPackedStruct() throws {
    var m = try Module("foo")
    let t = m.integerType(64)
    XCTAssert(m.structType((t, t), packed: true).unsafe[].isPacked)
    XCTAssert(m.createStructType(named: "S", [t.erased, t.erased], packed: true).unsafe[].isPacked)
  }

  func testFields() throws {
    var m = try Module("foo")
    let t = m.integerType(64)
    let u = m.integerType(32)

    let s0 = m.structType([])
    XCTAssertEqual(s0.unsafe[].fields.count, 0)

    let s1 = m.structType((t))
    XCTAssertEqual(s1.unsafe[].fields.count, 1)
    XCTAssert(s1.unsafe[].fields[0] == t)

    let s2 = m.structType((t, u))
    XCTAssertEqual(s2.unsafe[].fields.count, 2)
    XCTAssert(s2.unsafe[].fields[0] == t)
    XCTAssert(s2.unsafe[].fields[1] == u)
  }

  func testConversion() throws {
    var m = try Module("foo")

    let t = m.structType([])
    XCTAssertNotNil(StructType.UnsafeReference(t.erased))

    let u = m.integerType(64)
    XCTAssertNil(StructType.UnsafeReference(u.erased))
  }

  func testEquality() throws {
    var m = try Module("foo")
    let t = m.integerType(64)
    let u = m.integerType(32)

    let s0 = m.structType((t, u)).unsafe[]
    let s1 = m.structType((t, u)).unsafe[]
    XCTAssertEqual(s0, s1)
    let s2 = m.structType((u, t)).unsafe[]
    XCTAssertNotEqual(s0, s2)
  }

  func testSameNamedStructTypeEqual() throws {
    var m = try Module("foo")
    let t = m.integerType(64)
    let u = m.integerType(32)

    let s0 = m.structType(named: "S", (t, u)).unsafe[]
    let s1 = m.structType(named: "S", (t, u)).unsafe[]
    XCTAssertEqual(s0, s1)
    XCTAssertEqual(s0.llvm, s1.llvm)
  }

  func testDifferentNameSameFieldsNotEqual() throws {
    var m = try Module("foo")
    let t = m.integerType(64)
    let u = m.integerType(32)

    let s0 = m.structType(named: "S", (t, u)).unsafe[]
    let s1 = m.structType(named: "T", (t, u)).unsafe[]

    XCTAssertNotEqual(s0, s1)
    XCTAssertNotEqual(s0.llvm, s1.llvm)

    XCTAssertEqual(s0.fields[0].erased, t.erased)
    XCTAssertEqual(s0.fields[1].erased, u.erased)

    XCTAssertEqual(s1.fields[0].erased, t.erased)
    XCTAssertEqual(s1.fields[1].erased, u.erased)
  }

  func testSameNameDifferentFields() throws {
    var m = try Module("foo")
    let t = m.integerType(64).erased
    let u = m.integerType(32).erased

    let s0 = m.createStructType(named: "S", [t, u]).unsafe[]
    let s1 = m.createStructType(named: "S", [u, t]).unsafe[]
    XCTAssertNotEqual(s0, s1)

    XCTAssertEqual(s0.fields[0].erased, t.erased)
    XCTAssertEqual(s0.fields[1].erased, u.erased)

    XCTAssertEqual(s1.fields[0].erased, u.erased)
    XCTAssertEqual(s1.fields[1].erased, t.erased)
  }

}
