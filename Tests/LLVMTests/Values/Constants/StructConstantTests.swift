import SwiftyLLVM
import XCTest

final class StructConstantTests: XCTestCase {

  func testInitNamed() {
    var m = Module("foo")
    let i32 = m.integerType(32)

    let t = m.structType((i32, i32))
    let a = m.structConstant(
      of: t, aggregating: (i32.pointee.constant(4), i32.pointee.constant(2)))
    XCTAssertEqual(a.pointee.count, 2)
    XCTAssertEqual(StructType.UnsafeReference(a.pointee.type), t)
    XCTAssertEqual(IntegerConstant.UnsafeReference(a.pointee[0]), i32.pointee.constant(4))
    XCTAssertEqual(IntegerConstant.UnsafeReference(a.pointee[1]), i32.pointee.constant(2))
  }

  func testInitFromValues() throws {
    var m = Module("foo")
    let i32 = m.integerType(32)
    
    let a = m.structConstant(aggregating: (i32.pointee.constant(4), i32.pointee.constant(2)))
    XCTAssertEqual(a.pointee.count, 2)
    XCTAssertEqual(try XCTUnwrap(StructType.UnsafeReference(a.pointee.type)).pointee.isPacked, false)
    XCTAssertEqual(IntegerConstant.UnsafeReference(a.pointee[0]), i32.pointee.constant(4))
    XCTAssertEqual(IntegerConstant.UnsafeReference(a.pointee[1]), i32.pointee.constant(2))
  }

  func testInitFromValuesPacked() throws {
    var m = Module("foo")
    let i32 = m.integerType(32)
    
    let a = m.structConstant(aggregating: (i32.pointee.constant(4), i32.pointee.constant(2)), packed: true)
    XCTAssertEqual(a.pointee.count, 2)
    XCTAssertEqual(try XCTUnwrap(StructType.UnsafeReference(a.pointee.type)).pointee.isPacked, true)
    XCTAssertEqual(IntegerConstant.UnsafeReference(a.pointee[0]), i32.pointee.constant(4))
    XCTAssertEqual(IntegerConstant.UnsafeReference(a.pointee[1]), i32.pointee.constant(2))
  }

  func testEquality() {
    var m = Module("foo")
    let i32 = m.integerType(32)
    
    let a = m.structConstant(aggregating: (i32.pointee.constant(4), i32.pointee.constant(2)))
    let b = m.structConstant(aggregating: (i32.pointee.constant(4), i32.pointee.constant(2)))
    XCTAssertEqual(a, b)

    let c = m.structConstant(aggregating: (i32.pointee.constant(2), i32.pointee.constant(4)))
    XCTAssertNotEqual(a, c)
  }

}
