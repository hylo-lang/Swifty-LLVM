import SwiftyLLVM
import XCTest

final class DataLayoutTests: XCTestCase {

  func testBitWidth() throws {
    try Context.withNew { (llvm) in
      let t = try TargetMachine(for: .host())
      let i32 = IntegerType(32, in: &llvm)
      XCTAssertEqual(t.layout.bitWidth(of: i32), 32)
    }
  }

  func testStorageSize() throws {
    try Context.withNew { (llvm) in
      let t = try TargetMachine(for: .host())
      let i32 = IntegerType(32, in: &llvm)
      XCTAssertEqual(t.layout.storageSize(of: i32), 4)
    }
  }

  func testStorageStride() throws {
    try Context.withNew { (llvm) in
      let t = try TargetMachine(for: .host())
      let i32 = IntegerType(32, in: &llvm)
      XCTAssertEqual(t.layout.storageStride(of: i32), 4)
    }
  }

  func testABIAlignment() throws {
    try Context.withNew { (llvm) in
      let t = try TargetMachine(for: .host())
      let i32 = IntegerType(32, in: &llvm)
      XCTAssertEqual(t.layout.abiAlignment(of: i32), 4)
    }
  }

  func testOffset() throws {
    try Context.withNew { (llvm) in
      let t = try TargetMachine(for: .host())

      let i32 = IntegerType(32, in: &llvm)
      let s = StructType([i32, i32], in: &llvm)
      XCTAssertEqual(t.layout.offset(of: 1, in: s), 4)
    }
  }

  func testIndex() throws {
    try Context.withNew { (llvm) in
      let t = try TargetMachine(for: .host())

      let i32 = IntegerType(32, in: &llvm)
      let s = StructType([i32, i32], in: &llvm)
      XCTAssertEqual(t.layout.index(at: 5, in: s), 1)
    }
  }

}
