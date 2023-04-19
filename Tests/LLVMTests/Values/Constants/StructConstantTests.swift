import LLVM
import XCTest

final class StructConstantTests: XCTestCase {

  func testInitNamed() {
    var m = Module("foo")
    let i32 = IntegerType(32, in: &m)

    let t = StructType([i32, i32], in: &m)
    let a = StructConstant(of: t, aggregating: [i32.constant(4), i32.constant(2)], in: &m)
    XCTAssertEqual(a.count, 2)
    XCTAssertEqual(StructType(a.type), t)
    XCTAssertEqual(IntegerConstant(a[0]), i32.constant(4))
    XCTAssertEqual(IntegerConstant(a[1]), i32.constant(2))
  }

  func testInitFromValues() {
    var m = Module("foo")
    let i32 = IntegerType(32, in: &m)

    let a = StructConstant(aggregating: [i32.constant(4), i32.constant(2)], in: &m)
    XCTAssertEqual(a.count, 2)
    XCTAssertEqual(StructType(a.type)!.isPacked, false)
    XCTAssertEqual(IntegerConstant(a[0]), i32.constant(4))
    XCTAssertEqual(IntegerConstant(a[1]), i32.constant(2))
  }

  func testInitFromValuesPacked() {
    var m = Module("foo")
    let i32 = IntegerType(32, in: &m)

    let a = StructConstant(aggregating: [i32.constant(4), i32.constant(2)], packed: true, in: &m)
    XCTAssertEqual(a.count, 2)
    XCTAssertEqual(StructType(a.type)!.isPacked, true)
    XCTAssertEqual(IntegerConstant(a[0]), i32.constant(4))
    XCTAssertEqual(IntegerConstant(a[1]), i32.constant(2))
  }

  func testEquality() {
    var m = Module("foo")
    let i32 = IntegerType(32, in: &m)

    let a = StructConstant(aggregating: [i32.constant(4), i32.constant(2)], in: &m)
    let b = StructConstant(aggregating: [i32.constant(4), i32.constant(2)], in: &m)
    XCTAssertEqual(a, b)

    let c = StructConstant(aggregating: [i32.constant(2), i32.constant(4)], in: &m)
    XCTAssertNotEqual(a, c)
  }

}
