import XCTest

@testable import SwiftyLLVM

final class BasicBlockTests: XCTestCase {
  func testDescription() {
    var m = Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: ()))

    let b = m.appendBlock(named: "b", to: f)
    XCTAssertEqual(b.pointee.description, "b")
    XCTAssertEqual(b.pointee.name, "b")
  }
  func testEmptyNameDescription() {
    var m = Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: ()))

    let b = m.appendBlock(to: f)
    XCTAssertEqual(b.pointee.description, "<unnamed>")
    XCTAssertEqual(b.pointee.name, nil)
  }

  func testNamedBasicBlockLLCode() throws {
    var m = Module("foo")

    let f = m.declareFunction("doubleValue", m.functionType(from: (m.i32), to: m.i32))
    let b = m.appendBlock(named: "my_block", to: f)

    let double = m.insertAdd(
      f.pointee.parameters[0], f.pointee.parameters[0], at: m.endOf(b))
    m.insertReturn(double, at: m.endOf(b))
    XCTAssertEqual(
      m.llCode(),
      """
      ; ModuleID = 'foo'
      source_filename = "foo"

      define i32 @doubleValue(i32 %0) {
      my_block:
        %1 = add i32 %0, %0
        ret i32 %1
      }

      """)
  }

  func testEmptyNameLLCode() throws {
    var m = Module("foo")
    let f = m.declareFunction("doubleValue", m.functionType(from: (m.i32), to: m.i32))
    let b = m.appendBlock(to: f)

    let double = m.insertAdd(
      f.pointee.parameters[0], f.pointee.parameters[0], at: m.endOf(b))
    m.insertReturn(double, at: m.endOf(b))
    XCTAssertEqual(
      m.llCode(),
      """
      ; ModuleID = 'foo'
      source_filename = "foo"

      define i32 @doubleValue(i32 %0) {
        %2 = add i32 %0, %0
        ret i32 %2
      }

      """)
  }

  func testTwoUnnamedBlocksLLCode() throws {
    var m = Module("foo")
    let f = m.declareFunction("doubleValue", m.functionType(from: (m.i32), to: m.i32))
    let entry = m.appendBlock(to: f)
    let body = m.appendBlock(to: f)

    m.insertBr(to: body, at: m.endOf(entry))
    let double = m.insertAdd(
      f.pointee.parameters[0], f.pointee.parameters[0], at: m.endOf(body))
    m.insertReturn(double, at: m.endOf(body))

    XCTAssertEqual(entry.pointee.name, nil)
    XCTAssertEqual(body.pointee.name, nil)

    let ir = m.llCode()
    XCTAssertEqual(
      ir,
      """
      ; ModuleID = 'foo'
      source_filename = "foo"

      define i32 @doubleValue(i32 %0) {
        br label %2

      2:                                                ; preds = %1
        %3 = add i32 %0, %0
        ret i32 %3
      }

      """
    )
  }
}
