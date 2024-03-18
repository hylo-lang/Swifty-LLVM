import SwiftyLLVM
import XCTest

final class AllocaTests: XCTestCase {

  func testAllocatedType() {
    withContextAndModule(named: "foo") { (llvm, m) in
      let f = m.declareFunction("fn", .init(from: [], in: &llvm))
      let b = m.appendBlock(to: f)
      let i = m.insertAlloca(IntegerType(64, in: &llvm), at: m.endOf(b))
      XCTAssert(i.allocatedType == IntegerType(64, in: &llvm))
    }
  }

  func testConversion() {
    withContextAndModule(named: "foo") { (llvm, m) in
      let f = m.declareFunction("fn", .init(from: [], in: &llvm))
      let b = m.appendBlock(to: f)
      let i: IRValue = m.insertAlloca(IntegerType(64, in: &llvm), at: m.endOf(b))
      XCTAssertNotNil(Alloca(i))
      let u: IRValue = IntegerType(64, in: &llvm).zero
      XCTAssertNil(Alloca(u))
    }
  }

}
