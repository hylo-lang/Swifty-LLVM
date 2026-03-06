import SwiftyLLVM

import XCTest

final class DataLayoutTests: XCTestCase {

  func testBitWidth() throws {
    var m = Module("foo")
    let t = try TargetMachine(for: .host())

    let i32 = m.integerType(32)
    XCTAssertEqual(t.layout.bitWidth(of: i32), 32)
  }

  func testStorageSize() throws {
    var m = Module("foo")
    let t = try TargetMachine(for: .host())

    let i32 = m.integerType(32)
    XCTAssertEqual(t.layout.storageSize(of: i32), 4)
  }

  func testStorageStride() throws {
    var m = Module("foo")
    let t = try TargetMachine(for: .host())

    let i32 = m.integerType(32)
    XCTAssertEqual(t.layout.storageStride(of: i32), 4)
  }

  func testABIAlignment() throws {
    var m = Module("foo")
    let t = try TargetMachine(for: .host())

    let i32 = m.integerType(32)
    XCTAssertEqual(t.layout.abiAlignment(of: i32), 4)
  }

  func testOffset() throws {
    var m = Module("foo")
    let t = try TargetMachine(for: .host())

    let i32 = m.integerType(32)
    let s = m.structType((i32, i32))
    XCTAssertEqual(t.layout.offset(of: 1, in: s), 4)
  }

  func testIndex() throws {
    var m = Module("foo")
    let t = try TargetMachine(for: .host())

    let i32 = m.integerType(32)
    let s = m.structType((i32, i32))
    XCTAssertEqual(t.layout.index(at: 5, in: s), 1)
  }

  /// Asserts that for a given `type`
  ///  - The preferred alignment >= ABI alignment.
  ///  - The ABI alignment is a power of 2.
  ///  - The preferred alignment is a power of 2.
  func assertAlignmentInvariants(
    _ type: UnsafeReference<some IRType>, in layout: borrowing DataLayout, file: String = #file,
    line: Int = #line
  ) {
    let abiAlignment = layout.abiAlignment(of: type)
    let preferredAlignment = layout.preferredAlignment(of: type)

    XCTAssertGreaterThanOrEqual(preferredAlignment, abiAlignment)
    XCTAssertTrue(
      preferredAlignment & (preferredAlignment - 1) == 0, "preferred alignment must be a power of 2"
    )
    XCTAssertTrue(abiAlignment & (abiAlignment - 1) == 0, "abi alignment must be a power of 2")
  }

  func testAlignmentGuarantees() throws {
    var m = Module("foo")
    let layout = m.layout

    for i in 1...128 {
      assertAlignmentInvariants(m.integerType(i), in: layout)
    }

    // assertAlignmentInvariants(m.void, in: layout)
    assertAlignmentInvariants(m.half, in: layout)
    assertAlignmentInvariants(m.float, in: layout)
    assertAlignmentInvariants(m.double, in: layout)
    assertAlignmentInvariants(m.fp128, in: layout)
  }


}
