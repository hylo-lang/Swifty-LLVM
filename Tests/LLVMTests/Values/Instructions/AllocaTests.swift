@testable import SwiftyLLVM
import XCTest

final class AllocaTests: XCTestCase {

  func testAllocatedType() {
    var m = Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: []))
    let b = m.appendBlock(to: f)
    let i64 = m.integerType(64)
    let i = m.insertAlloca(i64, at: m.endOf(b))
    XCTAssert(i.pointee.allocatedType == m.i64)
  }

  func testConversion() {
    var m = Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: []))
    let b = m.appendBlock(to: f)
    let i64 = m.integerType(64)

    let i = m.insertAlloca(i64, at: m.endOf(b))
    XCTAssertNotNil(Alloca.UnsafeReference(i.erased))

    let u = m.i64.pointee.zero
    XCTAssertNil(Alloca.UnsafeReference(u.erased))
  }

}
