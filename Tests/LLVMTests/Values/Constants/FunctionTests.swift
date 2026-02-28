import XCTest

@testable import SwiftyLLVM

final class FunctionTests: XCTestCase {

  func testWellFormed() {
    var m = Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: ()))
    XCTAssert(f.unsafePointee.isWellFormed())
    m.appendBlock(to: f)
    XCTAssertFalse(f.unsafePointee.isWellFormed())
  }

  func testEntry() {
    var m = Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: ()))
    XCTAssertNil(f.unsafePointee.entry)
    m.appendBlock(to: f)
    XCTAssertNotNil(f.unsafePointee.entry)
  }

  func testParameters() {
    var m = Module("foo")
    let t = m.i64
    let u = m.i32

    let f0 = m.declareFunction("f0", m.functionType(from: ()))
    XCTAssertEqual(f0.unsafePointee.parameters.count, 0)

    let f1 = m.declareFunction("f1", m.functionType(from: (m.i64)))
    XCTAssertEqual(f1.unsafePointee.parameters.count, 1)
    XCTAssert(f1.unsafePointee.parameters[0].unsafePointee.type == t.erased)

    let f2 = m.declareFunction("f2", m.functionType(from: (m.i64, m.i32)))
    XCTAssertEqual(f2.unsafePointee.parameters.count, 2)
    XCTAssert(f2.unsafePointee.parameters[0].unsafePointee.type == t.erased)
    XCTAssert(f2.unsafePointee.parameters[1].unsafePointee.type == u.erased)
  }

  func testBasicBlocks() {
    var m = Module("foo")

    let f = m.declareFunction("f", m.functionType(from: ()))
    XCTAssertEqual(f.unsafePointee.basicBlocks.count, 0)
    XCTAssert(f.unsafePointee.basicBlocks.elementsEqual([]))

    let b0 = m.appendBlock(to: f)
    XCTAssertEqual(f.unsafePointee.basicBlocks.count, 1)
    XCTAssert(f.unsafePointee.basicBlocks.elementsEqual([b0]))

    let b1 = m.appendBlock(to: f)
    XCTAssertEqual(f.unsafePointee.basicBlocks.count, 2)
    XCTAssert(f.unsafePointee.basicBlocks.contains(b0))
    XCTAssert(f.unsafePointee.basicBlocks.contains(b1))
  }

  func testBasicBlockIndices() {
    var m = Module("foo")
    let f = m.declareFunction("f", m.functionType(from: ()))
    XCTAssertEqual(f.unsafePointee.basicBlocks.startIndex, f.unsafePointee.basicBlocks.endIndex)

    m.appendBlock(to: f)
    XCTAssertEqual(
      f.unsafePointee.basicBlocks.index(after: f.unsafePointee.basicBlocks.startIndex),
      f.unsafePointee.basicBlocks.endIndex)
    XCTAssertEqual(
      f.unsafePointee.basicBlocks.index(before: f.unsafePointee.basicBlocks.endIndex),
      f.unsafePointee.basicBlocks.startIndex)

    m.appendBlock(to: f)
    let middle = f.unsafePointee.basicBlocks.index(after: f.unsafePointee.basicBlocks.startIndex)
    XCTAssertEqual(
      f.unsafePointee.basicBlocks.index(after: middle), f.unsafePointee.basicBlocks.endIndex)
    XCTAssertEqual(
      f.unsafePointee.basicBlocks.index(before: f.unsafePointee.basicBlocks.endIndex), middle)
  }

  func testAttributes() {
    var m = Module("foo")
    let f = m.declareFunction("f", m.functionType(from: ()))
    let a = m.functionAttribute(.alwaysinline)
    let b = m.functionAttribute(.hot)

    m.addFunctionAttribute(a, to: f)
    m.addFunctionAttribute(b, to: f)
    XCTAssertEqual(f.unsafePointee.attributes.count, 2)
    XCTAssert(f.unsafePointee.attributes.contains(a.erased))
    XCTAssert(f.unsafePointee.attributes.contains(b.erased))

    XCTAssertEqual(m.addFunctionAttribute(named: .alwaysinline, to: f), a)

    m.removeFunctionAttribute(a, from: f)
    XCTAssertEqual(f.unsafePointee.attributes, [b.erased])
  }

  func testReturnAttributes() {
    var m = Module("foo")
    let f = m.declareFunction("f", m.functionType(from: (), to: m.ptr))
    let r = f.unsafePointee.returnValue
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
    XCTAssertNotNil(Function.Reference(t.erased))

    let u = m.integerType(64).unsafePointee.zero
    XCTAssertNil(Function.Reference(u.erased))
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
    let f = m.declareFunction("fn", m.functionType(from: ())).unsafePointee.returnValue
    let g = m.declareFunction("fn", m.functionType(from: ())).unsafePointee.returnValue
    XCTAssertEqual(f, g)

    let h = m.declareFunction("fn1", m.functionType(from: ())).unsafePointee.returnValue
    XCTAssertNotEqual(f, h)
  }

}
