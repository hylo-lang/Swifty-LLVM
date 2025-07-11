import SwiftyLLVM
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
    let p0 = PointerType(in: &m)
    let f = try XCTUnwrap(m.intrinsic(named: Intrinsic.llvm.va_start, for: [p0]))
    XCTAssertTrue(f.isOverloaded)

    // llvm.smax is overloaded for different integer types.
    let i16 = IntegerType(16, in: &m)
    let g = try XCTUnwrap(m.intrinsic(named: Intrinsic.llvm.smax, for: [i16]))
    XCTAssert(g.isOverloaded)

    // llvm.trap is not overloaded.
    let h = try XCTUnwrap(m.intrinsic(named: Intrinsic.llvm.trap))
    XCTAssertFalse(h.isOverloaded)
  }

  func testName() throws {
    var m = Module("foo")
    let f = try XCTUnwrap(m.intrinsic(named: Intrinsic.llvm.trap, for: []))
    XCTAssertEqual(f.name, "llvm.trap")
  }

  func testEquality() throws {
    var m = Module("foo")
    let p0 = PointerType(in: &m)
    let f = try XCTUnwrap(m.intrinsic(named: Intrinsic.llvm.va_start, for: [p0]))
    let g = try XCTUnwrap(m.intrinsic(named: Intrinsic.llvm.va_start, for: [p0]))
    XCTAssertEqual(f, g)

    let h = try XCTUnwrap(m.intrinsic(named: Intrinsic.llvm.va_end, for: [p0]))
    XCTAssertNotEqual(f, h)
  }

}
