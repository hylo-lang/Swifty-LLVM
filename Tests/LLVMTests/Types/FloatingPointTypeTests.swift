import XCTest

@testable import SwiftyLLVM

final class FloatingPointTypeTests: XCTestCase {

  func testConversion() {
    var m = Module("foo")

    let t0 = m.half.unsafePointee as any IRType
    let t1 = m.float.unsafePointee as any IRType
    let t2 = m.double.unsafePointee as any IRType
    let t3 = m.fp128.unsafePointee as any IRType
    for t in [t0, t1, t2, t3] {
      XCTAssertNotNil(FloatingPointType(t))
    }

    let u = m.integerType(64).unsafePointee as any IRType
    XCTAssertNil(FloatingPointType(u))
  }

  func testCallSyntax() {
    var m = Module("foo")
    let double = m.double.unsafePointee
    let x = double(1)
    XCTAssertEqual(x.unsafePointee.value.value, 1, accuracy: .ulpOfOne)
  }

  func testEquality() {
    var m = Module("foo")
    let t = m.double.unsafePointee
    let u = m.double.unsafePointee
    XCTAssertEqual(t.llvm, u.llvm)

    let v = m.float.unsafePointee
    XCTAssertNotEqual(t.llvm, v.llvm)
  }

}
