import SwiftyLLVM
import XCTest

final class TargetMachineTests: XCTestCase {

  func testTarget() throws {
    let t = try TargetMachine(triple: Target.defaultTargetTriple)
    XCTAssertEqual(t.triple, Target.defaultTargetTriple)
  }

}
