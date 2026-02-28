import XCTest

@testable import SwiftyLLVM

final class ParameterTests: XCTestCase {

  func testIndex() {
    var m = Module("foo")

    let f = m.declareFunction("fn", m.functionType(from: (m.i64, m.i64)))
    XCTAssertEqual(f.unsafePointee.parameters[0].unsafePointee.index, 0)
    XCTAssertEqual(f.unsafePointee.parameters[1].unsafePointee.index, 1)

    let p = Parameter(f.unsafePointee.parameters[1].unsafePointee as any IRValue)
    XCTAssertEqual(p?.index, 1)
  }
  func testIndexDynamic() {
    var m = Module("foo")

    let f = m.declareFunction("fn", m.functionType(from: (m.i64, m.i64)))
    XCTAssertEqual(f.unsafePointee.parameters[0].unsafePointee.index, 0)
    XCTAssertEqual(f.unsafePointee.parameters[1].unsafePointee.index, 1)

    let p = Parameter(f.unsafePointee.parameters[1].unsafePointee as any IRValue)
    XCTAssertEqual(p?.index, 1)
  }

  func testParent() {
    var m = Module("foo")

    let f: Function.Reference = m.declareFunction("fn", m.functionType(from: (m.i64, m.i64)))
    XCTAssertEqual(f.unsafePointee.parameters[0].unsafePointee.parent, f.unsafePointee)
  }

  func testParentDynamic() {
    var m = Module("foo")

    let f: Function.Reference = m.declareFunction("fn", m.functionType(from: (m.i64, m.i64)))
    XCTAssertEqual(f.unsafePointee.parameters[0].unsafePointee.parent, f.unsafePointee)
  }
  func testAttributes() throws {
    var m = Module("foo")
    let f = m.declareFunction("f", m.functionType(from: (m.ptr)))
    let p = f.unsafePointee.parameters[0]
    let a = m.parameterAttribute(.nofree)
    let b = m.parameterAttribute(.dereferenceable_or_null, 8)

    m.addParameterAttribute(a, to: p)
    m.addParameterAttribute(b, to: p)
    XCTAssertEqual(p.unsafePointee.attributes.count, 2)
    XCTAssert(p.unsafePointee.attributes.contains(a))
    XCTAssert(p.unsafePointee.attributes.contains(b))

    XCTAssertEqual(m.addParameterAttribute(named: .nofree, to: p), a)

    m.removeParameterAttribute(a, from: p)
    XCTAssertEqual(p.unsafePointee.attributes, [b])
  }

  func testConversion() {
    var m = Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: (m.i64)))
    let p: any IRValue = f.unsafePointee.parameters[0].unsafePointee
    XCTAssertNotNil(Parameter(p))
    let q: any IRValue = m.i64.unsafePointee.zero.unsafePointee
    XCTAssertNil(Parameter(q))
  }

  func testEquality() {
    var m = Module("foo")

    let p = m.declareFunction("fn", m.functionType(from: (m.i64))).unsafePointee.parameters[0]
    let q = m.declareFunction("fn", m.functionType(from: (m.i64))).unsafePointee.parameters[0]
    XCTAssertEqual(p, q)

    let r = m.declareFunction("fn1", m.functionType(from: (m.i64))).unsafePointee.parameters[0]
    XCTAssertNotEqual(p, r)
  }

}
