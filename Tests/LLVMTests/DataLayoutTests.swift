import LLVM
import XCTest

final class DataLayoutTests: XCTestCase {

  func testBitWidth() throws {
    var m = Module("foo")
    let t = try TargetMachine(for: .host())
    let l = DataLayout(t)

    let i32 = IntegerType(32, in: &m)
    XCTAssertEqual(l.bitWidth(of: i32), 32)
  }

  func testStorageSize() throws {
    var m = Module("foo")
    let t = try TargetMachine(for: .host())
    let l = DataLayout(t)

    let i32 = IntegerType(32, in: &m)
    XCTAssertEqual(l.storageSize(of: i32), 4)
  }

  func testStorageStride() throws {
    var m = Module("foo")
    let t = try TargetMachine(for: .host())
    let l = DataLayout(t)

    let i32 = IntegerType(32, in: &m)
    XCTAssertEqual(l.storageStride(of: i32), 4)
  }

  func testABIAlignment() throws {
    var m = Module("foo")
    let t = try TargetMachine(for: .host())
    let l = DataLayout(t)

    let i32 = IntegerType(32, in: &m)
    XCTAssertEqual(l.abiAlignment(of: i32), 4)
  }

  func testOffset() throws {
    var m = Module("foo")
    let t = try TargetMachine(for: .host())
    let l = DataLayout(t)

    let i32 = IntegerType(32, in: &m)
    let s = StructType([i32, i32], in: &m)
    XCTAssertEqual(l.offset(of: 1, in: s), 4)
  }

  func testIndex() throws {
    var m = Module("foo")
    let t = try TargetMachine(for: .host())
    let l = DataLayout(t)

    let i32 = IntegerType(32, in: &m)
    let s = StructType([i32, i32], in: &m)
    XCTAssertEqual(l.index(at: 5, in: s), 1)
  }

}
