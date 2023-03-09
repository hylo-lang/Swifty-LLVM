import LLVM
import XCTest

final class StructTypeTests: XCTestCase {

  func testInlineStruct() {
    var m = Module("foo")
    let t = IntegerType(64, in: &m)
    let s = StructType([t, t], in: &m)
    XCTAssert(s.isLiteral)
    XCTAssertFalse(s.isPacked)
    XCTAssertFalse(s.isOpaque)
    XCTAssertNil(s.name)
  }

  func testNamedStruct() {
    var m = Module("foo")
    let t = IntegerType(64, in: &m)
    let s = StructType(named: "S", [t, t], in: &m)
    XCTAssertFalse(s.isLiteral)
    XCTAssertFalse(s.isPacked)
    XCTAssertFalse(s.isOpaque)
    XCTAssertEqual(s.name, "S")
  }

  func testPackedStruct() {
    var m = Module("foo")
    let t = IntegerType(64, in: &m)
    XCTAssert(StructType([t, t], packed: true, in: &m).isPacked)
    XCTAssert(StructType(named: "S", [t, t], packed: true, in: &m).isPacked)
  }

  func testFields() {
    var m = Module("foo")
    let t = IntegerType(64, in: &m)
    let u = IntegerType(32, in: &m)

    let s0 = StructType([], in: &m)
    XCTAssertEqual(s0.fields.count, 0)

    let s1 = StructType([t], in: &m)
    XCTAssertEqual(s1.fields.count, 1)
    XCTAssert(s1.fields[0] == t)

    let s2 = StructType([t, u], in: &m)
    XCTAssertEqual(s2.fields.count, 2)
    XCTAssert(s2.fields[0] == t)
    XCTAssert(s2.fields[1] == u)
  }

  func testConversion() {
    var m = Module("foo")
    let t: IRType = StructType([], in: &m)
    XCTAssertNotNil(StructType(t))
    let u: IRType = IntegerType(64, in: &m)
    XCTAssertNil(StructType(u))
  }

  func testEquality() {
    var m = Module("foo")
    let t = IntegerType(64, in: &m)
    let u = IntegerType(32, in: &m)

    let s0 = StructType([t, u], in: &m)
    let s1 = StructType([t, u], in: &m)
    XCTAssertEqual(s0, s1)

    let s2 = StructType([u, t], in: &m)
    XCTAssertNotEqual(s0, s2)
  }

}
