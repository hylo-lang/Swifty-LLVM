import LLVM
import XCTest

final class ParameterTests: XCTestCase {

  func testIndex() {
    var m = Module("foo")
    let i64 = IntegerType(64, in: &m)

    let f = m.declareFunction("fn", .init(from: [i64, i64], in: &m))
    XCTAssertEqual(f.parameters[0].index, 0)
    XCTAssertEqual(f.parameters[1].index, 1)

    let p = Parameter(f.parameters[1] as IRValue)
    XCTAssertEqual(p?.index, 1)
  }

  func testParent() {
    var m = Module("foo")
    let i64 = IntegerType(64, in: &m)

    let f = m.declareFunction("fn", .init(from: [i64, i64], in: &m))
    XCTAssertEqual(f.parameters[0].parent, f)
  }

  func testAttributes() {
    var m = Module("foo")
    let f = m.declareFunction("f", .init(from: [PointerType(in: &m)], in: &m))
    let p = f.parameters[0]
    let a = Parameter.Attribute(.nofree, in: &m)
    let b = Parameter.Attribute(.dereferenceable_or_null, 8, in: &m)

    m.addAttribute(a, to: p)
    m.addAttribute(b, to: p)
    XCTAssertEqual(p.attributes.count, 2)
    XCTAssert(p.attributes.contains(a))
    XCTAssert(p.attributes.contains(b))

    m.removeAttribute(a, from: p)
    XCTAssertEqual(p.attributes, [b])
  }

  func testConversion() {
    var m = Module("foo")
    let i64 = IntegerType(64, in: &m)

    let p: IRValue = m.declareFunction("fn", .init(from: [i64], in: &m)).parameters[0]
    XCTAssertNotNil(Parameter(p))
    let q: IRValue = IntegerType(64, in: &m).zero
    XCTAssertNil(Parameter(q))
  }

  func testEquality() {
    var m = Module("foo")
    let i64 = IntegerType(64, in: &m)

    let p = m.declareFunction("fn", .init(from: [i64], in: &m)).parameters[0]
    let q = m.declareFunction("fn", .init(from: [i64], in: &m)).parameters[0]
    XCTAssertEqual(p, q)

    let r = m.declareFunction("fn1", .init(from: [i64], in: &m)).parameters[0]
    XCTAssertNotEqual(p, r)
  }

}
