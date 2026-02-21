import XCTest

@testable import SwiftyLLVM

final class GlobalVariableTests: XCTestCase {

  func testIsGlobalConstant() {
    var m = Module("foo")
    let g = m.declareGlobalVariable("gl", m.ptr)
    XCTAssertFalse(g.unsafePointee.isGlobalConstant)
    m.setGlobalConstant(true, for: g)
    XCTAssertTrue(g.unsafePointee.isGlobalConstant)
  }

  func testIsExternallyInitialized() {
    var m = Module("foo")
    let g = m.declareGlobalVariable("gl", m.ptr)
    XCTAssertFalse(g.unsafePointee.isExternallyInitialized)
    m.setExternallyInitialized(true, for: g)
    XCTAssertTrue(g.unsafePointee.isExternallyInitialized)
  }

  func testLinkage() {
    var m = Module("foo")
    let g = m.declareGlobalVariable("gl", m.ptr)
    m.setLinkage(.private, for: g)
    XCTAssertEqual(g.unsafePointee.linkage, .private)
  }

  func testInitializer() {
    var m = Module("foo")
    let i8id = m.integerType(8)
    let i8 = i8id.unsafePointee
    let g = m.declareGlobalVariable("x", i8id)

    let gv0 = g.unsafePointee
    XCTAssertNil(gv0.initializer)
    let z = i8.zero
    m.setInitializer(z, for: g)
    let gv1 = g.unsafePointee
    XCTAssertEqual(gv1.initializer.map { IntegerConstant($0.unsafePointee) }, i8.zero.unsafePointee)
  }

}
