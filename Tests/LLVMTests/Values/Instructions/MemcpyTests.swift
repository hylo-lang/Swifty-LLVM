import XCTest
import SwiftyLLVM

final class MemcpyTests: XCTestCase {

  func testMemcpyAlignment() throws {
    for a in [1, 2, 8] {
      var m = try Module("foo", targetMachine: .host())
      let f = m.declareFunction("fn", m.functionType(from: [m.ptr.t, m.ptr.t]))
      let b = m.appendBlock(to: f)

      let target = f.unsafe[].parameters[0]
      let source = f.unsafe[].parameters[1]
      let count = m.i64.unsafe[].constant(64)
      let i = m.insertMemcpy(to: target, from: source, count: count, alignedAt: a, at: m.endOf(b))
      m.insertReturn(at: m.endOf(b))

      XCTAssertNoThrow(try m.verify())

      // Both pointer arguments carry the requested alignment.
      XCTAssertEqual(
        i.unsafe[].description,
        "  call void @llvm.memcpy.p0.p0.i64(ptr align \(a) %0, ptr align \(a) %1, i64 64, i1 false)"
      )
    }
  }

  /// Cortex-M0 has no support for unaligned memory access, so the alignment recorded
  /// by `insertMemcpy` is what tells the backend that the copy may be done word-wise.
  func testMemcpyAlignmentOnCortexM0() throws {
    #if !SWIFTY_LLVM_CROSS_COMPILATION_ENABLED
      throw XCTSkip()
    #else
      let t = try TargetSpecification(target: .init("thumbv6m-none-eabi"))
      var m = Module("foo", targetMachine: .init(target: t))
      let f = m.declareFunction("fn", m.functionType(from: [m.ptr.t, m.ptr.t]))
      let b = m.appendBlock(to: f)

      let target = f.unsafe[].parameters[0]
      let source = f.unsafe[].parameters[1]
      let count = m.i32.unsafe[].constant(16)
      let i = m.insertMemcpy(to: target, from: source, count: count, alignedAt: 4, at: m.endOf(b))
      m.insertReturn(at: m.endOf(b))

      XCTAssertNoThrow(try m.verify())
      XCTAssertEqual(
        i.unsafe[].description,
        "  call void @llvm.memcpy.p0.p0.i32(ptr align 4 %0, ptr align 4 %1, i32 16, i1 false)")
    #endif
  }

}
