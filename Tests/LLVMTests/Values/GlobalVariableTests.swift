import XCTest

@testable import SwiftyLLVM

final class GlobalVariableTests: XCTestCase {

  func testIsGlobalConstant() throws {
    var m = try Module("foo")
    let g = m.declareGlobalVariable("gl", m.ptr)
    XCTAssertFalse(g.unsafe[].isGlobalConstant)
    m.setGlobalConstant(true, for: g)
    XCTAssertTrue(g.unsafe[].isGlobalConstant)
  }

  func testIsExternallyInitialized() throws {
    var m = try Module("foo")
    let g = m.declareGlobalVariable("gl", m.ptr)
    XCTAssertFalse(g.unsafe[].isExternallyInitialized)
    m.setExternallyInitialized(true, for: g)
    XCTAssertTrue(g.unsafe[].isExternallyInitialized)
  }

  func testLinkage() throws {
    var m = try Module("foo")
    let g = m.declareGlobalVariable("gl", m.ptr)
    m.setLinkage(.private, for: g)
    XCTAssertEqual(g.unsafe[].linkage, .private)
  }

  func testInitializer() throws {
    var m = try Module("foo")
    let i8id = m.integerType(8)
    let i8 = i8id.unsafe[]
    let g = m.declareGlobalVariable("x", i8id)

    let gv0 = g.unsafe[]
    XCTAssertNil(gv0.initializer)
    let z = i8.zero
    m.setInitializer(z, for: g)
    let gv1 = g.unsafe[]
    
    let i = try XCTUnwrap(gv1.initializer)
    XCTAssertEqual(IntegerConstant.UnsafeReference(i), i8.zero)
  }

}
