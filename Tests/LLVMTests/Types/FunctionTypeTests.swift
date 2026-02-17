import SwiftyLLVM
import XCTest

final class FunctionTypeTests: XCTestCase {

  func testDefaultReturnType() {
    var m = Module("foo")
    let f = m.types[FunctionType.create(from: [], in: &m)]
    XCTAssert(f.returnType == m.types[VoidType.create(in: &m)])
  }

  func testReturnType() {
    var m = Module("foo")
    let t = m.types[IntegerType.create(64, in: &m)]
    let f = m.types[FunctionType.create(from: [], to: AnyType.ID(m.types.id(for: t)!), in: &m)]
    XCTAssert(f.returnType == t)
  }

  func testParameters() {
    var m = Module("foo")
    let t = m.types[IntegerType.create(64, in: &m)]
    let u = m.types[IntegerType.create(32, in: &m)]

    let f0 = m.types[FunctionType.create(from: [], in: &m)]
    XCTAssertEqual(f0.parameters.count, 0)

    let tID = AnyType.ID(m.types.id(for: t)!)
    let uID = AnyType.ID(m.types.id(for: u)!)

    let f1 = m.types[FunctionType.create(from: [tID], in: &m)]
    XCTAssertEqual(f1.parameters.count, 1)
    XCTAssert(f1.parameters[0] == t)

    let f2 = m.types[FunctionType.create(from: [tID, uID], in: &m)]
    XCTAssertEqual(f2.parameters.count, 2)
    XCTAssert(f2.parameters[0] == t)
    XCTAssert(f2.parameters[1] == u)
  }

  func testConversion() {
    var m = Module("foo")
    let t: any IRType = m.types[FunctionType.create(from: [], in: &m)]
    XCTAssertNotNil(FunctionType(t))
    let u: any IRType = m.types[IntegerType.create(64, in: &m)]
    XCTAssertNil(FunctionType(u))
  }

  func testEquality() {
    var m = Module("foo")
    let t = m.types[IntegerType.create(64, in: &m)]
    let u = m.types[IntegerType.create(32, in: &m)]
    let tID = AnyType.ID(m.types.id(for: t)!)
    let uID = AnyType.ID(m.types.id(for: u)!)

    let f0 = m.types[FunctionType.create(from: [tID, uID], in: &m)]
    let f1 = m.types[FunctionType.create(from: [tID, uID], in: &m)]
    XCTAssertEqual(f0, f1)

    let f2 = m.types[FunctionType.create(from: [uID, tID], in: &m)]
    XCTAssertNotEqual(f0, f2)
  }

}
