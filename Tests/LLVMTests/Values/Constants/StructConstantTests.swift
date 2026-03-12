import SwiftyLLVM
import XCTest

final class StructConstantTests: XCTestCase {

  func testInitNamed() throws {
    var m = try Module("foo")
    let i32 = m.integerType(32)

    let t = m.structType((i32, i32))
    let a = m.structConstant(
      of: t, aggregating: (i32.unsafe[].constant(4), i32.unsafe[].constant(2)))
    XCTAssertEqual(a.unsafe[].count, 2)
    XCTAssertEqual(StructType.UnsafeReference(a.unsafe[].type), t)
    XCTAssertEqual(IntegerConstant.UnsafeReference(a.unsafe[][0]), i32.unsafe[].constant(4))
    XCTAssertEqual(IntegerConstant.UnsafeReference(a.unsafe[][1]), i32.unsafe[].constant(2))
  }

  func testInitFromValues() throws {
    var m = try Module("foo")
    let i32 = m.integerType(32)
    
    let a = m.structConstant(aggregating: (i32.unsafe[].constant(4), i32.unsafe[].constant(2)))
    XCTAssertEqual(a.unsafe[].count, 2)
    XCTAssertEqual(try XCTUnwrap(StructType.UnsafeReference(a.unsafe[].type)).unsafe[].isPacked, false)
    XCTAssertEqual(IntegerConstant.UnsafeReference(a.unsafe[][0]), i32.unsafe[].constant(4))
    XCTAssertEqual(IntegerConstant.UnsafeReference(a.unsafe[][1]), i32.unsafe[].constant(2))
  }

  func testInitFromValuesPacked() throws {
    var m = try Module("foo")
    let i32 = m.integerType(32)
    
    let a = m.structConstant(aggregating: (i32.unsafe[].constant(4), i32.unsafe[].constant(2)), packed: true)
    XCTAssertEqual(a.unsafe[].count, 2)
    XCTAssertEqual(try XCTUnwrap(StructType.UnsafeReference(a.unsafe[].type)).unsafe[].isPacked, true)
    XCTAssertEqual(IntegerConstant.UnsafeReference(a.unsafe[][0]), i32.unsafe[].constant(4))
    XCTAssertEqual(IntegerConstant.UnsafeReference(a.unsafe[][1]), i32.unsafe[].constant(2))
  }

  func testEquality() throws {
    var m = try Module("foo")
    let i32 = m.integerType(32)
    
    let a = m.structConstant(aggregating: (i32.unsafe[].constant(4), i32.unsafe[].constant(2)))
    let b = m.structConstant(aggregating: (i32.unsafe[].constant(4), i32.unsafe[].constant(2)))
    XCTAssertEqual(a, b)

    let c = m.structConstant(aggregating: (i32.unsafe[].constant(2), i32.unsafe[].constant(4)))
    XCTAssertNotEqual(a, c)
  }

}
