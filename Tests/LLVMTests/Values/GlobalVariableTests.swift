import SwiftyLLVM
import XCTest

final class GlobalVariableTests: XCTestCase {

  func testIsGlobalConstant() {
    withContextAndModule(named: "foo") { (llvm, m) in
      let g = m.declareGlobalVariable("gl", PointerType(in: &llvm))
      XCTAssertFalse(g.isGlobalConstant)
      m.setGlobalConstant(true, for: g)
      XCTAssert(g.isGlobalConstant)
    }
  }

  func testIsExternallyInitialized() {
    withContextAndModule(named: "foo") { (llvm, m) in
      let g = m.declareGlobalVariable("gl", PointerType(in: &llvm))
      XCTAssertFalse(g.isExternallyInitialized)
      m.setExternallyInitialized(true, for: g)
      XCTAssert(g.isExternallyInitialized)
    }
  }

  func testLinkage() {
    withContextAndModule(named: "foo") { (llvm, m) in
      let g = m.declareGlobalVariable("gl", PointerType(in: &llvm))
      m.setLinkage(.private, for: g)
      XCTAssertEqual(g.linkage, .private)
    }
  }

  func testInitializer() {
    withContextAndModule(named: "foo") { (llvm, m) in
      let i8 = IntegerType(8, in: &llvm)
      let g = m.declareGlobalVariable("x", i8)

      XCTAssertNil(g.initializer)
      m.setInitializer(i8.zero, for: g)
      XCTAssertEqual(g.initializer.map(IntegerConstant.init(_:)), i8.zero)
    }
  }

}
