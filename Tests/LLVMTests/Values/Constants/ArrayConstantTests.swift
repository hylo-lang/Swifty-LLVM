import SwiftyLLVM
import XCTest

final class ArrayConstantTests: XCTestCase {

  func testInit() {
    Context.withNew { (llvm) in
      let i32 = IntegerType(32, in: &llvm)

      let a = ArrayConstant(
        of: i32, containing: (0 ..< 5).map({ i32.constant($0) }), in: &llvm)
      XCTAssertEqual(a.count, 5)
      XCTAssertEqual(IntegerConstant(a[1]), i32.constant(1))
      XCTAssertEqual(IntegerConstant(a[2]), i32.constant(2))
    }
  }

  func testInitFromBytes() {
    Context.withNew { (llvm) in
      let i8 = IntegerType(8, in: &llvm)
      let a = ArrayConstant(bytes: [0, 1, 2, 3, 4], in: &llvm)
      XCTAssertEqual(a.count, 5)
      XCTAssertEqual(IntegerConstant(a[1]), i8.constant(1))
      XCTAssertEqual(IntegerConstant(a[2]), i8.constant(2))
    }
  }

  func testEquality() {
    Context.withNew { (llvm) in
      let i32 = IntegerType(32, in: &llvm)

      let a = ArrayConstant(
        of: i32, containing: (0 ..< 5).map({ i32.constant($0) }), in: &llvm)
      let b = ArrayConstant(
        of: i32, containing: (0 ..< 5).map({ i32.constant($0) }), in: &llvm)
      XCTAssertEqual(a, b)

      let c = ArrayConstant(
        of: i32, containing: (0 ..< 5).map({ i32.constant($0 + 1) }), in: &llvm)
      XCTAssertNotEqual(a, c)
    }
  }

}
