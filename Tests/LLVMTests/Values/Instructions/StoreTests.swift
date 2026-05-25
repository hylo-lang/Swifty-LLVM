@testable import SwiftyLLVM
import XCTest

final class StoreTests: XCTestCase {

  func testAlignement() throws {
    var m = try Module("foo", targetMachine: .host())
    let i64 = m.integerType(64)

    let f = m.declareFunction("fn", m.functionType(from: []))
    let b = m.appendBlock(to: f)
    let i = m.insertAlloca(i64, at: m.endOf(b))
    m.setAlignment(32, for: i)

    // Custom alignment at insertion.
    let s0 = m.insertStore(i64.unsafe[].constant(32), to: i, alignedAt: 32, at: m.endOf(b))
    XCTAssertEqual(s0.unsafe[].alignment, 32)

    // Modified alignment.
    m.setAlignment(16, for: s0)
    XCTAssertEqual(s0.unsafe[].alignment, 16)

    // Default alignment at insertion.
    let s1 = m.insertStore(i64.unsafe[].constant(32), to: i, at: m.endOf(b))
    XCTAssertEqual(s1.unsafe[].alignment, m.layout.preferredAlignment(of: i64))
  }


  func testConversion() throws {
    var m = try Module("foo", targetMachine: .host())
    let i64 = m.integerType(64)

    let f = m.declareFunction("fn", m.functionType(from: []))
    let b = m.appendBlock(to: f)
    let i = m.insertAlloca(i64, at: m.endOf(b))

    let s = m.insertStore(i64.unsafe[].constant(32), to: i, at: m.endOf(b))
    XCTAssertNotNil(Store.UnsafeReference(s.erased))

    let u = m.i64.unsafe[].zero
    XCTAssertNil(Store.UnsafeReference(u.erased))
  }

}
