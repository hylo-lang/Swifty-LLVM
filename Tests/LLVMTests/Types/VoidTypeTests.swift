import SwiftyLLVM
import XCTest

final class VoidTypeTests: XCTestCase {

  func testBitWidth() {
    var m = Module("foo")
    XCTAssertEqual(m.types[m.integerType(64)].bitWidth, 64)
    XCTAssertEqual(m.types[m.integerType(32)].bitWidth, 32)
  }

  func testConversion() {
    var m = Module("foo")
    let t: any IRType = m.types[m.void]
    XCTAssertNotNil(VoidType(t))
    let u: any IRType = m.types[m.integerType(64)]
    XCTAssertNil(VoidType(u))
  }

  func testEquality() {
    var m = Module("foo")
    let t = m.types[m.void]
    let u = m.types[m.void]
    XCTAssertEqual(t, u)
  }

}
