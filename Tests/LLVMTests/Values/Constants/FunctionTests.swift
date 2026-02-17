@testable import SwiftyLLVM
import XCTest

final class FunctionTests: XCTestCase {

  func testWellFormed() {
    var m = Module("foo")
    let f = m.declareFunction("fn", FunctionType.create(from: [], in: &m))
    XCTAssert(m.values[f].isWellFormed())
    m.appendBlock(to: f)
    XCTAssertFalse(m.values[f].isWellFormed())
  }

  func testEntry() {
    var m = Module("foo")
    let f = m.declareFunction("fn", FunctionType.create(from: [], in: &m))
    XCTAssertNil(m.values[f].entry)
    m.appendBlock(to: f)
    XCTAssertNotNil(m.values[f].entry)
  }

  func testParameters() {
    var m = Module("foo")
    let t = m.types[IntegerType.create(64, in: &m)]
    let u = m.types[IntegerType.create(32, in: &m)]
    let tID = AnyType.ID(m.types.id(for: t)!)
    let uID = AnyType.ID(m.types.id(for: u)!)

    let f0 = m.declareFunction("f0", FunctionType.create(from: [], in: &m))
    XCTAssertEqual(m.values[f0].parameters.count, 0)

    let f1 = m.declareFunction("f1", FunctionType.create(from: [tID], in: &m))
    XCTAssertEqual(m.values[f1].parameters.count, 1)
    XCTAssert(m.values[f1].parameters[0].type == t)

    let f2 = m.declareFunction("f2", FunctionType.create(from: [tID, uID], in: &m))
    XCTAssertEqual(m.values[f2].parameters.count, 2)
    XCTAssert(m.values[f2].parameters[0].type == t)
    XCTAssert(m.values[f2].parameters[1].type == u)
  }

  func testBasicBlocks() {
    var m = Module("foo")

    let f = m.declareFunction("f", FunctionType.create(from: [], in: &m))
    XCTAssertEqual(m.values[f].basicBlocks.count, 0)
    XCTAssert(m.values[f].basicBlocks.elementsEqual([]))

    let b0 = m.appendBlock(to: f)
    let bb0 = m.basicBlocks[b0]
    XCTAssertEqual(m.values[f].basicBlocks.count, 1)
    XCTAssert(m.values[f].basicBlocks.elementsEqual([bb0]))

    let b1 = m.appendBlock(to: f)
    let bb1 = m.basicBlocks[b1]
    XCTAssertEqual(m.values[f].basicBlocks.count, 2)
    XCTAssert(m.values[f].basicBlocks.contains(bb0))
    XCTAssert(m.values[f].basicBlocks.contains(bb1))
  }

  func testBasicBlockIndices() {
    var m = Module("foo")
    let f = m.declareFunction("f", FunctionType.create(from: [], in: &m))
    XCTAssertEqual(m.values[f].basicBlocks.startIndex, m.values[f].basicBlocks.endIndex)

    m.appendBlock(to: f)
    XCTAssertEqual(
      m.values[f].basicBlocks.index(after: m.values[f].basicBlocks.startIndex),
      m.values[f].basicBlocks.endIndex)
    XCTAssertEqual(
      m.values[f].basicBlocks.index(before: m.values[f].basicBlocks.endIndex),
      m.values[f].basicBlocks.startIndex)

    m.appendBlock(to: f)
    let middle = m.values[f].basicBlocks.index(after: m.values[f].basicBlocks.startIndex)
    XCTAssertEqual(m.values[f].basicBlocks.index(after: middle), m.values[f].basicBlocks.endIndex)
    XCTAssertEqual(m.values[f].basicBlocks.index(before: m.values[f].basicBlocks.endIndex), middle)
  }

  func testAttributes() {
    var m = Module("foo")
    let f = m.declareFunction("f", FunctionType.create(from: [], in: &m))
    let a = m.createFunctionAttribute(.alwaysinline)
    let b = m.createFunctionAttribute(.hot)

    m.addFunctionAttribute(a, to: f)
    m.addFunctionAttribute(b, to: f)
    XCTAssertEqual(m.values[f].attributes.count, 2)
    XCTAssert(m.values[f].attributes.contains(m.attributes[a]))
    XCTAssert(m.values[f].attributes.contains(m.attributes[b]))

    XCTAssertEqual(m.addFunctionAttribute(named: .alwaysinline, to: f), a)

    m.removeFunctionAttribute(a, from: f)
    XCTAssertEqual(m.values[f].attributes, [m.attributes[b]])
  }

  func testReturnAttributes() {
    var m = Module("foo")
    let f = m.declareFunction("f", FunctionType.create(from: [], to: PointerType.create(in: &m).erased, in: &m))
    let r = m.values[f].returnValue
    let a = m.createReturnAttribute(.noalias)
    let b = m.createReturnAttribute(.dereferenceable_or_null, 8)

    m.addReturnAttribute(a, to: f)
    m.addReturnAttribute(b, to: f)
    XCTAssertEqual(r.attributes.count, 2)
    XCTAssert(r.attributes.contains(m.attributes[a]))
    XCTAssert(r.attributes.contains(m.attributes[b]))

    XCTAssertEqual(m.addReturnAttribute(named: .noalias, to: f), a)

    m.removeReturnAttribute(a, from: r)
    XCTAssertEqual(r.attributes, [m.attributes[b]])
  }

  func testConversion() {
    var m = Module("foo")
    let t: any IRValue = m.values[m.declareFunction("fn", FunctionType.create(from: [], in: &m))]
    XCTAssertNotNil(Function(t))
    let u: any IRValue = m.types[IntegerType.create(64, in: &m)].zero
    XCTAssertNil(Function(u))
  }

  func testEquality() {
    var m = Module("foo")
    let f = m.declareFunction("fn", FunctionType.create(from: [], in: &m))
    let g = m.declareFunction("fn", FunctionType.create(from: [], in: &m))
    XCTAssertEqual(f, g)

    let h = m.declareFunction("fn1", FunctionType.create(from: [], in: &m))
    XCTAssertNotEqual(f, h)
  }

  func testReturnEquality() {
    var m = Module("foo")
    let f = m.values[m.declareFunction("fn", FunctionType.create(from: [], in: &m))].returnValue
    let g = m.values[m.declareFunction("fn", FunctionType.create(from: [], in: &m))].returnValue
    XCTAssertEqual(f, g)

    let h = m.values[m.declareFunction("fn1", FunctionType.create(from: [], in: &m))].returnValue
    XCTAssertNotEqual(f, h)
  }

}
