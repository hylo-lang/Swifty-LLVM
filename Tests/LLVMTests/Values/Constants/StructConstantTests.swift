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

  func testIteration() throws {
    var m = try Module("foo")
    let i32 = m.integerType(32)

    let elements = (0 ..< 4).map({ i32.unsafe[].constant($0) })
    let a = m.structConstant(
      aggregating: (elements[0], elements[1], elements[2], elements[3]))

    XCTAssertEqual(a.unsafe[].startIndex, 0)
    XCTAssertEqual(a.unsafe[].endIndex, 4)

    let forward = a.unsafe[].map({ IntegerConstant.UnsafeReference($0) })
    XCTAssertEqual(forward, elements)

    let backward = a.unsafe[].reversed().map({ IntegerConstant.UnsafeReference($0) })
    XCTAssertEqual(backward, elements.reversed())
  }

  func testEmptyStructIteration() throws {
    var m = try Module("foo")
    let t = m.structType(())
    let a = m.structConstant(of: t, aggregating: ())

    XCTAssertEqual(a.unsafe[].count, 0)
    XCTAssertEqual(a.unsafe[].startIndex, a.unsafe[].endIndex)
    XCTAssertTrue(a.unsafe[].isEmpty)
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
