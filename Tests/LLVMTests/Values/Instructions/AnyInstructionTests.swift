import SwiftyLLVM
import XCTest

final class AnyInstructionTests: XCTestCase {

  func testConversion() throws {
    var m = try Module("foo", targetMachine: .host())
    let f = m.declareFunction("f", m.functionType(from: []))
    let b = m.appendBlock(to: f)

    let i = m.insertAlloca(m.i64, at: m.endOf(b))
    XCTAssertNotNil(AnyInstruction.UnsafeReference(i.erased))

    let u = m.i64.unsafe[].zero
    XCTAssertNil(AnyInstruction.UnsafeReference(u.erased))
  }

  func testEquality() throws {
    var m = try Module("foo", targetMachine: .host())
    let f = m.declareFunction("f", m.functionType(from: []))
    let b = m.appendBlock(to: f)

    let i = m.insertAlloca(m.i64, at: m.endOf(b))
    let j = m.insertAlloca(m.i64, at: m.endOf(b))
    XCTAssertNotEqual(i.instruction, j.instruction)
    XCTAssertEqual(i.instruction, i.instruction)

    XCTAssertEqual(i.instruction.erased, i.erased)
    XCTAssertTrue(i.instruction == i)
    XCTAssertTrue(i.instruction == i.erased)
  }

}
