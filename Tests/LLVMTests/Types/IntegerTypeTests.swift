@testable import SwiftyLLVM
import XCTest

final class IntegerTypeTests: XCTestCase {

  func testBitWidth() throws {
    var m = try Module("foo")
    let i64 = m.integerType(64)
    let i32 = m.integerType(32)
    XCTAssertEqual(i64.unsafe[].bitWidth, 64)
    XCTAssertEqual(i32.unsafe[].bitWidth, 32)
  }

  func testCallSyntax() throws {
    var m = try Module("foo")
    let i64 = m.integerType(64)
    XCTAssertEqual(i64.unsafe[](1).unsafe[].sext, 1)
  }

  func testConversion() throws {
    var m = try Module("foo")
    
    let i64 = m.integerType(64)
    XCTAssertNotNil(IntegerType.UnsafeReference(i64.erased))

    let float = m.float
    XCTAssertNil(IntegerType.UnsafeReference(float.erased))
  }

  func testEquality() throws {
    var m = try Module("foo")
    let i64 = m.integerType(64)
    let t = i64.unsafe[]
    let u = i64.unsafe[]
    XCTAssertEqual(t, u)

    let i32 = m.integerType(32)
    let v = i32.unsafe[]
    XCTAssertNotEqual(t, v)
  }

}
