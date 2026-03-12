@testable import SwiftyLLVM
import XCTest

final class IRValueTests: XCTestCase {

  func testName() throws {
    var m = try Module("foo")
    let g = m.declareGlobalVariable("x", m.pointerType())
    XCTAssertEqual(g.unsafe[].name, "x")
    m.setName("y", for: g)
    XCTAssertEqual(g.unsafe[].name, "y")
  }

  func testDescription() throws {
    var m = try Module("foo")
    let g = m.declareGlobalVariable("x", m.pointerType())
    XCTAssertEqual(g.unsafe[].description, "@x = external global ptr")
    m.setName("y", for: g)
    XCTAssertEqual(g.unsafe[].description, "@y = external global ptr")
  }

  func testIsNull() throws {
    var m = try Module("foo")
    XCTAssert(m.i64.unsafe[].null.unsafe[].isNull)
    XCTAssertFalse(m.i64.unsafe[].constant(42).unsafe[].isNull)
  }

  func testIsConstant() throws {
    var m = try Module("foo")
    let i64 = m.integerType(64)
    XCTAssert(i64.unsafe[].null.unsafe[].isConstant)

    let f = m.declareFunction("fn", m.functionType(from: ()))
    let b = m.appendBlock(to: f)
    let i = m.insertAlloca(i64, at: m.endOf(b)).unsafe[]
    XCTAssertFalse(i.isConstant)
  }

  func testIsTerminator() throws {
    var m = try Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: ()))
    let b = m.appendBlock(to: f)
    let i64 = m.integerType(64)

    let p = m.endOf(b)
    let i = m.insertAlloca(i64, at: p).unsafe[]
    XCTAssertFalse(i.isTerminator)
    let j = m.insertReturn(at: p)
    XCTAssert(j.unsafe[].isTerminator)
  }

  func testEqualty() throws {
    var m = try Module("foo")
    let t = m.integerType(64).unsafe[].null
    let u = m.integerType(32).unsafe[].null

    XCTAssertEqual(t, t.erased)
    XCTAssertEqual(t.erased, t)
    XCTAssertEqual(t.erased, t.erased)

    XCTAssertNotEqual(t, u.erased)
    XCTAssertNotEqual(t.erased, u)
    XCTAssertNotEqual(t.erased, u.erased)
  }

  func testStringConvertible() throws {
    var m = try Module("foo")
    let t = m.integerType(64).unsafe[].null
    XCTAssertEqual("\(t)", "\(t)", "Unstable string representation!")
  }

}
