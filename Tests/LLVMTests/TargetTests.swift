import SwiftyLLVM
import XCTest

final class TargetTests: XCTestCase {

  func testHostTargetNameCopyValidity() throws {
    // Check that a copy of the target name can still be used after the lifetime
    // of the Target ends.
    let h = try Target.host()
    let n = h.name
    XCTAssertFalse(n.isEmpty)
  }

}
