@testable import SwiftyLLVM
import XCTest

final class PhiTests: XCTestCase {

  func testConversion() throws {
    var m = try Module("foo", targetMachine: .host())
    let f = m.declareFunction("fn", m.functionType(from: [m.i1.t, m.i32.t, m.i32.t]))

    let (i, _) = define(f, in: &m)
    XCTAssertNotNil(Phi.UnsafeReference(i.v))

    let u = m.i64.unsafe[].zero
    XCTAssertNil(Phi.UnsafeReference(u.v))
  }

  func testIncoming() throws {
    var m = try Module("foo", targetMachine: .host())
    let f = m.declareFunction("fn", m.functionType(from: [m.i1.t, m.i32.t, m.i32.t]))

    let (i, a) = define(f, in: &m)
    XCTAssertEqual(i.unsafe[].incoming.count, 2)

    let vs = i.unsafe[].incoming.map(\.value)
    XCTAssertEqual(vs[0].v, a[0].0)
    XCTAssertEqual(vs[1].v, a[1].0)

    let bs = i.unsafe[].incoming.reversed().map(\.block)
    XCTAssertEqual(bs[0], a[1].1)
    XCTAssertEqual(bs[1], a[0].1)
  }

  private func define(
    _ f: Function.UnsafeReference, in m: inout Module
  ) -> (Phi.UnsafeReference, [(AnyValue.UnsafeReference, BasicBlock.UnsafeReference)]) {
    let b0 = m.appendBlock(to: f)
    let b1 = m.appendBlock(to: f)
    let b2 = m.appendBlock(to: f)
    let b3 = m.appendBlock(to: f)

    var p = m.endOf(b0)
    m.insertCondBr(if: f.unsafe[].parameters[0], then: b1, else: b2, at: p)

    p = m.endOf(b1)
    let x = m.insertAdd(f.unsafe[].parameters[1], f.unsafe[].parameters[2], at: p)
    m.insertBr(to: b3, at: p)

    p = m.endOf(b2)
    let y = m.insertSub(f.unsafe[].parameters[1], f.unsafe[].parameters[2], at: p)
    m.insertBr(to: b3, at: p)

    p = m.endOf(b3)
    let a = [(x.v, b1), (y.v, b2)]
    let i = m.insertPhi(m.i32, merging: a, at: p)

    return (i, a)
  }

}
