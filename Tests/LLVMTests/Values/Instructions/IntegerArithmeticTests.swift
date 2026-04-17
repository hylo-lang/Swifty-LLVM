import XCTest

@testable import SwiftyLLVM

final class IntegerArithmeticTests: XCTestCase {

  func testIntegerAdd() throws {
    var m = try Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: (m.i64, m.i64), to: m.i64))
    let b = m.appendBlock(to: f)
    let l = f.unsafe[].parameters[0]
    let r = f.unsafe[].parameters[1]

    let x0 = m.insertAdd(l, r, at: m.endOf(b))
    let x1 = m.insertAdd(overflow: .nuw, x0, r, at: m.endOf(b))
    let x2 = m.insertAdd(overflow: .nsw, x1, r, at: m.endOf(b))
    m.insertReturn(x2, at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
  }

  func testIntegerSub() throws {
    var m = try Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: (m.i64, m.i64), to: m.i64))
    let b = m.appendBlock(to: f)
    let l = f.unsafe[].parameters[0]
    let r = f.unsafe[].parameters[1]

    let x0 = m.insertSub(l, r, at: m.endOf(b))
    let x1 = m.insertSub(overflow: .nuw, x0, r, at: m.endOf(b))
    let x2 = m.insertSub(overflow: .nsw, x1, r, at: m.endOf(b))
    m.insertReturn(x2, at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
  }

  func testIntegerMul() throws {
    var m = try Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: (m.i64, m.i64), to: m.i64))
    let b = m.appendBlock(to: f)
    let l = f.unsafe[].parameters[0]
    let r = f.unsafe[].parameters[1]

    let x0 = m.insertMul(l, r, at: m.endOf(b))
    let x1 = m.insertMul(overflow: .nuw, x0, r, at: m.endOf(b))
    let x2 = m.insertMul(overflow: .nsw, x1, r, at: m.endOf(b))
    m.insertReturn(x2, at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
  }

  func testUnsignedDiv() throws {
    var m = try Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: (m.i64, m.i64), to: m.i64))
    let b = m.appendBlock(to: f)
    let l = f.unsafe[].parameters[0]
    let r = f.unsafe[].parameters[1]

    let x0 = m.insertUnsignedDiv(l, r, at: m.endOf(b))
    let x1 = m.insertUnsignedDiv(exact: true, x0, r, at: m.endOf(b))
    m.insertReturn(x1, at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
  }

  func testSignedDiv() throws {
    var m = try Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: (m.i64, m.i64), to: m.i64))
    let b = m.appendBlock(to: f)
    let l = f.unsafe[].parameters[0]
    let r = f.unsafe[].parameters[1]

    let x0 = m.insertSignedDiv(l, r, at: m.endOf(b))
    let x1 = m.insertSignedDiv(exact: true, x0, r, at: m.endOf(b))
    m.insertReturn(x1, at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
  }

  func testUnsignedRem() throws {
    var m = try Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: (m.i64, m.i64), to: m.i64))
    let b = m.appendBlock(to: f)
    let l = f.unsafe[].parameters[0]
    let r = f.unsafe[].parameters[1]

    m.insertReturn(m.insertUnsignedRem(l, r, at: m.endOf(b)), at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
  }

  func testSignedRem() throws {
    var m = try Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: (m.i64, m.i64), to: m.i64))
    let b = m.appendBlock(to: f)
    let l = f.unsafe[].parameters[0]
    let r = f.unsafe[].parameters[1]

    m.insertReturn(m.insertSignedRem(l, r, at: m.endOf(b)), at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
  }

}
