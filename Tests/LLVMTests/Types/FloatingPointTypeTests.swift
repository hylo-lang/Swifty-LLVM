import XCTest

@testable import SwiftyLLVM

final class FloatingPointTypeTests: XCTestCase {

  func testConversion() {
    var m = Module("foo")

    let t0 = m.half.erased
    let t1 = m.float.erased
    let t2 = m.double.erased
    let t3 = m.fp128.erased
    for t in [t0, t1, t2, t3] {
      XCTAssertNotNil(FloatingPointType.UnsafeReference(t))
    }

    let u = m.integerType(64).erased
    XCTAssertNil(FloatingPointType.UnsafeReference(u))
  }

  func testCallSyntax() {
    var m = Module("foo")
    let double = m.double.pointee
    let x = double(1)
    XCTAssertEqual(x.pointee.value.value, 1, accuracy: .ulpOfOne)
  }

  func testEquality() {
    var m = Module("foo")
    let t = m.double.pointee
    let u = m.double.pointee
    XCTAssertEqual(t.llvm, u.llvm)

    let v = m.float.pointee
    XCTAssertNotEqual(t.llvm, v.llvm)
  }

}
