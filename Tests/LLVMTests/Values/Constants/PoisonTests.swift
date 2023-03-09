import LLVM
import XCTest

final class PoisonTests: XCTestCase {

  func testConversion() {
    var m = Module("foo")
    let t: IRValue = Poison(of: FloatingPointType.float(in: &m))
    XCTAssertNotNil(Poison(t))
    let u: IRValue = IntegerType(64, in: &m).zero
    XCTAssertNil(Poison(u))
  }

  func testEquality() {
    var m = Module("foo")
    let t = Poison(of: FloatingPointType.double(in: &m))
    let u = Poison(of: FloatingPointType.double(in: &m))
    XCTAssertEqual(t, u)

    let v = Poison(of: FloatingPointType.float(in: &m))
    XCTAssertNotEqual(t, v)
  }

}
