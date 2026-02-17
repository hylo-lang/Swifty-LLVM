@testable import SwiftyLLVM
import XCTest

final class AllocaTests: XCTestCase {

  func testAllocatedType() {
    var m = Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: []))
    let b = m.appendBlock(to: f)
    let i64 = m.integerType(64)
    let i = m.values[m.insertAlloca(i64, at: m.endOf(b))]
    XCTAssert(i.allocatedType == m.types[i64])
  }

  func testConversion() {
    var m = Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: []))
    let b = m.appendBlock(to: f)
    let i64 = m.integerType(64)
    let i = m.values[m.insertAlloca(i64, at: m.endOf(b))]
    XCTAssertNotNil(Alloca(i))
    let u: any IRValue = m.types[i64].zero
    XCTAssertNil(Alloca(u))
  }

}
