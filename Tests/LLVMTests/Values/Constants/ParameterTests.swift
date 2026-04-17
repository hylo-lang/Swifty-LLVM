import XCTest

@testable import SwiftyLLVM

final class ParameterTests: XCTestCase {

  func testIndex() throws {
    var m = try Module("foo")

    let f = m.declareFunction("fn", m.functionType(from: (m.i64, m.i64)))
    XCTAssertEqual(f.unsafe[].parameters[0].unsafe[].index, 0)
    XCTAssertEqual(f.unsafe[].parameters[1].unsafe[].index, 1)

    let p = Parameter.UnsafeReference(f.unsafe[].parameters[1].erased)
    XCTAssertEqual(p?.unsafe[].index, 1)
  }
  func testIndexDynamic() throws {
    var m = try Module("foo")

    let f = m.declareFunction("fn", m.functionType(from: (m.i64, m.i64)))
    XCTAssertEqual(f.unsafe[].parameters[0].unsafe[].index, 0)
    XCTAssertEqual(f.unsafe[].parameters[1].unsafe[].index, 1)

    let p = Parameter.UnsafeReference(f.unsafe[].parameters[1].erased)
    XCTAssertEqual(p?.unsafe[].index, 1)
  }

  func testParent() throws {
    var m = try Module("foo")

    let f: Function.UnsafeReference = m.declareFunction("fn", m.functionType(from: (m.i64, m.i64)))
    XCTAssertEqual(f.unsafe[].parameters[0].unsafe[].parent, f.unsafe[])
  }

  func testParentDynamic() throws {
    var m = try Module("foo")

    let f: Function.UnsafeReference = m.declareFunction("fn", m.functionType(from: (m.i64, m.i64)))
    XCTAssertEqual(f.unsafe[].parameters[0].unsafe[].parent, f.unsafe[])
  }
  func testAttributes() throws {
    var m = try Module("foo")
    let f = m.declareFunction("f", m.functionType(from: (m.ptr)))
    let p = f.unsafe[].parameters[0]
    let a = m.parameterAttribute(.nofree)
    let b = m.parameterAttribute(.dereferenceable_or_null, 8)

    m.addParameterAttribute(a, to: p)
    m.addParameterAttribute(b, to: p)
    XCTAssertEqual(p.unsafe[].attributes.count, 2)
    XCTAssert(p.unsafe[].attributes.contains(a))
    XCTAssert(p.unsafe[].attributes.contains(b))

    XCTAssertEqual(m.addParameterAttribute(named: .nofree, to: p), a)

    m.removeParameterAttribute(a, from: p)
    XCTAssertEqual(p.unsafe[].attributes, [b])
  }

  func testConversion() throws {
    var m = try Module("foo")

    let f = m.declareFunction("fn", m.functionType(from: (m.i64)))
    let p = f.unsafe[].parameters[0]
    XCTAssertNotNil(Parameter.UnsafeReference(p.erased))
    
    let q = m.i64.unsafe[].zero
    XCTAssertNil(Parameter.UnsafeReference(q.erased))
  }

  func testReferenceEquality() throws {
    var m = try Module("foo")

    let p = m.declareFunction("fn", m.functionType(from: (m.i64))).unsafe[].parameters[0]
    let q = m.declareFunction("fn", m.functionType(from: (m.i64))).unsafe[].parameters[0]
    XCTAssertEqual(p, q)

    let r = m.declareFunction("fn1", m.functionType(from: (m.i64))).unsafe[].parameters[0]
    XCTAssertNotEqual(p, r)
  }

  func testEquality() throws {
    var m = try Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: (m.i64, m.i32)))

    let p0a = f.unsafe[].parameters[0].unsafe[]
    let p0b = f.unsafe[].parameters[0].unsafe[]
    XCTAssertEqual(p0a, p0b)
    XCTAssertEqual(p0a.hashValue, p0b.hashValue)
  }

  func testInequality() throws {
    var m = try Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: (m.i64, m.i32)))

    let p0 = f.unsafe[].parameters[0].unsafe[]
    let p1 = f.unsafe[].parameters[1].unsafe[]
    XCTAssertNotEqual(p0, p1)

    let g = m.declareFunction("gn", m.functionType(from: (m.i64)))
    let q0 = g.unsafe[].parameters[0].unsafe[]
    XCTAssertNotEqual(p0, q0)
  }

}
