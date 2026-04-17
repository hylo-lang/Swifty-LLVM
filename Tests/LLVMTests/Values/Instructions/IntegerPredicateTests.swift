import XCTest

@testable import SwiftyLLVM

final class IntegerPredicateTests: XCTestCase {

  func testLosslessStringConvertible() {
    for p in IntegerPredicate.allCases {
      XCTAssertEqual(IntegerPredicate(p.description), p)
    }
    XCTAssertNil(IntegerPredicate("bogus"))
  }

  func testAllPredicatesVerification() throws {
    var m = try Module("foo")

    for p in IntegerPredicate.allCases {
      let f = m.declareFunction("f_\(p)", m.functionType(from: (m.i32, m.i32), to: m.i1))
      let b = m.appendBlock(to: f)

      let l = f.unsafe[].parameters[0]
      let r = f.unsafe[].parameters[1]

      m.insertReturn(m.insertIntegerComparison(p, l, r, at: m.endOf(b)), at: m.endOf(b))
    }

    XCTAssertNoThrow(try m.verify())
  }

}
