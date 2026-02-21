@testable import SwiftyLLVM
import XCTest

final class AllocaTests: XCTestCase {

  func testAllocatedType() {
    var m = Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: []))
    let b = m.appendBlock(to: f)
    let i64 = m.integerType(64)
    let i = m.insertAlloca(i64, at: m.endOf(b))
    XCTAssert(i.unsafePointee.allocatedType.unsafePointee == m.i64.unsafePointee)
  }

  func testConversion() {
    var m = Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: []))
    let b = m.appendBlock(to: f)
    let i64 = m.integerType(64)
    let i = m.insertAlloca(i64, at: m.endOf(b))
    XCTAssertNotNil(Alloca(i.unsafePointee))
    let u: any IRValue = m.i64.unsafePointee.zero.unsafePointee
    XCTAssertNil(Alloca(u))
  }

}
