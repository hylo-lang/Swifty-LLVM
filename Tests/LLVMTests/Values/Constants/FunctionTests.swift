
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

  func testEntry() {
    var m = Module("foo")
    let f = m.declareFunction("fn", .init(from: [], in: &m))
    XCTAssertNil(f.entry)
    m.appendBlock(to: f)
    XCTAssertNotNil(f.entry)
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

  func testBasicBlocks() {
    var m = Module("foo")

    let f = m.declareFunction("f", .init(from: [], in: &m))
    XCTAssertEqual(f.basicBlocks.count, 0)
    XCTAssert(f.basicBlocks.elementsEqual([]))

    let b0 = m.appendBlock(to: f)
    XCTAssertEqual(f.basicBlocks.count, 1)
    XCTAssert(f.basicBlocks.elementsEqual([b0]))

    let b1 = m.appendBlock(to: f)
    XCTAssertEqual(f.basicBlocks.count, 2)
    XCTAssert(f.basicBlocks.contains(b0))
    XCTAssert(f.basicBlocks.contains(b1))
  }

  func testBasicBlockIndices() {
    var m = Module("foo")
    let f = m.declareFunction("f", .init(from: [], in: &m))
    XCTAssertEqual(f.basicBlocks.startIndex, f.basicBlocks.endIndex)

    m.appendBlock(to: f)
    XCTAssertEqual(f.basicBlocks.index(after: f.basicBlocks.startIndex), f.basicBlocks.endIndex)
    XCTAssertEqual(f.basicBlocks.index(before: f.basicBlocks.endIndex), f.basicBlocks.startIndex)

    m.appendBlock(to: f)
    let middle = f.basicBlocks.index(after: f.basicBlocks.startIndex)
    XCTAssertEqual(f.basicBlocks.index(after: middle), f.basicBlocks.endIndex)
    XCTAssertEqual(f.basicBlocks.index(before: f.basicBlocks.endIndex), middle)
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

}
