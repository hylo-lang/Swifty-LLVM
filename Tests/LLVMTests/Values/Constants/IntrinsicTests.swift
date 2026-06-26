import XCTest

@testable import SwiftyLLVM

final class IntinsicTests: XCTestCase {

  func testInit() throws {
    var m = try Module("foo", targetMachine: .host())
    XCTAssertNotNil(m.intrinsic(named: IntrinsicFunction.llvm.trap))
    XCTAssertNil(m.intrinsic(named: IntrinsicFunction.llvm.does_not_exist))
  }

  func testIsOverloaded() throws {
    var m = try Module("foo", targetMachine: .host())

    // llvm.va_start is overloaded for different address spaces.
    let f = try XCTUnwrap(m.intrinsic(named: IntrinsicFunction.llvm.va_start, for: [m.ptr.t]))
    XCTAssertTrue(f.unsafe[].isOverloaded)

    // llvm.smax is overloaded for different integer types.
    let g = try XCTUnwrap(m.intrinsic(named: IntrinsicFunction.llvm.smax, for: [m.i16.t]))
    XCTAssert(g.unsafe[].isOverloaded)

    // llvm.trap is not overloaded.
    let h = try XCTUnwrap(m.intrinsic(named: IntrinsicFunction.llvm.trap))
    XCTAssertFalse(h.unsafe[].isOverloaded)
  }

  func testName() throws {
    var m = try Module("foo", targetMachine: .host())
    let f = try XCTUnwrap(m.intrinsic(named: IntrinsicFunction.llvm.trap, for: []))
    XCTAssertEqual(IntrinsicFunction(temporarilyWrapping: f.llvm).name, "llvm.trap")
  }

  func testEquality() throws {
    var m = try Module("foo", targetMachine: .host())

    let f = try XCTUnwrap(m.intrinsic(named: IntrinsicFunction.llvm.va_start, for: [m.ptr.t]))
    let g = try XCTUnwrap(m.intrinsic(named: IntrinsicFunction.llvm.va_start, for: [m.ptr.t]))
    XCTAssertEqual(f, g)

    let h = try XCTUnwrap(m.intrinsic(named: IntrinsicFunction.llvm.va_end, for: [m.ptr.t]))
    XCTAssertNotEqual(f, h)
  }

}
