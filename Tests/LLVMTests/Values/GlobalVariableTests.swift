import LLVM
import XCTest

final class GlobalVariableTests: XCTestCase {

  func testIsGlobalConstant() {
    var m = Module("foo")
    let g = m.declareGlobalVariable("gl", PointerType(in: &m))
    XCTAssertFalse(g.isGlobalConstant)
    m.setGlobalConstant(true, for: g)
    XCTAssert(g.isGlobalConstant)
  }

  func testIsExternallyInitialized() {
    var m = Module("foo")
    let g = m.declareGlobalVariable("gl", PointerType(in: &m))
    XCTAssertFalse(g.isExternallyInitialized)
    m.setExternallyInitialized(true, for: g)
    XCTAssert(g.isExternallyInitialized)
  }

  func testLinkage() {
    var m = Module("foo")
    let g = m.declareGlobalVariable("gl", PointerType(in: &m))
    m.setLinkage(.private, for: g)
    XCTAssertEqual(g.linkage, .private)
  }

  func testInitializer() {
    var m = Module("foo")
    let i8 = IntegerType(8, in: &m)
    let g = m.declareGlobalVariable("x", i8)

    XCTAssertNil(g.initializer)
    m.setInitializer(i8.zero, for: g)
    XCTAssertEqual(g.initializer.map(IntegerConstant.init(_:)), i8.zero)
  }

}
