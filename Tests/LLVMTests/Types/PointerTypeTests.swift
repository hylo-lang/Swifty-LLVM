import LLVM
import XCTest

final class PointerTypeTests: XCTestCase {

  func testDefaultAddressSpace() {
    var m = Module("foo")
    XCTAssertEqual(PointerType(in: &m).addressSpace, .default)
  }

  func testConversion() {
    var m = Module("foo")
    let t: IRType = PointerType(in: &m)
    XCTAssertNotNil(PointerType(t))
    let u: IRType = IntegerType(64, in: &m)
    XCTAssertNil(PointerType(u))
  }

  func testEquality() {
    var m = Module("foo")
    let t = PointerType(in: &m)
    let u = PointerType(in: &m)
    XCTAssertEqual(t, u)
  }

}
