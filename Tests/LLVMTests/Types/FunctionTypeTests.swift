import SwiftyLLVM
import XCTest

final class FunctionTypeTests: XCTestCase {

  func testDefaultReturnType() {
    var m = Module("foo")
    let f = m.functionType(from: ())
    XCTAssert(f.unsafePointee.returnType == m.void.erased)
  }
  func testDefaultReturnTypeDynamic() {
    var m = Module("foo")
    let f = m.functionType(from: [])
    XCTAssert(f.unsafePointee.returnType == m.void.erased)
  }

  func testReturnType() {
    var m = Module("foo")
    let t = m.i64
    let f = m.functionType(from: (), to: t)
    XCTAssert(f.unsafePointee.returnType == t.erased)
  }

  func testReturnTypeDynamic() {
    var m = Module("foo")
    let t = m.i64
    let f = m.functionType(from: [], to: t.erased)
    XCTAssert(f.unsafePointee.returnType == t.erased)
  }

  func testParameters() {
    var m = Module("foo")
    let t = m.integerType(64)
    let u = m.integerType(32)

    let f0 = m.functionType(from: ())
    XCTAssertEqual(f0.unsafePointee.parameters.count, 0)

    let f1 = m.functionType(from: (t))
    XCTAssertEqual(f1.unsafePointee.parameters.count, 1)
    XCTAssert(f1.unsafePointee.parameters[0] == t.erased)

    let f2 = m.functionType(from: (t, u))
    XCTAssertEqual(f2.unsafePointee.parameters.count, 2)
    XCTAssert(f2.unsafePointee.parameters[0] == t.erased)
    XCTAssert(f2.unsafePointee.parameters[1] == u.erased)
  }

  func testConversion() {
    var m = Module("foo")

    let t: any IRType = m.functionType(from: ()).unsafePointee
    XCTAssertNotNil(FunctionType(t))

    let u: any IRType = m.integerType(64).unsafePointee
    XCTAssertNil(FunctionType(u))
  }

  func testEquality() {
    var m = Module("foo")
    let t = m.i64
    let u = m.i32

    let f0 = m.functionType(from: (t, u))
    let f1 = m.functionType(from: (t, u))
    XCTAssertEqual(f0, f1)
    XCTAssertEqual(f0.unsafePointee, f1.unsafePointee)

    let f2 = m.functionType(from: (u, t))
    XCTAssertNotEqual(f0, f2)
    XCTAssertNotEqual(f0.unsafePointee, f2.unsafePointee)
  }

}
