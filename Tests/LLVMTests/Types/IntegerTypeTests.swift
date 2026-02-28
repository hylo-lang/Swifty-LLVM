@testable import SwiftyLLVM
import XCTest

final class IntegerTypeTests: XCTestCase {

  func testBitWidth() {
    var m = Module("foo")
    let i64 = m.integerType(64)
    let i32 = m.integerType(32)
    XCTAssertEqual(i64.unsafePointee.bitWidth, 64)
    XCTAssertEqual(i32.unsafePointee.bitWidth, 32)
  }

  func testCallSyntax() {
    var m = Module("foo")
    let i64 = m.integerType(64)
    XCTAssertEqual(i64.unsafePointee(1).unsafePointee.sext, 1)
  }

  func testConversion() {
    var m = Module("foo")
    
    let i64 = m.integerType(64)
    XCTAssertNotNil(IntegerType.Reference(i64.erased))

    let float = m.float
    XCTAssertNil(IntegerType.Reference(float.erased))
  }

  func testEquality() {
    var m = Module("foo")
    let i64 = m.integerType(64)
    let t = i64.unsafePointee
    let u = i64.unsafePointee
    XCTAssertEqual(t, u)

    let i32 = m.integerType(32)
    let v = i32.unsafePointee
    XCTAssertNotEqual(t, v)
  }

}
