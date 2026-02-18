import SwiftyLLVM
import XCTest

final class IRTypeTests: XCTestCase {

  func testIsSized() {
    var m = Module("foo")
    XCTAssert(m.types[m.integerType(64)].isSized)
    XCTAssertFalse(m.types[m.functionType(from: ())].isSized)
  }

  func testEqualty() {
    var m = Module("foo")
    let t = m.types[m.integerType(64)]
    let u = m.types[m.integerType(32)]

    XCTAssert(t == (t as (any IRType)))
    XCTAssert((t as (any IRType)) == t)
    XCTAssert((t as (any IRType)) == (t as (any IRType)))

    XCTAssert(t != (u as (any IRType)))
    XCTAssert((t as (any IRType)) != u)
    XCTAssert((t as (any IRType)) != (u as (any IRType)))
  }

  func testStringConvertible() {
    var m = Module("foo")
    let t = m.types[m.integerType(64)]
    XCTAssertEqual("\(t)", "\(t)", "Unstable string representation!")
  }

}
