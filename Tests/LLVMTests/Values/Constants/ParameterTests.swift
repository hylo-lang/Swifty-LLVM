@testable import SwiftyLLVM
import XCTest

final class ParameterTests: XCTestCase {

  func testIndex() {
    var m = Module("foo")
    let i64 = m.types[m.integerType(64)]
    let i64ID = AnyType.ID(m.integerType(64))

    let f = m.declareFunction("fn", m.functionType(from: [i64ID, i64ID], to: nil))
    XCTAssertEqual(m.values[f].parameters[0].index, 0)
    XCTAssertEqual(m.values[f].parameters[1].index, 1)

    let p = Parameter(m.values[f].parameters[1] as any IRValue)
    XCTAssertEqual(p?.index, 1)
  }

  func testParent() {
    var m = Module("foo")

    let f = m.declareFunction("fn", m.functionType(from: [m.i64.erased, m.i64.erased], to: nil))
    XCTAssertEqual(m.values[f].parameters[0].parent, m.values[f])
  }

  func testAttributes() throws {
    var m = Module("foo")
    let f = m.declareFunction("f", m.functionType(from: [m.ptr.erased], to: nil))
    let p = m.values[f].parameters[0]
    let pid = try XCTUnwrap(m.values.id(for: p))
    let a = m.createParameterAttribute(.nofree)
    let b = m.createParameterAttribute(.dereferenceable_or_null, 8)

    m.addParameterAttribute(a, to: pid)
    m.addParameterAttribute(b, to: pid)
    XCTAssertEqual(p.attributes.count, 2)
    XCTAssert(p.attributes.contains(m.attributes[a]))
    XCTAssert(p.attributes.contains(m.attributes[b]))

    XCTAssertEqual(m.addParameterAttribute(named: .nofree, to: pid), a)

    m.removeParameterAttribute(a, from: pid)
    XCTAssertEqual(p.attributes, [m.attributes[b]])
  }

  func testConversion() {
    var m = Module("foo")
    let i64ID = m.i64.erased

    let f = m.declareFunction("fn", m.functionType(from: [i64ID], to: nil))
    let p: any IRValue = m.values[f].parameters[0]
    XCTAssertNotNil(Parameter(p))
    let q: any IRValue = m.types[m.i64].zero
    XCTAssertNil(Parameter(q))
  }

  func testEquality() {
    var m = Module("foo")
    let i64 = m.i64.erased

    let p = m.values[m.declareFunction("fn", m.functionType(from: [i64]))].parameters[0]
    let q = m.values[m.declareFunction("fn", m.functionType(from: [i64]))].parameters[0]
    XCTAssertEqual(p, q)

    let r = m.values[m.declareFunction("fn1", m.functionType(from: [i64]))].parameters[0]
    XCTAssertNotEqual(p, r)
  }

}
