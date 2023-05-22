import LLVM
import XCTest

final class FloatingPointTypeTests: XCTestCase {

  func testConversion() {
    var m = Module("foo")

    let t0: IRType = FloatingPointType.half(in: &m)
    let t1: IRType = FloatingPointType.float(in: &m)
    let t2: IRType = FloatingPointType.double(in: &m)
    let t3: IRType = FloatingPointType.fp128(in: &m)
    for t in [t0, t1, t2, t3] {
      XCTAssertNotNil(FloatingPointType(t))
    }

    let u: IRType = IntegerType(64, in: &m)
    XCTAssertNil(FloatingPointType(u))
  }

  func testCallSyntax() {
    var m = Module("foo")
    let double = FloatingPointType.double(in: &m)
    XCTAssertEqual(double(1).value.value, 1, accuracy: .ulpOfOne)
  }

  func testEquality() {
    var m = Module("foo")
    let t = FloatingPointType.double(in: &m)
    let u = FloatingPointType.double(in: &m)
    XCTAssertEqual(t, u)

    let v = FloatingPointType.float(in: &m)
    XCTAssertNotEqual(t, v)
  }

}
