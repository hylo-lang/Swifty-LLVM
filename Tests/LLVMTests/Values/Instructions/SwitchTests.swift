@testable import SwiftyLLVM
import XCTest

final class SwitchTests: XCTestCase {

  func testSwitch() {
    var m = Module("foo")
    let f = m.declareFunction("fn", FunctionType.create(from: [], in: &m))
    let b = m.appendBlock(to: f)

    let c0 = m.appendBlock(to: f)
    let c1 = m.appendBlock(to: f)
    let c2 = m.appendBlock(to: f)
    let i16 = m.types[m.i16]
    let z = i16.constant(0, in: &m)
    let o = i16.constant(1, in: &m)

    _ = m.insertSwitch(
      on: z,
      cases: [(z.erased, c0), (o.erased, c1)],
      default: c2,
      at: m.endOf(b))
  }

}
