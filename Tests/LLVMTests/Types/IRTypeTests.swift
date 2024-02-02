import SwiftyLLVM
import XCTest

final class IRTypeTests: XCTestCase {

  func testIsSized() {
    var m = Module("foo")
    XCTAssert(IntegerType(64, in: &m).isSized)
    XCTAssertFalse(FunctionType(from: [], in: &m).isSized)
  }

  func testEqualty() {
    var m = Module("foo")
    let t = IntegerType(64, in: &m)
    let u = IntegerType(32, in: &m)

    XCTAssert(t == (t as IRType))
    XCTAssert((t as IRType) == t)
    XCTAssert((t as IRType) == (t as IRType))

    XCTAssert(t != (u as IRType))
    XCTAssert((t as IRType) != u)
    XCTAssert((t as IRType) != (u as IRType))
  }

}
