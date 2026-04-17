import XCTest

@testable import SwiftyLLVM

final class FloatingPointTypeTests: XCTestCase {

  func testConversion() throws {
    var m = try Module("foo")

    let floatingPointTypes = [
      m.half.erased, m.bfloat.erased, m.float.erased, m.double.erased,
      m.x86_fp80.erased, m.fp128.erased, m.ppc_fp128.erased
    ]

    for t in floatingPointTypes {
      XCTAssertNotNil(FloatingPointType.UnsafeReference(t))
    }

    let u = m.integerType(64).erased
    XCTAssertNil(FloatingPointType.UnsafeReference(u))
  }

  func testCallSyntax() throws {
    let m = try Module("foo")
    let double = m.double.unsafe[]
    let x = double(1)
    XCTAssertEqual(x.unsafe[].type, m.double.erased)
    XCTAssertTrue(x.unsafe[].isConstant)
    XCTAssertEqual(x.unsafe[].value.value, 1, accuracy: .ulpOfOne)
  }

  func testEquality() throws {
    let m = try Module("foo")
    let t = m.double.unsafe[]
    let u = m.double.unsafe[]
    XCTAssertEqual(t, u)
    XCTAssertEqual(t.llvm, u.llvm)

    let v = m.float.unsafe[]
    XCTAssertNotEqual(t, v)
    XCTAssertNotEqual(t.llvm, v.llvm)
  }

  func testDistinctTypes() throws {
    let m = try Module("foo")
    let types = [m.half, m.bfloat, m.float, m.double, m.x86_fp80, m.fp128, m.ppc_fp128]

    for i in types.indices {
      for j in types.indices where i != j {
        XCTAssertNotEqual(types[i].llvm, types[j].llvm)
      }
    }
  }

}
