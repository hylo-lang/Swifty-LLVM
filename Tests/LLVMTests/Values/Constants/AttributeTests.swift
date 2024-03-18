import SwiftyLLVM
import XCTest

final class AttributeTests: XCTestCase {

  func testEquality() {
    Context.withNew { (llvm) in
      let a = Function.Attribute(.cold, in: &llvm)
      let b = Function.Attribute(.cold, in: &llvm)
      XCTAssertEqual(a, b)
      
      let c = Function.Attribute(.hot, in: &llvm)
      XCTAssertNotEqual(a, c)
    }
  }

  func testValue() {
    Context.withNew { (llvm) in
      let a = Parameter.Attribute(.dereferenceable_or_null, 64, in: &llvm)
      XCTAssertEqual(a.value, 64)
    }
  }

}
