import SwiftyLLVM
import XCTest

final class StructConstantTests: XCTestCase {

  func testInitNamed() {
    Context.withNew { (llvm) in
      let i32 = IntegerType(32, in: &llvm)

      let t = StructType([i32, i32], in: &llvm)
      let a = StructConstant(of: t, aggregating: [i32(4), i32(2)], in: &llvm)
      XCTAssertEqual(a.count, 2)
      XCTAssertEqual(StructType(a.type), t)
      XCTAssertEqual(IntegerConstant(a[0]), i32.constant(4))
      XCTAssertEqual(IntegerConstant(a[1]), i32.constant(2))
    }
  }

  func testInitFromValues() {
    Context.withNew { (llvm) in
      let i32 = IntegerType(32, in: &llvm)

      let a = StructConstant(aggregating: [i32(4), i32(2)], in: &llvm)
      XCTAssertEqual(a.count, 2)
      XCTAssertEqual(StructType(a.type)!.isPacked, false)
      XCTAssertEqual(IntegerConstant(a[0]), i32.constant(4))
      XCTAssertEqual(IntegerConstant(a[1]), i32.constant(2))
    }
  }

  func testInitFromValuesPacked() {
    Context.withNew { (llvm) in
      let i32 = IntegerType(32, in: &llvm)

      let a = StructConstant(aggregating: [i32(4), i32(2)], packed: true, in: &llvm)
      XCTAssertEqual(a.count, 2)
      XCTAssertEqual(StructType(a.type)!.isPacked, true)
      XCTAssertEqual(IntegerConstant(a[0]), i32.constant(4))
      XCTAssertEqual(IntegerConstant(a[1]), i32.constant(2))
    }
  }

  func testEquality() {
    Context.withNew { (llvm) in
      let i32 = IntegerType(32, in: &llvm)

      let a = StructConstant(aggregating: [i32(4), i32(2)], in: &llvm)
      let b = StructConstant(aggregating: [i32(4), i32(2)], in: &llvm)
      XCTAssertEqual(a, b)

      let c = StructConstant(aggregating: [i32(2), i32(4)], in: &llvm)
      XCTAssertNotEqual(a, c)
    }
  }

}
