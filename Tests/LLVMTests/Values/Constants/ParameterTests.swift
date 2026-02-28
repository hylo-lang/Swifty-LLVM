import XCTest

@testable import SwiftyLLVM

final class ParameterTests: XCTestCase {

  func testIndex() {
    var m = Module("foo")

    let f = m.declareFunction("fn", m.functionType(from: (m.i64, m.i64)))
    XCTAssertEqual(f.pointee.parameters[0].pointee.index, 0)
    XCTAssertEqual(f.pointee.parameters[1].pointee.index, 1)

    let p = Parameter.UnsafeReference(f.pointee.parameters[1].erased)
    XCTAssertEqual(p?.pointee.index, 1)
  }
  func testIndexDynamic() {
    var m = Module("foo")

    let f = m.declareFunction("fn", m.functionType(from: (m.i64, m.i64)))
    XCTAssertEqual(f.pointee.parameters[0].pointee.index, 0)
    XCTAssertEqual(f.pointee.parameters[1].pointee.index, 1)

    let p = Parameter.UnsafeReference(f.pointee.parameters[1].erased)
    XCTAssertEqual(p?.pointee.index, 1)
  }

  func testParent() {
    var m = Module("foo")

    let f: Function.UnsafeReference = m.declareFunction("fn", m.functionType(from: (m.i64, m.i64)))
    XCTAssertEqual(f.pointee.parameters[0].pointee.parent, f.pointee)
  }

  func testParentDynamic() {
    var m = Module("foo")

    let f: Function.UnsafeReference = m.declareFunction("fn", m.functionType(from: (m.i64, m.i64)))
    XCTAssertEqual(f.pointee.parameters[0].pointee.parent, f.pointee)
  }
  func testAttributes() throws {
    var m = Module("foo")
    let f = m.declareFunction("f", m.functionType(from: (m.ptr)))
    let p = f.pointee.parameters[0]
    let a = m.parameterAttribute(.nofree)
    let b = m.parameterAttribute(.dereferenceable_or_null, 8)

    m.addParameterAttribute(a, to: p)
    m.addParameterAttribute(b, to: p)
    XCTAssertEqual(p.pointee.attributes.count, 2)
    XCTAssert(p.pointee.attributes.contains(a))
    XCTAssert(p.pointee.attributes.contains(b))

    XCTAssertEqual(m.addParameterAttribute(named: .nofree, to: p), a)

    m.removeParameterAttribute(a, from: p)
    XCTAssertEqual(p.pointee.attributes, [b])
  }

  func testConversion() {
    var m = Module("foo")

    let f = m.declareFunction("fn", m.functionType(from: (m.i64)))
    let p = f.pointee.parameters[0]
    XCTAssertNotNil(Parameter.UnsafeReference(p.erased))
    
    let q = m.i64.pointee.zero
    XCTAssertNil(Parameter.UnsafeReference(q.erased))
  }

  func testEquality() {
    var m = Module("foo")

    let p = m.declareFunction("fn", m.functionType(from: (m.i64))).pointee.parameters[0]
    let q = m.declareFunction("fn", m.functionType(from: (m.i64))).pointee.parameters[0]
    XCTAssertEqual(p, q)

    let r = m.declareFunction("fn1", m.functionType(from: (m.i64))).pointee.parameters[0]
    XCTAssertNotEqual(p, r)
  }

}
