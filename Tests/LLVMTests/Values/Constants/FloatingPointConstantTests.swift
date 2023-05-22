import LLVM
import XCTest

final class FloatingPointConstantTests: XCTestCase {

  func testZero() {
    var m = Module("foo")
    let x = FloatingPointType.double(in: &m).zero
    XCTAssertEqual(x.value.value, 0.0, accuracy: .ulpOfOne)
  }

  func testInitWithDouble() {
    var m = Module("foo")
    let x = FloatingPointType.double(in: &m).constant(4.2)
    XCTAssertEqual(x.value.value, 4.2, accuracy: .ulpOfOne)
  }

  func testInitWithText() {
    var m = Module("foo")
    let x = FloatingPointType.double(in: &m).constant(parsing: "4.2")
    XCTAssertEqual(x.value.value, 4.2, accuracy: .ulpOfOne)
  }

  func testConversion() {
    var m = Module("foo")
    let t: IRValue = FloatingPointType.float(in: &m).zero
    XCTAssertNotNil(FloatingPointConstant(t))
    let u: IRValue = IntegerType(64, in: &m).zero
    XCTAssertNil(FloatingPointConstant(u))
  }

  func testEquality() {
    var m = Module("foo")
    let t = FloatingPointType.double(in: &m).zero
    let u = FloatingPointType.double(in: &m).zero
    XCTAssertEqual(t, u)

    let v = FloatingPointType.double(in: &m).constant(4.2)
    XCTAssertNotEqual(t, v)
  }

}
