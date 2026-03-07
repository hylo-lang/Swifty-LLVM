import XCTest

@testable import SwiftyLLVM

final class SwitchTests: XCTestCase {

  func testSwitch() {
    var m = Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: []))
    let b = m.appendBlock(to: f)

    let c0 = m.appendBlock(to: f)
    let c1 = m.appendBlock(to: f)
    let c2 = m.appendBlock(to: f)
    let i16 = m.i16.pointee
    let z = i16.constant(0)
    let o = i16.constant(1)

    _ = m.insertSwitch(
      on: z,
      cases: ((z, c0), (o, c1)),
      default: c2,
      at: m.endOf(b))
  }

}
