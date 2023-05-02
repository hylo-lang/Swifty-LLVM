import LLVM
import XCTest

final class IntinsicTests: XCTestCase {

  func testInit() {
    var m = Module("foo")
    XCTAssertNotNil(m.intrinsic(named: Intrinsic.llvm.va_start))
    XCTAssertNil(m.intrinsic(named: Intrinsic.llvm.does_not_exist))
  }

  func testIsOverloaded() throws {
    var m = Module("foo")
    let f = try XCTUnwrap(m.intrinsic(named: Intrinsic.llvm.va_start))
    XCTAssertFalse(f.isOverloaded)

    let i16 = IntegerType(16, in: &m)
    let g = try XCTUnwrap(m.intrinsic(named: Intrinsic.llvm.smax, for: [i16]))
    XCTAssert(g.isOverloaded)
  }

  func testName() throws {
    var m = Module("foo")
    let f = try XCTUnwrap(m.intrinsic(named: Intrinsic.llvm.va_start))
    XCTAssertEqual(f.name, "llvm.va_start")
  }

  func testEquality() throws {
    var m = Module("foo")
    let f = try XCTUnwrap(m.intrinsic(named: Intrinsic.llvm.va_start))
    let g = try XCTUnwrap(m.intrinsic(named: Intrinsic.llvm.va_start))
    XCTAssertEqual(f, g)

    let h = try XCTUnwrap(m.intrinsic(named: Intrinsic.llvm.va_end))
    XCTAssertNotEqual(f, h)
  }

}
