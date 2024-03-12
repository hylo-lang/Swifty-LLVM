import SwiftyLLVM
import XCTest

final class IRValueTests: XCTestCase {

  func testName() {
    var m = Module("foo")
    let g = m.declareGlobalVariable("x", PointerType(in: &m))
    XCTAssertEqual(g.name, "x")
    m.setName("y", for: g)
    XCTAssertEqual(g.name, "y")
  }

  func testIsNull() {
    var m = Module("foo")
    XCTAssert(IntegerType(64, in: &m).null.isNull)
    XCTAssertFalse(IntegerType(64, in: &m).constant(42).isNull)
  }

  func testIsConstant() {
    var m = Module("foo")
    XCTAssert(IntegerType(64, in: &m).null.isConstant)

    let f = m.declareFunction("fn", .init(from: [], in: &m))
    let b = m.appendBlock(to: f)
    let i = m.insertAlloca(IntegerType(64, in: &m), at: m.endOf(b))
    XCTAssertFalse(i.isConstant)
  }

  func testIsTerminator() {
    var m = Module("foo")
    let f = m.declareFunction("fn", .init(from: [], in: &m))
    let b = m.appendBlock(to: f)

    let p = m.endOf(b)
    let i = m.insertAlloca(IntegerType(64, in: &m), at: p)
    XCTAssertFalse(i.isTerminator)
    let j = m.insertReturn(at: p)
    XCTAssert(j.isTerminator)
  }

  func testEqualty() {
    var m = Module("foo")
    let t = IntegerType(64, in: &m).null
    let u = IntegerType(32, in: &m).null

    XCTAssert(t == (t as IRValue))
    XCTAssert((t as IRValue) == t)
    XCTAssert((t as IRValue) == (t as IRValue))

    XCTAssert(t != (u as IRValue))
    XCTAssert((t as IRValue) != u)
    XCTAssert((t as IRValue) != (u as IRValue))
  }

  func testStringConvertible() {
    var m = Module("foo")
    let t = IntegerType(64, in: &m).null
    XCTAssertEqual("\(t)", "\(t)", "Unstable string representation!")
  }

}
