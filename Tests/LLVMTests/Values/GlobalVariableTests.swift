import LLVM
import XCTest

final class GlobalVariableTests: XCTestCase {

  func testIsGlobalConstant() {
    var m = Module("foo")
    var g = m.declareGlobalVariable("gl", PointerType(in: &m))
    XCTAssertFalse(g.isGlobalConstant)
    g.isGlobalConstant = true
    XCTAssert(g.isGlobalConstant)
  }

  func testIsExternallyInitialized() {
    var m = Module("foo")
    var g = m.declareGlobalVariable("gl", PointerType(in: &m))
    XCTAssertFalse(g.isExternallyInitialized)
    g.isExternallyInitialized = true
    XCTAssert(g.isExternallyInitialized)
  }

  func testInitializer() {
    var m = Module("foo")
    let i8 = IntegerType(8, in: &m)
    var g = m.declareGlobalVariable("x", i8)

    XCTAssertNil(g.initializer)
    g.initializer = i8.zero
    XCTAssertEqual(g.initializer.map(IntegerConstant.init(_:)), i8.zero)
    g.initializer = nil
    XCTAssertNil(g.initializer)
  }

}
