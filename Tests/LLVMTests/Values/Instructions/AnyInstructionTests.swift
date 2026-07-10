import SwiftyLLVM
import XCTest

final class AnyInstructionTests: XCTestCase {

  func testConversion() throws {
    var m = try Module("foo", targetMachine: .host())
    let f = m.declareFunction("f", m.functionType(from: []))
    let b = m.appendBlock(to: f)

    let i = m.insertAlloca(m.i64, at: m.endOf(b))
    XCTAssertNotNil(AnyInstruction.UnsafeReference(i.v))

    let u = m.i64.unsafe[].zero
    XCTAssertNil(AnyInstruction.UnsafeReference(u.v))
  }

  func testEquality() throws {
    var m = try Module("foo", targetMachine: .host())
    let f = m.declareFunction("f", m.functionType(from: []))
    let b = m.appendBlock(to: f)

    let i = m.insertAlloca(m.i64, at: m.endOf(b))
    let j = m.insertAlloca(m.i64, at: m.endOf(b))
    XCTAssertNotEqual(i.i, j.i)
    XCTAssertEqual(i.i, i.i)

    XCTAssertEqual(i.i.v, i.v)
    XCTAssertEqual(i.i, i.i)
  }

  func testOperands() throws {
    var m = try Module("foo", targetMachine: .host())
    let f = m.declareFunction("fn", m.functionType(from: []))
    let b = m.appendBlock(to: f)
    let i64 = m.integerType(64)

    let x0 = m.insertAlloca(i64, at: m.endOf(b))
    m.insertStore(i64.unsafe[].constant(123), to: x0, at: m.endOf(b))
    let x1 = m.insertLoad(i64, from: x0, at: m.endOf(b))
    XCTAssertEqual(x1.unsafe[].operands.count, 1)
    XCTAssertEqual(x1.unsafe[].operands.first, x0.v)

    let x2 = m.insertIntegerComparison(.eq, x1, i64.unsafe[].constant(321), at: m.endOf(b))
    XCTAssertEqual(x2.unsafe[].operands.count, 2)
    if x2.unsafe[].operands.count == 2 {
      XCTAssertEqual(x2.unsafe[].operands[0], x1.v)
      XCTAssertNotNil(IntegerConstant.UnsafeReference(x2.unsafe[].operands[1]))
    } else {
      XCTFail("expected 2 operands, found \(x2.unsafe[].operands.count)")
    }
  }

  func testOperandsIndex() throws {
    var m = try Module("foo", targetMachine: .host())
    let n = m.integerType(64)
    let f = m.declareFunction("fn", m.functionType(from: [n.t, n.t]))
    let b = m.appendBlock(to: f)

    let x0 = m.insertIntegerComparison(
      .eq, f.unsafe[].parameters[0].v, f.unsafe[].parameters[1].v, at: m.endOf(b))

    let i = x0.unsafe[].operands.startIndex
    let j = x0.unsafe[].operands.endIndex
    XCTAssertEqual(x0.unsafe[].operands.index(after: i), 1)
    XCTAssertEqual(x0.unsafe[].operands.index(before: j), 1)
  }

}
