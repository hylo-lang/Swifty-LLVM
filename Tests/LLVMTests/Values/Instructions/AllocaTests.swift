@testable import SwiftyLLVM
import XCTest

final class AllocaTests: XCTestCase {

  func testAllocatedType() throws {
    var m = try Module("foo", targetMachine: .host())
    let f = m.declareFunction("fn", m.functionType(from: []))
    let b = m.appendBlock(to: f)
    let i = m.insertAlloca(m.i64, at: m.endOf(b))
    XCTAssertEqual(i.unsafe[].allocatedType, m.i64.t)
  }

  func testConversion() throws {
    var m = try Module("foo", targetMachine: .host())
    let f = m.declareFunction("fn", m.functionType(from: []))
    let b = m.appendBlock(to: f)

    let i = m.insertAlloca(m.i64, at: m.endOf(b))
    XCTAssertNotNil(Alloca.UnsafeReference(i.v))

    let u = m.i64.unsafe[].zero
    XCTAssertNil(Alloca.UnsafeReference(u.v))
  }

  func testOperands() throws {
    var m = try Module("foo", targetMachine: .host())
    let f = m.declareFunction("fn", m.functionType(from: []))
    let b = m.appendBlock(to: f)

    // There's one operand denoting the number of instances to allocate.
    let i = m.insertAlloca(m.i64, at: m.endOf(b))
    XCTAssertEqual(i.unsafe[].operands.count, 1)
  }

  func testDynamic() throws {
    var m = try Module("foo", targetMachine: .host())
    let f = m.declareFunction("fn", m.functionType(from: []))
    let b = m.appendBlock(to: f)

    let s = m.i16.unsafe[].constant(8)
    let i = m.insertAlloca(arrayOf: s, m.i64, at: m.endOf(b))
    let n = try XCTUnwrap(i.unsafe[].operands.first)
    XCTAssertEqual(IntegerConstant.UnsafeReference(n), m.i16.unsafe[].constant(8))
    XCTAssertEqual(i.unsafe[].allocatedType, m.i64.t)
  }

}
