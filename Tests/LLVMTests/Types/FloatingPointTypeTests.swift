@testable import SwiftyLLVM
import XCTest

final class FloatingPointTypeTests: XCTestCase {

  func testConversion() {
    var m = Module("foo")

    let t0 = m.types[FloatingPointType.half(in: &m)] as any IRType
    let t1 = m.types[FloatingPointType.float(in: &m)] as any IRType
    let t2 = m.types[FloatingPointType.double(in: &m)] as any IRType
    let t3 = m.types[FloatingPointType.fp128(in: &m)] as any IRType
    for t in [t0, t1, t2, t3] {
      XCTAssertNotNil(FloatingPointType(t))
    }

    let u = m.types[IntegerType.create(64, in: &m)] as any IRType
    XCTAssertNil(FloatingPointType(u))
  }

  func testCallSyntax() {
    var m = Module("foo")
    let double = m.types[FloatingPointType.double(in: &m)]
    let x = double(1, in: &m)
    XCTAssertEqual(m.values[x].value.value, 1, accuracy: .ulpOfOne)
  }

  func testEquality() {
    var m = Module("foo")
    let t = m.types[FloatingPointType.double(in: &m)]
    let u = m.types[FloatingPointType.double(in: &m)]
    XCTAssertEqual(t.llvm, u.llvm)

    let v = m.types[FloatingPointType.float(in: &m)]
    XCTAssertNotEqual(t.llvm, v.llvm)
  }

}
