@testable import SwiftyLLVM
import XCTest

final class GlobalVariableTests: XCTestCase {

  func testIsGlobalConstant() {
    var m = Module("foo")
    let g = m.declareGlobalVariable("gl", m.ptr)
    XCTAssertFalse(m.values[g].isGlobalConstant)
    m.setGlobalConstant(true, for: g)
    XCTAssert(m.values[g].isGlobalConstant)
  }

  func testIsExternallyInitialized() {
    var m = Module("foo")
    let g = m.declareGlobalVariable("gl", m.ptr)
    let gv0 = m.values[g]
    XCTAssertFalse(gv0.isExternallyInitialized)
    m.setExternallyInitialized(true, for: g)
    let gv1 = m.values[g]
    XCTAssert(gv1.isExternallyInitialized)
  }

  func testLinkage() {
    var m = Module("foo")
    let g = m.declareGlobalVariable("gl", m.ptr)
    m.setLinkage(.private, for: g)
    let gv = m.values[g]
    XCTAssertEqual(gv.linkage, .private)
  }

  func testInitializer() {
    var m = Module("foo")
    let i8id = m.integerType(8)
    let i8 = m.types[i8id]
    let g = m.declareGlobalVariable("x", i8id)

    let gv0 = m.values[g]
    XCTAssertNil(gv0.initializer)
    let z = i8.zero(in: &m)
    m.setInitializer(z, for: g)
    let gv1 = m.values[g]
    XCTAssertEqual(gv1.initializer.map(IntegerConstant.init(_:)), i8.zero)
  }

}
