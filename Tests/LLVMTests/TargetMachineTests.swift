import LLVM
import XCTest

final class TargetMachineTests: XCTestCase {

  func testTarget() throws {
    let h = try Target.host()
    let t = TargetMachine(for: h)
    XCTAssertEqual(t.target, h)
  }

}
