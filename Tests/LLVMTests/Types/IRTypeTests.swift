import SwiftyLLVM
import XCTest

final class IRTypeTests: XCTestCase {

  func testIsSized() throws {
    var m = try Module("foo", targetMachine: .host())
    XCTAssert(m.integerType(64).unsafe[].isSized)
    XCTAssertFalse(m.functionType(from: []).unsafe[].isSized)
  }

  func testEqualty() throws {
    var m = try Module("foo", targetMachine: .host())
    let t = m.integerType(64)
    let u = m.integerType(32)

    XCTAssertEqual(t.t, t.t)
    XCTAssertEqual(t, t)
    XCTAssertNotEqual(t.t, u.t)
  }

  func testStringConvertible() throws {
    var m = try Module("foo", targetMachine: .host())
    let t = m.integerType(64).unsafe[]
    XCTAssertEqual("\(t)", "\(t)", "Unstable string representation!")
  }

}
