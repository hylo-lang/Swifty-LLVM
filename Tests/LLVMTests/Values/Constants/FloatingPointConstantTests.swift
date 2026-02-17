@testable import SwiftyLLVM
import XCTest

final class FloatingPointConstantTests: XCTestCase {

  func testZero() {
    var m = Module("foo")
    let t = FloatingPointType.double(in: &m)
    let ty = m.types[t]
    let x = ty.zero(in: &m)
    XCTAssertEqual(m.values[x].value.value, 0.0, accuracy: .ulpOfOne)
  }

  func testInitWithDouble() {
    var m = Module("foo")
    let t = FloatingPointType.double(in: &m)
    let ty = m.types[t]
    let x = ty.constant(4.2, in: &m)
    XCTAssertEqual(m.values[x].value.value, 4.2, accuracy: .ulpOfOne)
  }

  func testInitWithText() {
    var m = Module("foo")
    let t = FloatingPointType.double(in: &m)
    let ty = m.types[t]
    let x = ty.constant(parsing: "4.2", in: &m)
    XCTAssertEqual(m.values[x].value.value, 4.2, accuracy: .ulpOfOne)
  }

  func testConversion() {
    var m = Module("foo")
    let ft = FloatingPointType.float(in: &m)
    let ty = m.types[ft]
    let t: any IRValue = m.values[ty.zero(in: &m)]
    XCTAssertNotNil(FloatingPointConstant(t))
    let i64 = m.integerType(64)
    let u: any IRValue = m.types[i64].zero
    XCTAssertNil(FloatingPointConstant(u))
  }

  func testEquality() {
    var m = Module("foo")
    let ty = FloatingPointType.double(in: &m)
    let tType = m.types[ty]
    let t = tType.zero(in: &m)
    let u = tType.zero(in: &m)
    XCTAssertEqual(m.values[t], m.values[u])

    let v = tType.constant(4.2, in: &m)
    XCTAssertNotEqual(m.values[t], m.values[v])
  }

}
