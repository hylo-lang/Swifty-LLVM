import SwiftyLLVM
import XCTest

final class IRTypeTests: XCTestCase {

  func testIsSized() throws {
    var m = try Module("foo", targetMachine: .host())
    XCTAssert(m.integerType(64).unsafe[].isSized)
    XCTAssertFalse(m.functionType(from: ()).unsafe[].isSized)
  }

  func testEqualty() throws {
    var m = try Module("foo", targetMachine: .host())
    let t = m.integerType(64)
    let u = m.integerType(32)

    XCTAssert(t == t.asAnyType)
    XCTAssert(t.asAnyType == t)
    XCTAssert(t.asAnyType == t.asAnyType)

    XCTAssert(t != u.asAnyType)
    XCTAssert(u.asAnyType != t)
    XCTAssert(t.asAnyType != u.asAnyType)
  }

  func testStringConvertible() throws {
    var m = try Module("foo", targetMachine: .host())
    let t = m.integerType(64).unsafe[]
    XCTAssertEqual("\(t)", "\(t)", "Unstable string representation!")
  }

}
