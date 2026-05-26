import SwiftyLLVM
import XCTest

final class VoidTypeTests: XCTestCase {

  func testConversion() throws {
    var m = try Module("foo", targetMachine: .host())

    let t: VoidType.UnsafeReference = m.void
    XCTAssertNotNil(VoidType.UnsafeReference(t.asAnyType))

    let u = m.integerType(64)
    XCTAssertNil(VoidType.UnsafeReference(u.asAnyType))
  }

  func testEquality() throws {
    let m = try Module("foo", targetMachine: .host())
    let t = m.void
    let u = m.void
    XCTAssertEqual(t, u)
  }

}
