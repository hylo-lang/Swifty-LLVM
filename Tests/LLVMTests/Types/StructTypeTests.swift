import SwiftyLLVM
import XCTest

final class StructTypeTests: XCTestCase {

  func testInlineStruct() {
    Context.withNew { (llvm) in
      let t = IntegerType(64, in: &llvm)
      let s = StructType([t, t], in: &llvm)
      XCTAssert(s.isLiteral)
      XCTAssertFalse(s.isPacked)
      XCTAssertFalse(s.isOpaque)
      XCTAssertNil(s.name)
    }
  }

  func testNamedStruct() {
    Context.withNew { (llvm) in
      let t = IntegerType(64, in: &llvm)
      let s = StructType(named: "S", [t, t], in: &llvm)
      XCTAssertFalse(s.isLiteral)
      XCTAssertFalse(s.isPacked)
      XCTAssertFalse(s.isOpaque)
      XCTAssertEqual(s.name, "S")
    }
  }

  func testPackedStruct() {
    Context.withNew { (llvm) in
      let t = IntegerType(64, in: &llvm)
      XCTAssert(StructType([t, t], packed: true, in: &llvm).isPacked)
      XCTAssert(StructType(named: "S", [t, t], packed: true, in: &llvm).isPacked)
    }
  }

  func testFields() {
    Context.withNew { (llvm) in
      let t = IntegerType(64, in: &llvm)
      let u = IntegerType(32, in: &llvm)

      let s0 = StructType([], in: &llvm)
      XCTAssertEqual(s0.fields.count, 0)

      let s1 = StructType([t], in: &llvm)
      XCTAssertEqual(s1.fields.count, 1)
      XCTAssert(s1.fields[0] == t)

      let s2 = StructType([t, u], in: &llvm)
      XCTAssertEqual(s2.fields.count, 2)
      XCTAssert(s2.fields[0] == t)
      XCTAssert(s2.fields[1] == u)
    }
  }

  func testConversion() {
    Context.withNew { (llvm) in
      let t: IRType = StructType([], in: &llvm)
      XCTAssertNotNil(StructType(t))
      let u: IRType = IntegerType(64, in: &llvm)
      XCTAssertNil(StructType(u))
    }
  }

  func testEquality() {
    Context.withNew { (llvm) in
      let t = IntegerType(64, in: &llvm)
      let u = IntegerType(32, in: &llvm)
      
      let s0 = StructType([t, u], in: &llvm)
      let s1 = StructType([t, u], in: &llvm)
      XCTAssertEqual(s0, s1)
      
      let s2 = StructType([u, t], in: &llvm)
      XCTAssertNotEqual(s0, s2)
    }
  }

  func testInstantiate() {
    Context.withNew { (llvm) in
      let t = StructType([llvm.i64, llvm.i32], in: &llvm)
      let a = t.constant(aggregating: [llvm.i64(1), llvm.i32(2)], in: &llvm)
      XCTAssertEqual(IntegerConstant(a[1]), llvm.i32(2))
    }
  }

}
