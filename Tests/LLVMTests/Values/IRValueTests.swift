@testable import SwiftyLLVM
import XCTest

final class IRValueTests: XCTestCase {

  func testName() {
    var m = Module("foo")
    let g = m.declareGlobalVariable("x", PointerType.create(in: &m))
    XCTAssertEqual(m.values[g].name, "x")
    m.setName("y", for: g)
    XCTAssertEqual(m.values[g].name, "y")
  }

  func testIsNull() {
    var m = Module("foo")
    let i64 = m.types[IntegerType.create(64, in: &m)]
    XCTAssert(i64.null.isNull)
    XCTAssertFalse(i64.constant(42).isNull)
  }

  func testIsConstant() {
    var m = Module("foo")
    let i64 = IntegerType.create(64, in: &m)
    XCTAssert(m.types[i64].null.isConstant)

    let f = m.declareFunction("fn", FunctionType.create(from: [], in: &m))
    let b = m.appendBlock(to: f)
    let i = m.insertAlloca(i64, at: m.endOf(b))
    XCTAssertFalse(i.isConstant)
  }

  func testIsTerminator() {
    var m = Module("foo")
    let f = m.declareFunction("fn", FunctionType.create(from: [], in: &m))
    let b = m.appendBlock(to: f)
    let i64 = IntegerType.create(64, in: &m)

    let p = m.endOf(b)
    let i = m.insertAlloca(i64, at: p)
    XCTAssertFalse(i.isTerminator)
    let j = m.insertReturn(at: p)
    XCTAssert(m.values[j].isTerminator)
  }

  func testEqualty() {
    var m = Module("foo")
    let t = m.types[IntegerType.create(64, in: &m)].null
    let u = m.types[IntegerType.create(32, in: &m)].null

    XCTAssert(t == (t as any IRValue))
    XCTAssert((t as any IRValue) == t)
    XCTAssert((t as any IRValue) == (t as any IRValue))

    XCTAssert(t != (u as any IRValue))
    XCTAssert((t as any IRValue) != u)
    XCTAssert((t as any IRValue) != (u as any IRValue))
  }

  func testStringConvertible() {
    var m = Module("foo")
    let t = m.types[IntegerType.create(64, in: &m)].null
    XCTAssertEqual("\(t)", "\(t)", "Unstable string representation!")
  }

}
