@testable import SwiftyLLVM
import XCTest

final class IRValueTests: XCTestCase {

  func testName() {
    var m = Module("foo")
    let g = m.declareGlobalVariable("x", m.pointerType())
    XCTAssertEqual(g.pointee.name, "x")
    m.setName("y", for: g)
    XCTAssertEqual(g.pointee.name, "y")
  }

  func testDescription() {
    var m = Module("foo")
    let g = m.declareGlobalVariable("x", m.pointerType())
    XCTAssertEqual(g.pointee.description, "@x = external global ptr")
    m.setName("y", for: g)
    XCTAssertEqual(g.pointee.description, "@y = external global ptr")
  }

  func testIsNull() {
    var m = Module("foo")
    XCTAssert(m.i64.pointee.null.pointee.isNull)
    XCTAssertFalse(m.i64.pointee.constant(42).pointee.isNull)
  }

  func testIsConstant() {
    var m = Module("foo")
    let i64 = m.integerType(64)
    XCTAssert(i64.pointee.null.pointee.isConstant)

    let f = m.declareFunction("fn", m.functionType(from: ()))
    let b = m.appendBlock(to: f)
    let i = m.insertAlloca(i64, at: m.endOf(b)).pointee
    XCTAssertFalse(i.isConstant)
  }

  func testIsTerminator() {
    var m = Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: ()))
    let b = m.appendBlock(to: f)
    let i64 = m.integerType(64)

    let p = m.endOf(b)
    let i = m.insertAlloca(i64, at: p).pointee
    XCTAssertFalse(i.isTerminator)
    let j = m.insertReturn(at: p)
    XCTAssert(j.pointee.isTerminator)
  }

  func testEqualty() {
    var m = Module("foo")
    let t = m.integerType(64).pointee.null
    let u = m.integerType(32).pointee.null

    XCTAssertEqual(t, t.erased)
    XCTAssertEqual(t.erased, t)
    XCTAssertEqual(t.erased, t.erased)

    XCTAssertNotEqual(t, u.erased)
    XCTAssertNotEqual(t.erased, u)
    XCTAssertNotEqual(t.erased, u.erased)
  }

  func testStringConvertible() {
    var m = Module("foo")
    let t = m.integerType(64).pointee.null
    XCTAssertEqual("\(t)", "\(t)", "Unstable string representation!")
  }

}
