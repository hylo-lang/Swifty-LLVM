import XCTest

@testable import SwiftyLLVM

final class BitwiseOperationTests: XCTestCase {

  func testBitwiseAnd() throws {
    var m = try Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: (m.i64, m.i64), to: m.i64))
    let b = m.appendBlock(to: f)
    let l = f.unsafe[].parameters[0]
    let r = f.unsafe[].parameters[1]

    m.insertReturn(m.insertBitwiseAnd(l, r, at: m.endOf(b)), at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
  }

  func testBitwiseOr() throws {
    var m = try Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: (m.i64, m.i64), to: m.i64))
    let b = m.appendBlock(to: f)
    let l = f.unsafe[].parameters[0]
    let r = f.unsafe[].parameters[1]

    m.insertReturn(m.insertBitwiseOr(l, r, at: m.endOf(b)), at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
  }

  func testBitwiseXor() throws {
    var m = try Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: (m.i64, m.i64), to: m.i64))
    let b = m.appendBlock(to: f)
    let l = f.unsafe[].parameters[0]
    let r = f.unsafe[].parameters[1]

    m.insertReturn(m.insertBitwiseXor(l, r, at: m.endOf(b)), at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
  }

}
