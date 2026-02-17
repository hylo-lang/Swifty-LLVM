@testable import SwiftyLLVM
import XCTest

final class PoisonTests: XCTestCase {

  func testConversion() {
    var m = Module("foo")
    let float = FloatingPointType.float(in: &m)
    let t: any IRValue = m.values[Poison.create(of: m.types[float], in: &m)]
    XCTAssertNotNil(Poison(t))
    let i64 = IntegerType.create(64, in: &m)
    let u: any IRValue = m.types[i64].zero
    XCTAssertNil(Poison(u))
  }

  func testEquality() {
    var m = Module("foo")
    let double = FloatingPointType.double(in: &m)
    let t = Poison.create(of: m.types[double], in: &m)
    let u = Poison.create(of: m.types[double], in: &m)
    XCTAssertEqual(t, u)

    let float = FloatingPointType.float(in: &m)
    let v = Poison.create(of: m.types[float], in: &m)
    XCTAssertNotEqual(t, v)
  }

}
