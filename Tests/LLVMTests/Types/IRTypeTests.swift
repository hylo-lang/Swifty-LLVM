import SwiftyLLVM
import XCTest

final class IRTypeTests: XCTestCase {

  func testIsSized() {
    var m = Module("foo")
    XCTAssert(m.integerType(64).pointee.isSized)
    XCTAssertFalse(m.functionType(from: ()).pointee.isSized)
  }

  func testEqualty() {
    var m = Module("foo")
    let t = m.integerType(64)
    let u = m.integerType(32)

    XCTAssert(t == t.erased)
    XCTAssert(t.erased == t)
    XCTAssert(t.erased == t.erased)

    XCTAssert(t != u.erased)
    XCTAssert(u.erased != t)
    XCTAssert(t.erased != u.erased)
  }

  func testStringConvertible() {
    var m = Module("foo")
    let t = m.integerType(64).pointee
    XCTAssertEqual("\(t)", "\(t)", "Unstable string representation!")
  }

}
