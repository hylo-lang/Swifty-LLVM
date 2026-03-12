@testable import SwiftyLLVM
import XCTest

final class FloatingPointConstantTests: XCTestCase {

  func testZero() throws {
    var m = try Module("foo")
    let t = m.double
    let ty = t.unsafe[]
    let x = ty.zero
    XCTAssertEqual(x.unsafe[].value.value, 0.0, accuracy: .ulpOfOne)
  }

  func testInitWithDouble() throws {
    var m = try Module("foo")
    let t = m.double
    let ty = t.unsafe[]
    let x = ty.constant(4.2)
    XCTAssertEqual(x.unsafe[].value.value, 4.2, accuracy: .ulpOfOne)
  }

  func testInitWithText() throws {
    var m = try Module("foo")
    let t = m.double
    let ty = t.unsafe[]
    let x = ty.constant(parsing: "4.2")
    XCTAssertEqual(x.unsafe[].value.value, 4.2, accuracy: .ulpOfOne)
  }

  func testConversion() throws {
    var m = try Module("foo")

    let ft = m.float
    let ty = ft.unsafe[]
    XCTAssertNotNil(FloatingPointConstant.UnsafeReference(ty.zero.erased))
    
    let i64 = m.integerType(64)
    let u = i64.unsafe[].zero
    XCTAssertNil(FloatingPointConstant.UnsafeReference(u.erased))
  }

  func testEquality() throws {
    var m = try Module("foo")
    let ty = m.double
    let double = ty.unsafe[]

    let t = double.zero
    let u = double.zero
    XCTAssertEqual(t, u)

    let v = double.constant(4.2)
    XCTAssertNotEqual(t, v)
  }

}
