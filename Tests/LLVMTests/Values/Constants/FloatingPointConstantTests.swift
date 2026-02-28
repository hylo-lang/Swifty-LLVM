@testable import SwiftyLLVM
import XCTest

final class FloatingPointConstantTests: XCTestCase {

  func testZero() {
    var m = Module("foo")
    let t = m.double
    let ty = t.pointee
    let x = ty.zero
    XCTAssertEqual(x.pointee.value.value, 0.0, accuracy: .ulpOfOne)
  }

  func testInitWithDouble() {
    var m = Module("foo")
    let t = m.double
    let ty = t.pointee
    let x = ty.constant(4.2)
    XCTAssertEqual(x.pointee.value.value, 4.2, accuracy: .ulpOfOne)
  }

  func testInitWithText() {
    var m = Module("foo")
    let t = m.double
    let ty = t.pointee
    let x = ty.constant(parsing: "4.2")
    XCTAssertEqual(x.pointee.value.value, 4.2, accuracy: .ulpOfOne)
  }

  func testConversion() {
    var m = Module("foo")

    let ft = m.float
    let ty = ft.pointee
    XCTAssertNotNil(FloatingPointConstant.UnsafeReference(ty.zero.erased))
    
    let i64 = m.integerType(64)
    let u = i64.pointee.zero
    XCTAssertNil(FloatingPointConstant.UnsafeReference(u.erased))
  }

  func testEquality() {
    var m = Module("foo")
    let ty = m.double
    let double = ty.pointee

    let t = double.zero
    let u = double.zero
    XCTAssertEqual(t, u)

    let v = double.constant(4.2)
    XCTAssertNotEqual(t, v)
  }

}
