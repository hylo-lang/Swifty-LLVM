@testable import SwiftyLLVM
import XCTest

final class AllocaTests: XCTestCase {

  func testAllocatedType() {
    var m = Module("foo")
    let f = m.declareFunction("fn", FunctionType.create(from: [], in: &m))
    let b = m.appendBlock(to: f)
    let i64 = IntegerType.create(64, in: &m)
    let i = m.insertAlloca(i64, at: m.endOf(b))
    XCTAssert(i.allocatedType == m.types[i64])
  }

  func testConversion() {
    var m = Module("foo")
    let f = m.declareFunction("fn", FunctionType.create(from: [], in: &m))
    let b = m.appendBlock(to: f)
    let i64 = IntegerType.create(64, in: &m)
    let i: any IRValue = m.insertAlloca(i64, at: m.endOf(b))
    XCTAssertNotNil(Alloca(i))
    let u: any IRValue = m.types[i64].zero
    XCTAssertNil(Alloca(u))
  }

}
