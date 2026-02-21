import XCTest

@testable import SwiftyLLVM

final class IntinsicTests: XCTestCase {

  func testInit() {
    var m = Module("foo")
    XCTAssertNotNil(m.intrinsic(named: IntrinsicFunction.llvm.trap))
    XCTAssertNil(m.intrinsic(named: IntrinsicFunction.llvm.does_not_exist))
  }

  func testIsOverloaded() throws {
    var m = Module("foo")

    // llvm.va_start is overloaded for different address spaces.
    let f = try XCTUnwrap(m.intrinsic(named: IntrinsicFunction.llvm.va_start, for: [m.ptr.erased]))
    XCTAssertTrue(f.unsafePointee.isOverloaded)

    // llvm.smax is overloaded for different integer types.
    let g = try XCTUnwrap(m.intrinsic(named: IntrinsicFunction.llvm.smax, for: [m.i16.erased]))
    XCTAssert(g.unsafePointee.isOverloaded)

    // llvm.trap is not overloaded.
    let h = try XCTUnwrap(m.intrinsic(named: IntrinsicFunction.llvm.trap))
    XCTAssertFalse(h.unsafePointee.isOverloaded)
  }

  func testName() throws {
    var m = Module("foo")
    let f = try XCTUnwrap(m.intrinsic(named: IntrinsicFunction.llvm.trap, for: []))
    XCTAssertEqual(IntrinsicFunction(temporarilyWrapping: f.llvm).name, "llvm.trap")
  }

  func testEquality() throws {
    var m = Module("foo")

    let f = try XCTUnwrap(m.intrinsic(named: IntrinsicFunction.llvm.va_start, for: [m.ptr.erased]))
    let g = try XCTUnwrap(m.intrinsic(named: IntrinsicFunction.llvm.va_start, for: [m.ptr.erased]))
    XCTAssertEqual(f, g)

    let h = try XCTUnwrap(m.intrinsic(named: IntrinsicFunction.llvm.va_end, for: [m.ptr.erased]))
    XCTAssertNotEqual(f, h)
  }

}
