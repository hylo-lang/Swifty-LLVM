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
    let f = try XCTUnwrap(m.intrinsic(named: IntrinsicFunction.llvm.va_start, for: (m.ptr)))
    XCTAssertTrue(f.pointee.isOverloaded)

    // llvm.smax is overloaded for different integer types.
    let g = try XCTUnwrap(m.intrinsic(named: IntrinsicFunction.llvm.smax, for: (m.i16)))
    XCTAssert(g.pointee.isOverloaded)

    // llvm.trap is not overloaded.
    let h = try XCTUnwrap(m.intrinsic(named: IntrinsicFunction.llvm.trap))
    XCTAssertFalse(h.pointee.isOverloaded)
  }

  func testName() throws {
    var m = Module("foo")
    let f = try XCTUnwrap(m.intrinsic(named: IntrinsicFunction.llvm.trap, for: []))
    XCTAssertEqual(IntrinsicFunction(temporarilyWrapping: f.llvm).name, "llvm.trap")
  }

  func testEquality() throws {
    var m = Module("foo")

    let f = try XCTUnwrap(m.intrinsic(named: IntrinsicFunction.llvm.va_start, for: (m.ptr)))
    let g = try XCTUnwrap(m.intrinsic(named: IntrinsicFunction.llvm.va_start, for: (m.ptr)))
    XCTAssertEqual(f, g)

    let h = try XCTUnwrap(m.intrinsic(named: IntrinsicFunction.llvm.va_end, for: (m.ptr)))
    XCTAssertNotEqual(f, h)
  }

}
