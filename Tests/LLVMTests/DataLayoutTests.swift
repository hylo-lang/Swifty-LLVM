import SwiftyLLVM

import XCTest

final class DataLayoutTests: XCTestCase {

  func testBitWidth() throws {
    var m = try Module("foo")

    let i32 = m.integerType(32)
    XCTAssertEqual(m.layout.bitWidth(of: i32), 32)
  }

  func testStorageSize() throws {
    var m = try Module("foo")

    let i32 = m.integerType(32)
    XCTAssertEqual(m.layout.storageSize(of: i32), 4)
  }

  func testStorageStride() throws {
    var m = try Module("foo")

    let i32 = m.integerType(32)
    XCTAssertEqual(m.layout.storageStride(of: i32), 4)
  }

  func testABIAlignment() throws {
    var m = try Module("foo")

    let i32 = m.integerType(32)
    XCTAssertEqual(m.layout.abiAlignment(of: i32), 4)
  }

  func testOffset() throws {
    var m = try Module("foo", targetMachine: .host())

    let i32 = m.integerType(32)
    let s = m.structType((i32, i32))
    XCTAssertEqual(m.layout.offset(of: 1, in: s), 4)
  }

  func testIndex() throws {
    var m = try Module("foo", targetMachine: .host())

    let i32 = m.integerType(32)
    let s = m.structType((i32, i32))
    XCTAssertEqual(m.layout.index(at: 5, in: s), 1)
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
    var m = try Module("foo")

    for i in 1...128 {
      assertAlignmentInvariants(m.integerType(i), in: m.layout)
    }

    // assertAlignmentInvariants(m.void, in: m.layout)
    assertAlignmentInvariants(m.half, in: m.layout)
    assertAlignmentInvariants(m.float, in: m.layout)
    assertAlignmentInvariants(m.double, in: m.layout)
    assertAlignmentInvariants(m.fp128, in: m.layout)
  }

  func testPointerSize() throws {
    let m = try Module("foo")

    XCTAssertEqual(m.layout.pointerSize, m.layout.storageSize(of: m.ptr))
    XCTAssertEqual(m.layout.pointerSize, MemoryLayout<UnsafeRawPointer>.size)
  }

  func testPointerSizedIntegerType() throws {
    let m = try Module("foo")

    let intptr = m.layout.pointerSizedIntegerType
    XCTAssertEqual(m.layout.storageSize(of: intptr), m.layout.pointerSize)
    XCTAssertEqual(m.layout.storageSize(of: intptr), MemoryLayout<UnsafeRawPointer>.size)
  }

  func testProgramAddressSpace() throws {
    let m = try Module("foo")

    XCTAssertEqual(m.layout.programAddressSpace, m.programAddressSpace)
    XCTAssertEqual(m.functionPointer.unsafe[].addressSpace, m.layout.programAddressSpace)

    // On the currently supported host platforms, function pointers are always in the default address space (arm64, amd64).
    // This may not hold for other targets, but we need to build LLVM with support for other targets to test those.
    XCTAssertEqual(m.layout.programAddressSpace.llvm, 0)
  }

}
