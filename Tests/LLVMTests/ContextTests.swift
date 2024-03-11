import SwiftyLLVM
import XCTest

final class ContextTests: XCTestCase {

  func testTypeNamed() throws {
    try Context.withNew { (llvm) in
      let t = StructType(named: "T", [], in: &llvm)
      let u = try XCTUnwrap(llvm.type(named: "T"))
      XCTAssert(t == u)
      XCTAssertNil(llvm.type(named: "U"))
    }
  }

}
