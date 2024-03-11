import SwiftyLLVM
import XCTest

final class IRValueTests: XCTestCase {

  func testName() {
    withContextAndModule(named: "foo") { (llvm, m) in
      let g = m.declareGlobalVariable("x", PointerType(in: &llvm))
      XCTAssertEqual(g.name, "x")
      m.setName("y", for: g)
      XCTAssertEqual(g.name, "y")
    }
  }

  func testIsNull() {
    Context.withNew { (llvm) in
      XCTAssert(IntegerType(64, in: &llvm).null.isNull)
      XCTAssertFalse(IntegerType(64, in: &llvm).constant(42).isNull)
    }
  }

  func testIsConstant() {
    withContextAndModule(named: "foo") { (llvm, m) in
      XCTAssert(IntegerType(64, in: &llvm).null.isConstant)

      let f = m.declareFunction("fn", .init(from: [], in: &llvm))
      let b = m.appendBlock(to: f)
      let i = m.insertAlloca(IntegerType(64, in: &llvm), at: m.endOf(b))
      XCTAssertFalse(i.isConstant)
    }
  }

  func testIsTerminator() {
    withContextAndModule(named: "foo") { (llvm, m) in
      let f = m.declareFunction("fn", .init(from: [], in: &llvm))
      let b = m.appendBlock(to: f)

      let p = m.endOf(b)
      let i = m.insertAlloca(IntegerType(64, in: &llvm), at: p)
      XCTAssertFalse(i.isTerminator)
      let j = m.insertReturn(at: p)
      XCTAssert(j.isTerminator)
    }
  }

  func testEqualty() {
    Context.withNew { (llvm) in
      let t = IntegerType(64, in: &llvm).null
      let u = IntegerType(32, in: &llvm).null

      XCTAssert(t == (t as IRValue))
      XCTAssert((t as IRValue) == t)
      XCTAssert((t as IRValue) == (t as IRValue))

      XCTAssert(t != (u as IRValue))
      XCTAssert((t as IRValue) != u)
      XCTAssert((t as IRValue) != (u as IRValue))
    }
  }

  func testStringConvertible() {
    Context.withNew { (llvm) in
      let t = IntegerType(64, in: &llvm).null
      XCTAssertEqual("\(t)", "\(t)", "Unstable string representation!")
    }
  }

}
