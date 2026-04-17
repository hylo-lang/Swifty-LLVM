import XCTest

@testable import SwiftyLLVM

final class FloatingPointArithmeticTests: XCTestCase {

  func testFAdd() throws {
    var m = try Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: (m.double, m.double), to: m.double))
    let b = m.appendBlock(to: f)
    let l = f.unsafe[].parameters[0]
    let r = f.unsafe[].parameters[1]

    m.insertReturn(m.insertFAdd(l, r, at: m.endOf(b)), at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
  }

  func testFSub() throws {
    var m = try Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: (m.double, m.double), to: m.double))
    let b = m.appendBlock(to: f)
    let l = f.unsafe[].parameters[0]
    let r = f.unsafe[].parameters[1]

    m.insertReturn(m.insertFSub(l, r, at: m.endOf(b)), at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
  }

  func testFMul() throws {
    var m = try Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: (m.double, m.double), to: m.double))
    let b = m.appendBlock(to: f)
    let l = f.unsafe[].parameters[0]
    let r = f.unsafe[].parameters[1]

    m.insertReturn(m.insertFMul(l, r, at: m.endOf(b)), at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
  }

  func testFDiv() throws {
    var m = try Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: (m.double, m.double), to: m.double))
    let b = m.appendBlock(to: f)
    let l = f.unsafe[].parameters[0]
    let r = f.unsafe[].parameters[1]

    m.insertReturn(m.insertFDiv(l, r, at: m.endOf(b)), at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
  }

  func testFRem() throws {
    var m = try Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: (m.double, m.double), to: m.double))
    let b = m.appendBlock(to: f)
    let l = f.unsafe[].parameters[0]
    let r = f.unsafe[].parameters[1]

    m.insertReturn(m.insertFRem(l, r, at: m.endOf(b)), at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
  }

}
