import SwiftyLLVM
import XCTest

final class FunctionTypeTests: XCTestCase {

  func testDefaultReturnType() {
    var m = Module("foo")
    XCTAssert(FunctionType(from: [], in: &m).returnType == VoidType(in: &m))
  }

  func testReturnType() {
    var m = Module("foo")
    let t = IntegerType(64, in: &m)
    XCTAssert(FunctionType(from: [], to: t, in: &m).returnType == t)
  }

  func testParameters() {
    var m = Module("foo")
    let t = IntegerType(64, in: &m)
    let u = IntegerType(32, in: &m)

    let f0 = FunctionType(from: [], in: &m)
    XCTAssertEqual(f0.parameters.count, 0)

    let f1 = FunctionType(from: [t], in: &m)
    XCTAssertEqual(f1.parameters.count, 1)
    XCTAssert(f1.parameters[0] == t)

    let f2 = FunctionType(from: [t, u], in: &m)
    XCTAssertEqual(f2.parameters.count, 2)
    XCTAssert(f2.parameters[0] == t)
    XCTAssert(f2.parameters[1] == u)
  }

  func testConversion() {
    var m = Module("foo")
    let t: IRType = FunctionType(from: [], in: &m)
    XCTAssertNotNil(FunctionType(t))
    let u: IRType = IntegerType(64, in: &m)
    XCTAssertNil(FunctionType(u))
  }

  func testEquality() {
    var m = Module("foo")
    let t = IntegerType(64, in: &m)
    let u = IntegerType(32, in: &m)

    let f0 = FunctionType(from: [t, u], in: &m)
    let f1 = FunctionType(from: [t, u], in: &m)
    XCTAssertEqual(f0, f1)

    let f2 = FunctionType(from: [u, t], in: &m)
    XCTAssertNotEqual(f0, f2)
  }

}
