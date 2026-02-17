import SwiftyLLVM
import XCTest

final class IRTypeTests: XCTestCase {

  func testIsSized() {
    var m = Module("foo")
    XCTAssert(m.types[IntegerType.create(64, in: &m)].isSized)
    XCTAssertFalse(m.types[FunctionType.create(from: [], in: &m)].isSized)
  }

  func testEqualty() {
    var m = Module("foo")
    let t = m.types[IntegerType.create(64, in: &m)]
    let u = m.types[IntegerType.create(32, in: &m)]

    XCTAssert(t == (t as (any IRType)))
    XCTAssert((t as (any IRType)) == t)
    XCTAssert((t as (any IRType)) == (t as (any IRType)))

    XCTAssert(t != (u as (any IRType)))
    XCTAssert((t as (any IRType)) != u)
    XCTAssert((t as (any IRType)) != (u as (any IRType)))
  }

  func testStringConvertible() {
    var m = Module("foo")
    let t = m.types[IntegerType.create(64, in: &m)]
    XCTAssertEqual("\(t)", "\(t)", "Unstable string representation!")
  }

}
