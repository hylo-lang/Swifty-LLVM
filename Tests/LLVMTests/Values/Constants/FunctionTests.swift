import SwiftyLLVM
import XCTest

final class FunctionTests: XCTestCase {

  func testWellFormed() {
    withContextAndModule(named: "foo") { (llvm, m) in
      let f = m.declareFunction("fn", .init(from: [], in: &llvm))
      XCTAssert(f.isWellFormed())
      m.appendBlock(to: f)
      XCTAssertFalse(f.isWellFormed())
    }
  }

  func testEntry() {
    withContextAndModule(named: "foo") { (llvm, m) in
      let f = m.declareFunction("fn", .init(from: [], in: &llvm))
      XCTAssertNil(f.entry)
      m.appendBlock(to: f)
      XCTAssertNotNil(f.entry)
    }
  }

  func testParameters() {
    withContextAndModule(named: "foo") { (llvm, m) in
      let t = IntegerType(64, in: &llvm)
      let u = IntegerType(32, in: &llvm)

      let f0 = m.declareFunction("f0", .init(from: [], in: &llvm))
      XCTAssertEqual(f0.parameters.count, 0)

      let f1 = m.declareFunction("f1", .init(from: [t], in: &llvm))
      XCTAssertEqual(f1.parameters.count, 1)
      XCTAssert(f1.parameters[0].type == t)

      let f2 = m.declareFunction("f2", .init(from: [t, u], in: &llvm))
      XCTAssertEqual(f2.parameters.count, 2)
      XCTAssert(f2.parameters[0].type == t)
      XCTAssert(f2.parameters[1].type == u)
    }
  }

  func testBasicBlocks() {
    withContextAndModule(named: "foo") { (llvm, m) in
      let f = m.declareFunction("f", .init(from: [], in: &llvm))
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
  }

  func testBasicBlockIndices() {
    withContextAndModule(named: "foo") { (llvm, m) in
      let f = m.declareFunction("f", .init(from: [], in: &llvm))
      XCTAssertEqual(f.basicBlocks.startIndex, f.basicBlocks.endIndex)

      m.appendBlock(to: f)
      XCTAssertEqual(f.basicBlocks.index(after: f.basicBlocks.startIndex), f.basicBlocks.endIndex)
      XCTAssertEqual(f.basicBlocks.index(before: f.basicBlocks.endIndex), f.basicBlocks.startIndex)

      m.appendBlock(to: f)
      let middle = f.basicBlocks.index(after: f.basicBlocks.startIndex)
      XCTAssertEqual(f.basicBlocks.index(after: middle), f.basicBlocks.endIndex)
      XCTAssertEqual(f.basicBlocks.index(before: f.basicBlocks.endIndex), middle)
    }
  }

  func testAttributes() {
    withContextAndModule(named: "foo") { (llvm, m) in
      let f = m.declareFunction("f", .init(from: [], in: &llvm))
      let a = Function.Attribute(.alwaysinline, in: &llvm)
      let b = Function.Attribute(.hot, in: &llvm)

      m.addAttribute(a, to: f)
      m.addAttribute(b, to: f)
      XCTAssertEqual(f.attributes.count, 2)
      XCTAssert(f.attributes.contains(a))
      XCTAssert(f.attributes.contains(b))

      m.removeAttribute(a, from: f)
      XCTAssertEqual(f.attributes, [b])
    }
  }

  func testReturnAttributes() {
    withContextAndModule(named: "foo") { (llvm, m) in
      let f = m.declareFunction("f", .init(from: [], to: PointerType(in: &llvm), in: &llvm))
      let r = f.returnValue
      let a = Function.Return.Attribute(.noalias, in: &llvm)
      let b = Parameter.Attribute(.dereferenceable_or_null, 8, in: &llvm)

      m.addAttribute(a, to: r)
      m.addAttribute(b, to: r)
      XCTAssertEqual(r.attributes.count, 2)
      XCTAssert(r.attributes.contains(a))
      XCTAssert(r.attributes.contains(b))

      m.removeAttribute(a, from: r)
      XCTAssertEqual(r.attributes, [b])
    }
  }

  func testConversion() {
    withContextAndModule(named: "foo") { (llvm, m) in
      let t: IRValue = m.declareFunction("fn", .init(from: [], in: &llvm))
      XCTAssertNotNil(Function(t))
      let u: IRValue = IntegerType(64, in: &llvm).zero
      XCTAssertNil(Function(u))
    }
  }

  func testEquality() {
    withContextAndModule(named: "foo") { (llvm, m) in
      let f = m.declareFunction("fn", .init(from: [], in: &llvm))
      let g = m.declareFunction("fn", .init(from: [], in: &llvm))
      XCTAssertEqual(f, g)

      let h = m.declareFunction("fn1", .init(from: [], in: &llvm))
      XCTAssertNotEqual(f, h)
    }
  }

  func testReturnEquality() {
    withContextAndModule(named: "foo") { (llvm, m) in
      let f = m.declareFunction("fn", .init(from: [], in: &llvm)).returnValue
      let g = m.declareFunction("fn", .init(from: [], in: &llvm)).returnValue
      XCTAssertEqual(f, g)

      let h = m.declareFunction("fn1", .init(from: [], in: &llvm)).returnValue
      XCTAssertNotEqual(f, h)
    }
  }

}
