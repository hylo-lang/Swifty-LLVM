@testable import SwiftyLLVM
import XCTest

final class IntinsicTests: XCTestCase {

  func testInit() {
    var m = Module("foo")
    XCTAssertNotNil(m.intrinsic(named: Intrinsic.llvm.trap))
    XCTAssertNil(m.intrinsic(named: Intrinsic.llvm.does_not_exist))
  }

  func testIsOverloaded() throws {
    var m = Module("foo")

    // llvm.va_start is overloaded for different address spaces.
    let f = try XCTUnwrap(m.intrinsic(named: Intrinsic.llvm.va_start, for: [m.ptr]))
    XCTAssertTrue(m.values[f].isOverloaded)

    // llvm.smax is overloaded for different integer types.
    let g = try XCTUnwrap(m.intrinsic(named: Intrinsic.llvm.smax, for: [m.i16]))
    XCTAssert(m.values[g].isOverloaded)

    // llvm.trap is not overloaded.
    let h = try XCTUnwrap(m.intrinsic(named: Intrinsic.llvm.trap))
    XCTAssertFalse(m.values[h].isOverloaded)
  }

  func testName() throws {
    var m = Module("foo")
    let f = try XCTUnwrap(m.intrinsic(named: Intrinsic.llvm.trap, for: []))
    XCTAssertEqual(Intrinsic(wrappingTemporarily: m.values[f].llvm).name, "llvm.trap")
  }

  func testEquality() throws {
    var m = Module("foo")
    
    let f = try XCTUnwrap(m.intrinsic(named: Intrinsic.llvm.va_start, for: [m.ptr]))
    let g = try XCTUnwrap(m.intrinsic(named: Intrinsic.llvm.va_start, for: [m.ptr]))
    XCTAssertEqual(f, g)

    let h = try XCTUnwrap(m.intrinsic(named: Intrinsic.llvm.va_end, for: [m.ptr]))
    XCTAssertNotEqual(f, h)
  }

}
