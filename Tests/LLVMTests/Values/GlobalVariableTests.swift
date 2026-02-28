import XCTest

@testable import SwiftyLLVM

final class GlobalVariableTests: XCTestCase {

  func testIsGlobalConstant() {
    var m = Module("foo")
    let g = m.declareGlobalVariable("gl", m.ptr)
    XCTAssertFalse(g.pointee.isGlobalConstant)
    m.setGlobalConstant(true, for: g)
    XCTAssertTrue(g.pointee.isGlobalConstant)
  }

  func testIsExternallyInitialized() {
    var m = Module("foo")
    let g = m.declareGlobalVariable("gl", m.ptr)
    XCTAssertFalse(g.pointee.isExternallyInitialized)
    m.setExternallyInitialized(true, for: g)
    XCTAssertTrue(g.pointee.isExternallyInitialized)
  }

  func testLinkage() {
    var m = Module("foo")
    let g = m.declareGlobalVariable("gl", m.ptr)
    m.setLinkage(.private, for: g)
    XCTAssertEqual(g.pointee.linkage, .private)
  }

  func testInitializer() throws {
    var m = Module("foo")
    let i8id = m.integerType(8)
    let i8 = i8id.pointee
    let g = m.declareGlobalVariable("x", i8id)

    let gv0 = g.pointee
    XCTAssertNil(gv0.initializer)
    let z = i8.zero
    m.setInitializer(z, for: g)
    let gv1 = g.pointee
    
    let i = try XCTUnwrap(gv1.initializer)
    XCTAssertEqual(IntegerConstant.UnsafeReference(i), i8.zero)
  }

}
