import LLVM
import XCTest

final class VoidTypeTests: XCTestCase {

  func testBitWidth() {
    var m = Module("foo")
    XCTAssertEqual(IntegerType(64, in: &m).bitWidth, 64)
    XCTAssertEqual(IntegerType(32, in: &m).bitWidth, 32)
  }

  func testConversion() {
    var m = Module("foo")
    let t: IRType = VoidType(in: &m)
    XCTAssertNotNil(VoidType(t))
    let u: IRType = IntegerType(64, in: &m)
    XCTAssertNil(VoidType(u))
  }

  func testEquality() {
    var m = Module("foo")
    let t = VoidType(in: &m)
    let u = VoidType(in: &m)
    XCTAssertEqual(t, u)
  }

}
