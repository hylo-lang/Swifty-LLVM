import XCTest

@testable import SwiftyLLVM

final class AtomicRMWBinOpTests: XCTestCase {

  func testLLVMRoundTrip() {
    for op in AtomicRMWBinOp.allCases {
      XCTAssertEqual(AtomicRMWBinOp(llvm: op.llvm), op)
    }
  }

  func testIntegerOperations() throws {
    var m = try Module("foo")

    for op in [AtomicRMWBinOp.xchg, .add, .sub, .and, .nand, .or, .xor, .max, .min, .uMax, .uMin] {
      let f = m.declareFunction("f_\(op)", m.functionType(from: (m.ptr, m.i64), to: m.i64))
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
    var m = try Module("foo")

    for op in [AtomicRMWBinOp.xchg, .fAdd, .fSub, .fMax, .fMin] {
      let f = m.declareFunction("f_\(op)", m.functionType(from: (m.ptr, m.double), to: m.double))
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
