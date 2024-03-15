import SwiftyLLVM
import XCTest

final class ArrayTypeTests: XCTestCase {

  func testCount() {
    Context.withNew { (llvm) in
      let i16 = IntegerType(16, in: &llvm)
      XCTAssertEqual(ArrayType(8, i16, in: &llvm).count, 8)
    }
  }

  func testElement() {
    Context.withNew { (llvm) in
      let i16 = IntegerType(16, in: &llvm)
      XCTAssertEqual(IntegerType(ArrayType(8, i16, in: &llvm).element), i16)
    }
  }

  func testConversion() {
    Context.withNew { (llvm) in
      let i16 = IntegerType(16, in: &llvm)
      
      let t: IRType = ArrayType(8, i16, in: &llvm)
      XCTAssertNotNil(ArrayType(t))
      
      let u: IRType = IntegerType(64, in: &llvm)
      XCTAssertNil(ArrayType(u))
    }
  }

  func testEquality() {
    Context.withNew { (llvm) in
      let i16 = IntegerType(16, in: &llvm)

      let t = ArrayType(8, i16, in: &llvm)
      let u = ArrayType(8, i16, in: &llvm)
      XCTAssertEqual(t, u)

      let v = ArrayType(16, i16, in: &llvm)
      XCTAssertNotEqual(t, v)
    }
  }

  func testInstantiate() {
    Context.withNew { (llvm) in
      let t = ArrayType(4, llvm.i64, in: &llvm)
      let a = t.constant(contentsOf: (0 ..< 3).map(llvm.i64.constant(_:)), in: &llvm)
      XCTAssertEqual(IntegerConstant(a[1]), llvm.i64(1))
    }
  }

}
