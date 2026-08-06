import XCTest
import SwiftyLLVM

final class ConversionTests: XCTestCase {

  func testFPToUI() throws {
    var m = try Module("foo", targetMachine: .host())
    let f = m.declareFunction("fn", m.functionType(from: [m.double.t], to: m.i64.t))
    let b = m.appendBlock(to: f)
    let s = f.unsafe[].parameters[0]

    m.insertReturn(m.insertFPToUI(s, to: m.i64, at: m.endOf(b)), at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
    XCTAssert(m.description.contains("fptoui"))
  }

  func testFPToSI() throws {
    var m = try Module("foo", targetMachine: .host())
    let f = m.declareFunction("fn", m.functionType(from: [m.double.t], to: m.i64.t))
    let b = m.appendBlock(to: f)
    let s = f.unsafe[].parameters[0]

    m.insertReturn(m.insertFPToSI(s, to: m.i64, at: m.endOf(b)), at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
    XCTAssert(m.description.contains("fptosi"))
  }

  func testUIToFP() throws {
    var m = try Module("foo", targetMachine: .host())
    let f = m.declareFunction("fn", m.functionType(from: [m.i64.t], to: m.double.t))
    let b = m.appendBlock(to: f)
    let s = f.unsafe[].parameters[0]

    m.insertReturn(m.insertUIToFP(s, to: m.double, at: m.endOf(b)), at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
    XCTAssert(m.description.contains("uitofp"))
  }

  func testSIToFP() throws {
    var m = try Module("foo", targetMachine: .host())
    let f = m.declareFunction("fn", m.functionType(from: [m.i64.t], to: m.double.t))
    let b = m.appendBlock(to: f)
    let s = f.unsafe[].parameters[0]

    m.insertReturn(m.insertSIToFP(s, to: m.double, at: m.endOf(b)), at: m.endOf(b))
    XCTAssertNoThrow(try m.verify())
    XCTAssert(m.description.contains("sitofp"))
  }

}
