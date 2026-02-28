import XCTest

@testable import SwiftyLLVM

final class FunctionTests: XCTestCase {

  func testWellFormed() {
    var m = Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: ()))
    XCTAssert(f.pointee.isWellFormed())
    m.appendBlock(to: f)
    XCTAssertFalse(f.pointee.isWellFormed())
  }

  func testEntry() {
    var m = Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: ()))
    XCTAssertNil(f.pointee.entry)
    m.appendBlock(to: f)
    XCTAssertNotNil(f.pointee.entry)
  }

  func testParameters() {
    var m = Module("foo")
    let t = m.i64
    let u = m.i32

    let f0 = m.declareFunction("f0", m.functionType(from: ()))
    XCTAssertEqual(f0.pointee.parameters.count, 0)

    let f1 = m.declareFunction("f1", m.functionType(from: (m.i64)))
    XCTAssertEqual(f1.pointee.parameters.count, 1)
    XCTAssert(f1.pointee.parameters[0].pointee.type == t.erased)

    let f2 = m.declareFunction("f2", m.functionType(from: (m.i64, m.i32)))
    XCTAssertEqual(f2.pointee.parameters.count, 2)
    XCTAssert(f2.pointee.parameters[0].pointee.type == t.erased)
    XCTAssert(f2.pointee.parameters[1].pointee.type == u.erased)
  }

  func testBasicBlocks() {
    var m = Module("foo")

    let f = m.declareFunction("f", m.functionType(from: ()))
    XCTAssertEqual(f.pointee.basicBlocks.count, 0)
    XCTAssert(f.pointee.basicBlocks.elementsEqual([]))

    let b0 = m.appendBlock(to: f)
    XCTAssertEqual(f.pointee.basicBlocks.count, 1)
    XCTAssert(f.pointee.basicBlocks.elementsEqual([b0]))

    let b1 = m.appendBlock(to: f)
    XCTAssertEqual(f.pointee.basicBlocks.count, 2)
    XCTAssert(f.pointee.basicBlocks.contains(b0))
    XCTAssert(f.pointee.basicBlocks.contains(b1))
  }

  func testBasicBlockIndices() {
    var m = Module("foo")
    let f = m.declareFunction("f", m.functionType(from: ()))
    XCTAssertEqual(f.pointee.basicBlocks.startIndex, f.pointee.basicBlocks.endIndex)

    m.appendBlock(to: f)
    XCTAssertEqual(
      f.pointee.basicBlocks.index(after: f.pointee.basicBlocks.startIndex),
      f.pointee.basicBlocks.endIndex)
    XCTAssertEqual(
      f.pointee.basicBlocks.index(before: f.pointee.basicBlocks.endIndex),
      f.pointee.basicBlocks.startIndex)

    m.appendBlock(to: f)
    let middle = f.pointee.basicBlocks.index(after: f.pointee.basicBlocks.startIndex)
    XCTAssertEqual(
      f.pointee.basicBlocks.index(after: middle), f.pointee.basicBlocks.endIndex)
    XCTAssertEqual(
      f.pointee.basicBlocks.index(before: f.pointee.basicBlocks.endIndex), middle)
  }

  func testAttributes() {
    var m = Module("foo")
    let f = m.declareFunction("f", m.functionType(from: ()))
    let a = m.functionAttribute(.alwaysinline)
    let b = m.functionAttribute(.hot)

    m.addFunctionAttribute(a, to: f)
    m.addFunctionAttribute(b, to: f)
    XCTAssertEqual(f.pointee.attributes.count, 2)
    XCTAssert(f.pointee.attributes.contains(a.erased))
    XCTAssert(f.pointee.attributes.contains(b.erased))

    XCTAssertEqual(m.addFunctionAttribute(named: .alwaysinline, to: f), a)

    m.removeFunctionAttribute(a, from: f)
    XCTAssertEqual(f.pointee.attributes, [b.erased])
  }

  func testReturnAttributes() {
    var m = Module("foo")
    let f = m.declareFunction("f", m.functionType(from: (), to: m.ptr))
    let r = f.pointee.returnValue
    let a = m.returnAttribute(.noalias)
    let b = m.returnAttribute(.dereferenceable_or_null, 8)

    m.addReturnAttribute(a, to: f)
    m.addReturnAttribute(b, to: f)
    XCTAssertEqual(r.attributes.count, 2)
    XCTAssert(r.attributes.contains(a))
    XCTAssert(r.attributes.contains(b))

    XCTAssertEqual(m.addReturnAttribute(named: .noalias, to: f), a)

    m.removeReturnAttribute(a, from: r)
    XCTAssertEqual(r.attributes, [b])
  }

  func testConversion() {
    var m = Module("foo")

    let t = m.declareFunction("fn", m.functionType(from: ()))
    XCTAssertNotNil(Function.UnsafeReference(t.erased))

    let u = m.integerType(64).pointee.zero
    XCTAssertNil(Function.UnsafeReference(u.erased))
  }

  func testEquality() {
    var m = Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: ()))
    let g = m.declareFunction("fn", m.functionType(from: ()))
    XCTAssertEqual(f, g)

    let h = m.declareFunction("fn1", m.functionType(from: ()))
    XCTAssertNotEqual(f, h)
  }

  func testReturnEquality() {
    var m = Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: ())).pointee.returnValue
    let g = m.declareFunction("fn", m.functionType(from: ())).pointee.returnValue
    XCTAssertEqual(f, g)

    let h = m.declareFunction("fn1", m.functionType(from: ())).pointee.returnValue
    XCTAssertNotEqual(f, h)
  }

}
