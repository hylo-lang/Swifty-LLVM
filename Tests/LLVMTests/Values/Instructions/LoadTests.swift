@testable import SwiftyLLVM
import XCTest

final class LoadTests: XCTestCase {

  func testAlignement() throws {
    var m = try Module("foo", targetMachine: .host())
    let i64 = m.integerType(64)

    let f = m.declareFunction("fn", m.functionType(from: []))
    let b = m.appendBlock(to: f)
    let i = m.insertAlloca(i64, at: m.endOf(b))
    m.setAlignment(32, for: i)
    m.insertStore(i64.unsafe[].constant(32), to: i, alignedAt: 32, at: m.endOf(b))

    // Default alignment at insertion.
    let s = m.insertLoad(i64, from: i, at: m.endOf(b))
    XCTAssertGreaterThanOrEqual(s.unsafe[].alignment, 1)

    // Modified alignment.
    m.setAlignment(16, for: s)
    XCTAssertEqual(s.unsafe[].alignment, 16)
  }

}
