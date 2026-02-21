@testable import SwiftyLLVM
import XCTest

final class FloatingPointConstantTests: XCTestCase {

  func testZero() {
    var m = Module("foo")
    let t = m.double
    let ty = t.unsafePointee
    let x = ty.zero
    XCTAssertEqual(x.unsafePointee.value.value, 0.0, accuracy: .ulpOfOne)
  }

  func testInitWithDouble() {
    var m = Module("foo")
    let t = m.double
    let ty = t.unsafePointee
    let x = ty.constant(4.2)
    XCTAssertEqual(x.unsafePointee.value.value, 4.2, accuracy: .ulpOfOne)
  }

  func testInitWithText() {
    var m = Module("foo")
    let t = m.double
    let ty = t.unsafePointee
    let x = ty.constant(parsing: "4.2")
    XCTAssertEqual(x.unsafePointee.value.value, 4.2, accuracy: .ulpOfOne)
  }

  func testConversion() {
    var m = Module("foo")
    let ft = m.float
    let ty = ft.unsafePointee
    let t: any IRValue = ty.zero.unsafePointee
    XCTAssertNotNil(FloatingPointConstant(t))
    let i64 = m.integerType(64)
    let u: any IRValue = i64.unsafePointee.zero.unsafePointee
    XCTAssertNil(FloatingPointConstant(u))
  }

  func testEquality() {
    var m = Module("foo")
    let ty = m.double
    let tType = ty.unsafePointee
    let t = tType.zero
    let u = tType.zero
    XCTAssertEqual(t.unsafePointee, u.unsafePointee)

    let v = tType.constant(4.2)
    XCTAssertNotEqual(t.unsafePointee, v.unsafePointee)
  }

}
