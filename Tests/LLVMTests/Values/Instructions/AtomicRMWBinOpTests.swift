import XCTest

@testable import SwiftyLLVM

final class AtomicRMWBinOpTests: XCTestCase {

  func testLLVMRoundTrip() {
    for op in AtomicRMWBinOp.allCases {
      XCTAssertEqual(AtomicRMWBinOp(llvm: op.llvm), op)
    }
  }

  func testIntegerOperations() throws {
    var m = try Module("foo", targetMachine: .host())

    for op in [AtomicRMWBinOp.xchg, .add, .sub, .and, .nand, .or, .xor, .max, .min, .uMax, .uMin] {
      let f = m.declareFunction("f_\(op)", m.functionType(from: [m.ptr.t, m.i64.t], to: m.i64.t))
      let b = m.appendBlock(to: f)
      let a = f.unsafe[].parameters[0]
      let v = f.unsafe[].parameters[1]
      let r = m.insertAtomicRMW(
        a, operation: op, value: v, ordering: .monotonic, singleThread: false, at: m.endOf(b))
      m.insertReturn(r, at: m.endOf(b))
    }

    XCTAssertNoThrow(try m.verify())
  }

  func testFloatingPointOperations() throws {
    var m = try Module("foo", targetMachine: .host())

    for op in [AtomicRMWBinOp.xchg, .fAdd, .fSub, .fMax, .fMin] {
      let f = m.declareFunction(
        "f_\(op)", m.functionType(from: [m.ptr.t, m.double.t], to: m.double.t))
      let b = m.appendBlock(to: f)
      let a = f.unsafe[].parameters[0]
      let v = f.unsafe[].parameters[1]
      let r = m.insertAtomicRMW(
        a, operation: op, value: v, ordering: .monotonic, singleThread: false, at: m.endOf(b))
      m.insertReturn(r, at: m.endOf(b))
    }

    XCTAssertNoThrow(try m.verify())
  }

}
