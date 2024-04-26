import SwiftyLLVM
import XCTest

final class TargetTests: XCTestCase {

  func testHostTargetName() throws {
    let h = try Target.host()
    let n = h.name
    XCTAssertFalse(n.isEmpty)
  }

}
