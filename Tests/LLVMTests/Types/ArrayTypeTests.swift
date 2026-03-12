import SwiftyLLVM
import XCTest

final class ArrayTypeTests: XCTestCase {

  func testCount() throws {
    var m = try Module("foo")
    let i16 = m.integerType(16)
    XCTAssertEqual(m.arrayType(8, i16).unsafe[].count, 8)
  }

  func testElement() throws {
    var m = try Module("foo")
    let i16 = m.i16
    XCTAssertEqual(IntegerType.UnsafeReference(m.arrayType(8, i16).unsafe[].element), i16)
  }

  func testConversion() throws {
    var m = try Module("foo")
    let i16 = m.integerType(16)
    
    let t = m.arrayType(8, i16)
    XCTAssertNotNil(ArrayType.UnsafeReference(t.erased))
    
    let u = m.integerType(64)
    XCTAssertNil(ArrayType.UnsafeReference(u.erased))
  }

  func testEquality() throws {
    var m = try Module("foo")
    let i16 = m.integerType(16)

    let t = m.arrayType(8, i16).unsafe[]
    let u = m.arrayType(8, i16).unsafe[]
    XCTAssertEqual(t, u)

    let v = m.arrayType(16, i16).unsafe[]
    XCTAssertNotEqual(t, v)
  }

}
