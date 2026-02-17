import SwiftyLLVM
import XCTest

final class StructConstantTests: XCTestCase {

  func testInitNamed() {
    var m = Module("foo")
    let i32id = IntegerType.create(32, in: &m)
    let i32 = m.types[i32id]

    let t = m.types[StructType.create([i32id.erased, i32id.erased], in: &m)]
    let a = StructConstant(of: t, aggregating: [i32.constant(4), i32.constant(2)], in: &m)
    XCTAssertEqual(a.count, 2)
    XCTAssertEqual(StructType(a.type), t)
    XCTAssertEqual(IntegerConstant(a[0]), i32.constant(4))
    XCTAssertEqual(IntegerConstant(a[1]), i32.constant(2))
  }

  func testInitFromValues() throws {
    var m = Module("foo")
    let i32 = m.types[IntegerType.create(32, in: &m)]

    let a = StructConstant(aggregating: [i32.constant(4), i32.constant(2)], in: &m)
    XCTAssertEqual(a.count, 2)
    XCTAssertEqual(try XCTUnwrap(StructType(a.type)).isPacked, false)
    XCTAssertEqual(IntegerConstant(a[0]), i32.constant(4))
    XCTAssertEqual(IntegerConstant(a[1]), i32.constant(2))
  }

  func testInitFromValuesPacked() throws {
    var m = Module("foo")
    let i32 = m.types[IntegerType.create(32, in: &m)]

    let a = StructConstant(aggregating: [i32.constant(4), i32.constant(2)], packed: true, in: &m)
    XCTAssertEqual(a.count, 2)
    XCTAssertEqual(try XCTUnwrap(StructType(a.type)).isPacked, true)
    XCTAssertEqual(IntegerConstant(a[0]), i32.constant(4))
    XCTAssertEqual(IntegerConstant(a[1]), i32.constant(2))
  }

  func testEquality() {
    var m = Module("foo")
    let i32 = m.types[IntegerType.create(32, in: &m)]

    let a = StructConstant(aggregating: [i32.constant(4), i32.constant(2)], in: &m)
    let b = StructConstant(aggregating: [i32.constant(4), i32.constant(2)], in: &m)
    XCTAssertEqual(a, b)

    let c = StructConstant(aggregating: [i32.constant(2), i32.constant(4)], in: &m)
    XCTAssertNotEqual(a, c)
  }

}
