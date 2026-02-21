import SwiftyLLVM
import XCTest

final class IRTypeTests: XCTestCase {

  func testIsSized() {
    var m = Module("foo")
    XCTAssert(m.integerType(64).unsafePointee.isSized)
    XCTAssertFalse(m.functionType(from: ()).unsafePointee.isSized)
  }

  func testEqualty() {
    var m = Module("foo")
    let t = m.integerType(64).unsafePointee
    let u = m.integerType(32).unsafePointee

    XCTAssert(t == (t as (any IRType)))
    XCTAssert((t as (any IRType)) == t)
    XCTAssert((t as (any IRType)) == (t as (any IRType)))

    XCTAssert(t != (u as (any IRType)))
    XCTAssert((t as (any IRType)) != u)
    XCTAssert((t as (any IRType)) != (u as (any IRType)))
  }

  func testStringConvertible() {
    var m = Module("foo")
    let t = m.integerType(64).unsafePointee
    XCTAssertEqual("\(t)", "\(t)", "Unstable string representation!")
  }

}
