
import LLVM
import XCTest

final class ParameterTests: XCTestCase {

  func testConversion() {
    var m = Module("foo")
    let i64 = IntegerType(64, in: &m)

    let t: IRValue = m.declareFunction("fn", .init(from: [i64], in: &m)).parameters[0]
    XCTAssertNotNil(Parameter(t))
    let u: IRValue = IntegerType(64, in: &m).zero
    XCTAssertNil(Parameter(u))
  }

  func testEquality() {
    var m = Module("foo")
    let i64 = IntegerType(64, in: &m)

    let f = m.declareFunction("fn", .init(from: [i64], in: &m)).parameters[0]
    let g = m.declareFunction("fn", .init(from: [i64], in: &m)).parameters[0]
    XCTAssertEqual(f, g)

    let h = m.declareFunction("fn1", .init(from: [i64], in: &m)).parameters[0]
    XCTAssertNotEqual(f, h)
  }

}
