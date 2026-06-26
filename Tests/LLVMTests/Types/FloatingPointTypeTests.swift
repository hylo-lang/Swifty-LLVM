import XCTest

@testable import SwiftyLLVM

final class FloatingPointTypeTests: XCTestCase {

  func testConversion() throws {
    var m = try Module("foo", targetMachine: .host())

    let floatingPointTypes = [
      m.half.t, m.bfloat.t, m.float.t, m.double.t,
      m.x86_fp80.t, m.fp128.t, m.ppc_fp128.t
    ]

    for t in floatingPointTypes {
      XCTAssertNotNil(FloatingPointType.UnsafeReference(t))
    }

    let u = m.integerType(64).t
    XCTAssertNil(FloatingPointType.UnsafeReference(u))
  }

  func testCallSyntax() throws {
    let m = try Module("foo", targetMachine: .host())
    let double = m.double.unsafe[]
    let x = double(1)
    XCTAssertEqual(x.unsafe[].type, m.double.t)
    XCTAssertTrue(x.unsafe[].isConstant)
    XCTAssertEqual(x.unsafe[].value.value, 1, accuracy: .ulpOfOne)
  }

  func testEquality() throws {
    let m = try Module("foo", targetMachine: .host())
    let t = m.double.unsafe[]
    let u = m.double.unsafe[]
    XCTAssertEqual(t, u)
    XCTAssertEqual(t.llvm, u.llvm)

    let v = m.float.unsafe[]
    XCTAssertNotEqual(t, v)
    XCTAssertNotEqual(t.llvm, v.llvm)
  }

  func testDistinctTypes() throws {
    let m = try Module("foo", targetMachine: .host())
    let types = [m.half, m.bfloat, m.float, m.double, m.x86_fp80, m.fp128, m.ppc_fp128]

    for i in types.indices {
      for j in types.indices where i != j {
        XCTAssertNotEqual(types[i].llvm, types[j].llvm)
      }
    }
  }

}
