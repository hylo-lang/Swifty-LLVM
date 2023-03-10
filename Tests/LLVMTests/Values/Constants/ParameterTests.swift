import LLVM
import XCTest

final class ParameterTests: XCTestCase {

  func testIndex() {
    var m = Module("foo")
    let i64 = IntegerType(64, in: &m)

    let f = m.declareFunction("fn", .init(from: [i64, i64], in: &m))
    XCTAssertEqual(f.parameters[0].index, 0)
    XCTAssertEqual(f.parameters[1].index, 1)

    let p = Parameter(f.parameters[1] as IRValue)
    XCTAssertEqual(p?.index, 1)
  }

  func testConversion() {
    var m = Module("foo")
    let i64 = IntegerType(64, in: &m)

    let p: IRValue = m.declareFunction("fn", .init(from: [i64], in: &m)).parameters[0]
    XCTAssertNotNil(Parameter(p))
    let q: IRValue = IntegerType(64, in: &m).zero
    XCTAssertNil(Parameter(q))
  }

  func testEquality() {
    var m = Module("foo")
    let i64 = IntegerType(64, in: &m)

    let p = m.declareFunction("fn", .init(from: [i64], in: &m)).parameters[0]
    let q = m.declareFunction("fn", .init(from: [i64], in: &m)).parameters[0]
    XCTAssertEqual(p, q)

    let r = m.declareFunction("fn1", .init(from: [i64], in: &m)).parameters[0]
    XCTAssertNotEqual(p, r)
  }

}
