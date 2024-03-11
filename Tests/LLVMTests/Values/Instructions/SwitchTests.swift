import SwiftyLLVM
import XCTest

final class SwitchTests: XCTestCase {

  func testSwitch() {
    withContextAndModule(named: "foo") { (llvm, m) in
      let f = m.declareFunction("fn", .init(from: [], in: &llvm))
      let b = m.appendBlock(to: f)

      let c0 = m.appendBlock(to: f)
      let c1 = m.appendBlock(to: f)
      let c2 = m.appendBlock(to: f)

      _ = m.insertSwitch(
        on: llvm.i16(0),
        cases: [(llvm.i16(0), c0), (llvm.i16(1), c1)],
        default: c2,
        at: m.endOf(b))
    }
  }

}
