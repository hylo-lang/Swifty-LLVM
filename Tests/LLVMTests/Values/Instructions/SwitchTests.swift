import SwiftyLLVM
import XCTest

final class SwitchTests: XCTestCase {

  func testSwitch() {
    var m = Module("foo")
    let f = m.declareFunction("fn", .init(from: [], in: &m))
    let b = m.appendBlock(to: f)

    let c0 = m.appendBlock(to: f)
    let c1 = m.appendBlock(to: f)
    let c2 = m.appendBlock(to: f)

    _ = m.insertSwitch(
      on: m.i16(0),
      cases: [(m.i16(0), c0), (m.i16(1), c1)],
      default: c2,
      at: m.endOf(b))
  }

}
