import SwiftyLLVM
import XCTest

final class AllocaTests: XCTestCase {

  func testAllocatedType() {
    var m = Module("foo")
    let f = m.declareFunction("fn", .init(from: [], in: &m))
    let b = m.appendBlock(to: f)
    let i = m.insertAlloca(IntegerType(64, in: &m), at: m.endOf(b))
    XCTAssert(i.allocatedType == IntegerType(64, in: &m))
  }

  func testConversion() {
    var m = Module("foo")
    let f = m.declareFunction("fn", .init(from: [], in: &m))
    let b = m.appendBlock(to: f)
    let i: IRValue = m.insertAlloca(IntegerType(64, in: &m), at: m.endOf(b))
    XCTAssertNotNil(Alloca(i))
    let u: IRValue = IntegerType(64, in: &m).zero
    XCTAssertNil(Alloca(u))
  }

}
