import SwiftyLLVM
import XCTest

final class FunctionTypeTests: XCTestCase {

  func testDefaultReturnType() {
    var m = Module("foo")
    let f = m.types[m.functionType(from: ())]
    XCTAssert(f.returnType == m.types[m.void])
  }
  func testDefaultReturnTypeDynamic() {
    var m = Module("foo")
    let f = m.types[m.functionType(from: [])]
    XCTAssert(f.returnType == m.types[m.void])
  }

  func testReturnType() {
    var m = Module("foo")
    let t = m.i64
    let f = m.types[m.functionType(from: (), to: t)]
    XCTAssert(f.returnType == m.types[t])
  }

  func testReturnTypeDynamic() {
    var m = Module("foo")
    let t = m.i64
    let f = m.types[m.functionType(from: [], to: t.erased)]
    XCTAssert(f.returnType == m.types[t])
  }

  func testParameters() {
    var m = Module("foo")
    let t = m.types[m.integerType(64)]
    let u = m.types[m.integerType(32)]

    let f0 = m.types[m.functionType(from: ())]
    XCTAssertEqual(f0.parameters.count, 0)

    let te = m.types.id(for: t)!
    let ue = m.types.id(for: u)!

    let f1 = m.types[m.functionType(from: (te))]
    XCTAssertEqual(f1.parameters.count, 1)
    XCTAssert(f1.parameters[0] == t)

    let f2 = m.types[m.functionType(from: (te, ue))]
    XCTAssertEqual(f2.parameters.count, 2)
    XCTAssert(f2.parameters[0] == t)
    XCTAssert(f2.parameters[1] == u)
  }

  func testConversion() {
    var m = Module("foo")
    let t: any IRType = m.types[m.functionType(from: ())]
    XCTAssertNotNil(FunctionType(t))
    let u: any IRType = m.types[m.integerType(64)]
    XCTAssertNil(FunctionType(u))
  }

  func testEquality() {
    var m = Module("foo")
    let t = m.i64
    let u = m.i32

    let f0 = m.types[m.functionType(from: (t, u))]
    let f1 = m.types[m.functionType(from: (t, u))]
    XCTAssertEqual(f0, f1)

    let f2 = m.types[m.functionType(from: (u, t))]
    XCTAssertNotEqual(f0, f2)
  }

}
