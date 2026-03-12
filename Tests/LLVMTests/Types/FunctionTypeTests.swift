import SwiftyLLVM
import XCTest

final class FunctionTypeTests: XCTestCase {

  func testDefaultReturnType() throws {
    var m = try Module("foo")
    let f = m.functionType(from: ())
    XCTAssert(f.unsafe[].returnType == m.void.erased)
  }
  func testDefaultReturnTypeDynamic() throws {
    var m = try Module("foo")
    let f = m.functionType(from: [])
    XCTAssert(f.unsafe[].returnType == m.void.erased)
  }

  func testReturnType() throws {
    var m = try Module("foo")
    let t = m.i64
    let f = m.functionType(from: (), to: t)
    XCTAssert(f.unsafe[].returnType == t.erased)
  }

  func testReturnTypeDynamic() throws {
    var m = try Module("foo")
    let t = m.i64
    let f = m.functionType(from: [], to: t.erased)
    XCTAssert(f.unsafe[].returnType == t.erased)
  }

  func testParameters() throws {
    var m = try Module("foo")
    let t = m.integerType(64)
    let u = m.integerType(32)

    let f0 = m.functionType(from: ())
    XCTAssertEqual(f0.unsafe[].parameters.count, 0)

    let f1 = m.functionType(from: (t))
    XCTAssertEqual(f1.unsafe[].parameters.count, 1)
    XCTAssert(f1.unsafe[].parameters[0] == t.erased)

    let f2 = m.functionType(from: (t, u))
    XCTAssertEqual(f2.unsafe[].parameters.count, 2)
    XCTAssert(f2.unsafe[].parameters[0] == t.erased)
    XCTAssert(f2.unsafe[].parameters[1] == u.erased)
  }

  func testConversion() throws {
    var m = try Module("foo")

    let t = m.functionType(from: ())
    XCTAssertNotNil(FunctionType.UnsafeReference(t.erased))

    let u = m.integerType(64)
    XCTAssertNil(FunctionType.UnsafeReference(u.erased))
  }

  func testEquality() throws {
    var m = try Module("foo")
    let t = m.i64
    let u = m.i32

    let f0 = m.functionType(from: (t, u))
    let f1 = m.functionType(from: (t, u))
    XCTAssertEqual(f0, f1)
    XCTAssertEqual(f0.unsafe[], f1.unsafe[])

    let f2 = m.functionType(from: (u, t))
    XCTAssertNotEqual(f0, f2)
    XCTAssertNotEqual(f0.unsafe[], f2.unsafe[])
  }

}
