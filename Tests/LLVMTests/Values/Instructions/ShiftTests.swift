import XCTest

@testable import SwiftyLLVM

final class ShiftTests: XCTestCase {

  func testShl() throws {
    var m = try Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: (m.i64, m.i64), to: m.i64))
    let b = m.appendBlock(to: f)
    let l = f.unsafe[].parameters[0]
    let r = f.unsafe[].parameters[1]

    m.insertReturn(m.insertShl(l, r, at: m.endOf(b)), at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
  }

  func testLShr() throws {
    var m = try Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: (m.i64, m.i64), to: m.i64))
    let b = m.appendBlock(to: f)
    let l = f.unsafe[].parameters[0]
    let r = f.unsafe[].parameters[1]

    m.insertReturn(m.insertLShr(l, r, at: m.endOf(b)), at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
  }

  func testAShr() throws {
    var m = try Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: (m.i64, m.i64), to: m.i64))
    let b = m.appendBlock(to: f)
    let l = f.unsafe[].parameters[0]
    let r = f.unsafe[].parameters[1]

    m.insertReturn(m.insertAShr(l, r, at: m.endOf(b)), at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
  }

}
