@testable import SwiftyLLVM
import XCTest

final class IntegerTypeTests: XCTestCase {

  func testBitWidth() {
    var m = Module("foo")
    let i64 = m.integerType(64)
    let i32 = m.integerType(32)
    XCTAssertEqual(i64.pointee.bitWidth, 64)
    XCTAssertEqual(i32.pointee.bitWidth, 32)
  }

  func testCallSyntax() {
    var m = Module("foo")
    let i64 = m.integerType(64)
    XCTAssertEqual(i64.pointee(1).pointee.sext, 1)
  }

  func testConversion() {
    var m = Module("foo")
    
    let i64 = m.integerType(64)
    XCTAssertNotNil(IntegerType.UnsafeReference(i64.erased))

    let float = m.float
    XCTAssertNil(IntegerType.UnsafeReference(float.erased))
  }

  func testEquality() {
    var m = Module("foo")
    let i64 = m.integerType(64)
    let t = i64.pointee
    let u = i64.pointee
    XCTAssertEqual(t, u)

    let i32 = m.integerType(32)
    let v = i32.pointee
    XCTAssertNotEqual(t, v)
  }

}
