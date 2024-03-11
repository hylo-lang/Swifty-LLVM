import SwiftyLLVM
import XCTest

final class ParameterTests: XCTestCase {

  func testIndex() {
    withContextAndModule(named: "foo") { (llvm, m) in
      let i64 = IntegerType(64, in: &llvm)

      let f = m.declareFunction("fn", .init(from: [i64, i64], in: &llvm))
      XCTAssertEqual(f.parameters[0].index, 0)
      XCTAssertEqual(f.parameters[1].index, 1)

      let p = Parameter(f.parameters[1] as IRValue)
      XCTAssertEqual(p?.index, 1)
    }
  }

  func testParent() {
    withContextAndModule(named: "foo") { (llvm, m) in
      let i64 = IntegerType(64, in: &llvm)

      let f = m.declareFunction("fn", .init(from: [i64, i64], in: &llvm))
      XCTAssertEqual(f.parameters[0].parent, f)
    }
  }

  func testAttributes() {
    withContextAndModule(named: "foo") { (llvm, m) in
      let f = m.declareFunction("f", .init(from: [PointerType(in: &llvm)], in: &llvm))
      let p = f.parameters[0]
      let a = Parameter.Attribute(.nofree, in: &llvm)
      let b = Parameter.Attribute(.dereferenceable_or_null, 8, in: &llvm)

      m.addAttribute(a, to: p)
      m.addAttribute(b, to: p)
      XCTAssertEqual(p.attributes.count, 2)
      XCTAssert(p.attributes.contains(a))
      XCTAssert(p.attributes.contains(b))

      m.removeAttribute(a, from: p)
      XCTAssertEqual(p.attributes, [b])
    }
  }

  func testConversion() {
    withContextAndModule(named: "foo") { (llvm, m) in
      let i64 = IntegerType(64, in: &llvm)

      let p: IRValue = m.declareFunction("fn", .init(from: [i64], in: &llvm)).parameters[0]
      XCTAssertNotNil(Parameter(p))
      let q: IRValue = IntegerType(64, in: &llvm).zero
      XCTAssertNil(Parameter(q))
    }
  }

  func testEquality() {
    withContextAndModule(named: "foo") { (llvm, m) in
      let i64 = IntegerType(64, in: &llvm)

      let p = m.declareFunction("fn", .init(from: [i64], in: &llvm)).parameters[0]
      let q = m.declareFunction("fn", .init(from: [i64], in: &llvm)).parameters[0]
      XCTAssertEqual(p, q)

      let r = m.declareFunction("fn1", .init(from: [i64], in: &llvm)).parameters[0]
      XCTAssertNotEqual(p, r)
    }
  }

}
