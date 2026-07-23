import XCTest

@testable import SwiftyLLVM

final class FloatingPointArithmeticTests: XCTestCase {

  func testFAdd() throws {
    var m = try Module("foo", targetMachine: .host())
    let f = m.declareFunction("fn", m.functionType(from: [m.double.t, m.double.t], to: m.double.t))
    let b = m.appendBlock(to: f)
    let l = f.unsafe[].parameters[0]
    let r = f.unsafe[].parameters[1]

    m.insertReturn(m.insertFAdd(l, r, at: m.endOf(b)), at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
  }

  func testFSub() throws {
    var m = try Module("foo", targetMachine: .host())
    let f = m.declareFunction("fn", m.functionType(from: [m.double.t, m.double.t], to: m.double.t))
    let b = m.appendBlock(to: f)
    let l = f.unsafe[].parameters[0]
    let r = f.unsafe[].parameters[1]

    m.insertReturn(m.insertFSub(l, r, at: m.endOf(b)), at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
  }

  func testFMul() throws {
    var m = try Module("foo", targetMachine: .host())
    let f = m.declareFunction("fn", m.functionType(from: [m.double.t, m.double.t], to: m.double.t))
    let b = m.appendBlock(to: f)
    let l = f.unsafe[].parameters[0]
    let r = f.unsafe[].parameters[1]

    m.insertReturn(m.insertFMul(l, r, at: m.endOf(b)), at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
  }

  func testFDiv() throws {
    var m = try Module("foo", targetMachine: .host())
    let f = m.declareFunction("fn", m.functionType(from: [m.double.t, m.double.t], to: m.double.t))
    let b = m.appendBlock(to: f)
    let l = f.unsafe[].parameters[0]
    let r = f.unsafe[].parameters[1]

    m.insertReturn(m.insertFDiv(l, r, at: m.endOf(b)), at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
  }

  func testFRem() throws {
    var m = try Module("foo", targetMachine: .host())
    let f = m.declareFunction("fn", m.functionType(from: [m.double.t, m.double.t], to: m.double.t))
    let b = m.appendBlock(to: f)
    let l = f.unsafe[].parameters[0]
    let r = f.unsafe[].parameters[1]

    m.insertReturn(m.insertFRem(l, r, at: m.endOf(b)), at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
  }

  func testFlagsRuntime() throws {
    var m = try Module("foo", targetMachine: .host())
    let f = m.declareFunction("f", m.functionType(from: [m.double.t], to: m.double.t))
    let b = m.appendBlock(to: f)
    let p0 = f.unsafe[].parameters[0]

    let i = m.insertFAdd(p0, p0, at: m.endOf(b))

    XCTAssertEqual(i.unsafe[].fastMathFlags, FastMathFlags())

    m.setFastMathFlags([.afn, .contract], for: i)

    XCTAssertEqual(i.unsafe[].fastMathFlags, [.contract, .afn])
    XCTAssertNotEqual(i.unsafe[].fastMathFlags, .fast)

    m.setFastMathFlags(.fast, for: i)

    XCTAssertEqual(i.unsafe[].fastMathFlags, .fast)

    m.insertReturn(i, at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
  }


  func testFlagsCompileTime() throws {
    var m = try Module("foo", targetMachine: .host())
    let f = m.declareFunction("f", m.functionType(from: []))
    let b = m.appendBlock(to: f)

    let i = m.insertFAdd(
      m.double.unsafe[].constant(1), 
      m.double.unsafe[].constant(1), at: m.endOf(b))
    XCTAssertEqual(i.unsafe[].fastMathFlags, FastMathFlags())

    m.setFastMathFlags([.afn, .contract], for: i)
    XCTAssertEqual(i.unsafe[].fastMathFlags, [])

    m.insertReturn(at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
  }

}
