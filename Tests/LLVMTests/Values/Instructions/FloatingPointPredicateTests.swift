import XCTest

@testable import SwiftyLLVM

final class FloatingPointPredicateTests: XCTestCase {

  func testLosslessStringConvertible() {
    for p in FloatingPointPredicate.allCases {
      XCTAssertEqual(FloatingPointPredicate(p.description), p)
    }
    XCTAssertNil(FloatingPointPredicate("bogus"))
  }

  func testAllPredicatesVerification() throws {
    var m = try Module("foo")

    for p in FloatingPointPredicate.allCases {
      let f = m.declareFunction("f_\(p)", m.functionType(from: (m.double, m.double), to: m.i1))
      let b = m.appendBlock(to: f)

      let l = f.unsafe[].parameters[0]
      let r = f.unsafe[].parameters[1]

      m.insertReturn(m.insertFloatingPointComparison(p, l, r, at: m.endOf(b)), at: m.endOf(b))
    }

    XCTAssertNoThrow(try m.verify())
  }

}
