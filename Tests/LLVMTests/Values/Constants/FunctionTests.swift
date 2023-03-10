import LLVM
import XCTest

final class FunctionTests: XCTestCase {

  func testWellFormed() {
    var m = Module("foo")
    let f = m.declareFunction("fn", .init(from: [], in: &m))
    XCTAssert(f.isWellFormed())
    m.appendBlock(to: f)
    XCTAssertFalse(f.isWellFormed())
  }

  func testParameters() {
    var m = Module("foo")
    let t = IntegerType(64, in: &m)
    let u = IntegerType(32, in: &m)

    let f0 = m.declareFunction("f0", .init(from: [], in: &m))
    XCTAssertEqual(f0.parameters.count, 0)

    let f1 = m.declareFunction("f1", .init(from: [t], in: &m))
    XCTAssertEqual(f1.parameters.count, 1)
    XCTAssert(f1.parameters[0].type == t)

    let f2 = m.declareFunction("f2", .init(from: [t, u], in: &m))
    XCTAssertEqual(f2.parameters.count, 2)
    XCTAssert(f2.parameters[0].type == t)
    XCTAssert(f2.parameters[1].type == u)
  }

  func testAttributes() {
    var m = Module("foo")
    let f = m.declareFunction("f", .init(from: [], in: &m))
    let a = Function.Attribute(.alwaysinline, in: &m)
    let b = Function.Attribute(.hot, in: &m)

    m.addAttribute(a, to: f)
    m.addAttribute(b, to: f)
    XCTAssertEqual(f.attributes.count, 2)
    XCTAssert(f.attributes.contains(a))
    XCTAssert(f.attributes.contains(b))

    m.removeAttribute(a, from: f)
    XCTAssertEqual(f.attributes, [b])
  }

  func testReturnAttributes() {
    var m = Module("foo")
    let f = m.declareFunction("f", .init(from: [], to: PointerType(in: &m), in: &m))
    let r = f.returnValue
    let a = Function.Return.Attribute(.noalias, in: &m)
    let b = Parameter.Attribute(.dereferenceable_or_null, 8, in: &m)

    m.addAttribute(a, to: r)
    m.addAttribute(b, to: r)
    XCTAssertEqual(r.attributes.count, 2)
    XCTAssert(r.attributes.contains(a))
    XCTAssert(r.attributes.contains(b))

    m.removeAttribute(a, from: r)
    XCTAssertEqual(r.attributes, [b])
  }

  func testConversion() {
    var m = Module("foo")
    let t: IRValue = m.declareFunction("fn", .init(from: [], in: &m))
    XCTAssertNotNil(Function(t))
    let u: IRValue = IntegerType(64, in: &m).zero
    XCTAssertNil(Function(u))
  }

  func testEquality() {
    var m = Module("foo")
    let f = m.declareFunction("fn", .init(from: [], in: &m))
    let g = m.declareFunction("fn", .init(from: [], in: &m))
    XCTAssertEqual(f, g)

    let h = m.declareFunction("fn1", .init(from: [], in: &m))
    XCTAssertNotEqual(f, h)
  }

  func testReturnEquality() {
    var m = Module("foo")
    let f = m.declareFunction("fn", .init(from: [], in: &m)).returnValue
    let g = m.declareFunction("fn", .init(from: [], in: &m)).returnValue
    XCTAssertEqual(f, g)

    let h = m.declareFunction("fn1", .init(from: [], in: &m)).returnValue
    XCTAssertNotEqual(f, h)
  }

}
