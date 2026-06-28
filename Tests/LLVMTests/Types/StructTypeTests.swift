import XCTest

@testable import SwiftyLLVM

final class StructTypeTests: XCTestCase {

  func testInlineStruct() throws {
    var m = try Module("foo", targetMachine: .host())
    let t = m.integerType(64)
    let s = m.structType([t.t, t.t]).unsafe[]
    XCTAssert(s.isLiteral)
    XCTAssertFalse(s.isPacked)
    XCTAssertFalse(s.isOpaque)
    XCTAssertNil(s.name)
  }

  func testNamedStruct() throws {
    var m = try Module("foo", targetMachine: .host())
    let t = m.integerType(64)
    let s = m.structType(named: "S", [t.t, t.t]).unsafe[]
    XCTAssertFalse(s.isLiteral)
    XCTAssertFalse(s.isPacked)
    XCTAssertFalse(s.isOpaque)
    XCTAssertEqual(s.name, "S")
  }

  func testPackedStruct() throws {
    var m = try Module("foo", targetMachine: .host())
    let t = m.integerType(64)
    XCTAssert(m.structType([t.t, t.t], packed: true).unsafe[].isPacked)
    XCTAssert(
      m.createStructType(named: "S", [t.t, t.t], packed: true).unsafe[].isPacked)
  }

  func testOpaqueStruct() throws {
    var m = try Module("foo", targetMachine: .host())
    XCTAssert(m.opaqueStructType(named: "S").unsafe[].isOpaque)
  }

  func testRepeatedCallEquality() throws {
    var m = try Module("foo", targetMachine: .host())
    XCTAssertEqual(m.opaqueStructType(named: "S"), m.opaqueStructType(named: "S"))
    XCTAssertNotEqual(m.opaqueStructType(named: "A"), m.opaqueStructType(named: "B"))
  }

  func testFields() throws {
    var m = try Module("foo", targetMachine: .host())
    let t = m.integerType(64)
    let u = m.integerType(32)

    let s0 = m.structType([])
    XCTAssertEqual(s0.unsafe[].fields.count, 0)

    let s1 = m.structType([t.t])
    XCTAssertEqual(s1.unsafe[].fields.count, 1)
    XCTAssertEqual(s1.unsafe[].fields[0], t.t)

    let s2 = m.structType([t.t, u.t])
    XCTAssertEqual(s2.unsafe[].fields.count, 2)
    XCTAssertEqual(s2.unsafe[].fields[0], t.t)
    XCTAssertEqual(s2.unsafe[].fields[1], u.t)
  }

  func testConversion() throws {
    var m = try Module("foo", targetMachine: .host())

    let t = m.structType([])
    XCTAssertNotNil(StructType.UnsafeReference(t.t))

    let u = m.integerType(64)
    XCTAssertNil(StructType.UnsafeReference(u.t))
  }

  func testEquality() throws {
    var m = try Module("foo", targetMachine: .host())
    let t = m.integerType(64)
    let u = m.integerType(32)

    let s0 = m.structType([t.t, u.t]).unsafe[]
    let s1 = m.structType([t.t, u.t]).unsafe[]
    XCTAssertEqual(s0, s1)
    let s2 = m.structType([u.t, t.t]).unsafe[]
    XCTAssertNotEqual(s0, s2)
  }

  func testSameNamedStructTypeEqual() throws {
    var m = try Module("foo", targetMachine: .host())
    let t = m.integerType(64)
    let u = m.integerType(32)

    let s0 = m.structType(named: "S", [t.t, u.t]).unsafe[]
    let s1 = m.structType(named: "S", [t.t, u.t]).unsafe[]
    XCTAssertEqual(s0, s1)
    XCTAssertEqual(s0.llvm, s1.llvm)
  }

  func testDifferentNameSameFieldsNotEqual() throws {
    var m = try Module("foo", targetMachine: .host())
    let t = m.integerType(64)
    let u = m.integerType(32)

    let s0 = m.structType(named: "S", [t.t, u.t]).unsafe[]
    let s1 = m.structType(named: "T", [t.t, u.t]).unsafe[]

    XCTAssertNotEqual(s0, s1)
    XCTAssertNotEqual(s0.llvm, s1.llvm)

    XCTAssertEqual(s0.fields[0].t, t.t)
    XCTAssertEqual(s0.fields[1].t, u.t)

    XCTAssertEqual(s1.fields[0].t, t.t)
    XCTAssertEqual(s1.fields[1].t, u.t)
  }

  func testSameNameDifferentFields() throws {
    var m = try Module("foo", targetMachine: .host())
    let t = m.integerType(64).t
    let u = m.integerType(32).t

    let s0 = m.createStructType(named: "S", [t, u]).unsafe[]
    let s1 = m.createStructType(named: "S", [u, t]).unsafe[]
    XCTAssertNotEqual(s0, s1)

    XCTAssertEqual(s0.fields[0].t, t.t)
    XCTAssertEqual(s0.fields[1].t, u.t)

    XCTAssertEqual(s1.fields[0].t, u.t)
    XCTAssertEqual(s1.fields[1].t, t.t)
  }

}
