import SwiftyLLVM
import XCTest

final class IRTypeTests: XCTestCase {

  func testIsSized() throws {
    var m = try Module("foo")
    XCTAssert(m.integerType(64).unsafe[].isSized)
    XCTAssertFalse(m.functionType(from: ()).unsafe[].isSized)
  }

  func testEqualty() throws {
    var m = try Module("foo")
    let t = m.integerType(64)
    let u = m.integerType(32)

    XCTAssert(t == t.erased)
    XCTAssert(t.erased == t)
    XCTAssert(t.erased == t.erased)

    XCTAssert(t != u.erased)
    XCTAssert(u.erased != t)
    XCTAssert(t.erased != u.erased)
  }

  func testStringConvertible() throws {
    var m = try Module("foo")
    let t = m.integerType(64).unsafe[]
    XCTAssertEqual("\(t)", "\(t)", "Unstable string representation!")
  }

}
