import XCTest

@testable import SwiftyLLVM

final class FunctionTests: XCTestCase {

  func testWellFormed() throws {
    var m = try Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: ()))
    XCTAssert(f.unsafe[].isWellFormed())
    m.appendBlock(to: f)
    XCTAssertFalse(f.unsafe[].isWellFormed())
  }

  func testEntry() throws {
    var m = try Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: ()))
    XCTAssertNil(f.unsafe[].entry)
    m.appendBlock(to: f)
    XCTAssertNotNil(f.unsafe[].entry)
  }

  func testParameters() throws {
    var m = try Module("foo")
    let t = m.i64
    let u = m.i32

    let f0 = m.declareFunction("f0", m.functionType(from: ()))
    XCTAssertEqual(f0.unsafe[].parameters.count, 0)

    let f1 = m.declareFunction("f1", m.functionType(from: (m.i64)))
    XCTAssertEqual(f1.unsafe[].parameters.count, 1)
    XCTAssert(f1.unsafe[].parameters[0].unsafe[].type == t.erased)

    let f2 = m.declareFunction("f2", m.functionType(from: (m.i64, m.i32)))
    XCTAssertEqual(f2.unsafe[].parameters.count, 2)
    XCTAssert(f2.unsafe[].parameters[0].unsafe[].type == t.erased)
    XCTAssert(f2.unsafe[].parameters[1].unsafe[].type == u.erased)
  }

  func testBasicBlocks() throws {
    var m = try Module("foo")

    let f = m.declareFunction("f", m.functionType(from: ()))
    XCTAssertEqual(f.unsafe[].basicBlocks.count, 0)
    XCTAssert(f.unsafe[].basicBlocks.elementsEqual([]))

    let b0 = m.appendBlock(to: f)
    XCTAssertEqual(f.unsafe[].basicBlocks.count, 1)
    XCTAssert(f.unsafe[].basicBlocks.elementsEqual([b0]))

    let b1 = m.appendBlock(to: f)
    XCTAssertEqual(f.unsafe[].basicBlocks.count, 2)
    XCTAssert(f.unsafe[].basicBlocks.contains(b0))
    XCTAssert(f.unsafe[].basicBlocks.contains(b1))
  }

  func testBasicBlockIndices() throws {
    var m = try Module("foo")
    let f = m.declareFunction("f", m.functionType(from: ()))
    XCTAssertEqual(f.unsafe[].basicBlocks.startIndex, f.unsafe[].basicBlocks.endIndex)

    m.appendBlock(to: f)
    XCTAssertEqual(
      f.unsafe[].basicBlocks.index(after: f.unsafe[].basicBlocks.startIndex),
      f.unsafe[].basicBlocks.endIndex)
    XCTAssertEqual(
      f.unsafe[].basicBlocks.index(before: f.unsafe[].basicBlocks.endIndex),
      f.unsafe[].basicBlocks.startIndex)

    m.appendBlock(to: f)
    let middle = f.unsafe[].basicBlocks.index(after: f.unsafe[].basicBlocks.startIndex)
    XCTAssertEqual(
      f.unsafe[].basicBlocks.index(after: middle), f.unsafe[].basicBlocks.endIndex)
    XCTAssertEqual(
      f.unsafe[].basicBlocks.index(before: f.unsafe[].basicBlocks.endIndex), middle)
  }

  func testAttributes() throws {
    var m = try Module("foo")
    let f = m.declareFunction("f", m.functionType(from: ()))
    let a = m.functionAttribute(.alwaysinline)
    let b = m.functionAttribute(.hot)

    m.addFunctionAttribute(a, to: f)
    m.addFunctionAttribute(b, to: f)
    XCTAssertEqual(f.unsafe[].attributes.count, 2)
    XCTAssert(f.unsafe[].attributes.contains(a.erased))
    XCTAssert(f.unsafe[].attributes.contains(b.erased))

    XCTAssertEqual(m.addFunctionAttribute(named: .alwaysinline, to: f), a)

    m.removeFunctionAttribute(a, from: f)
    XCTAssertEqual(f.unsafe[].attributes, [b.erased])
  }

  func testReturnAttributes() throws {
    var m = try Module("foo")
    let f = m.declareFunction("f", m.functionType(from: (), to: m.ptr))
    let r = f.unsafe[].returnValue
    let a = m.returnAttribute(.noalias)
    let b = m.returnAttribute(.dereferenceable_or_null, 8)

    m.addReturnAttribute(a, to: f)
    m.addReturnAttribute(b, to: f)
    XCTAssertEqual(r.attributes.count, 2)
    XCTAssert(r.attributes.contains(a))
    XCTAssert(r.attributes.contains(b))

    XCTAssertEqual(m.addReturnAttribute(named: .noalias, to: f), a)

    m.removeReturnAttribute(a, from: r)
    XCTAssertEqual(r.attributes, [b])
  }

  func testConversion() throws {
    var m = try Module("foo")

    let t = m.declareFunction("fn", m.functionType(from: ()))
    XCTAssertNotNil(Function.UnsafeReference(t.erased))

    let u = m.integerType(64).unsafe[].zero
    XCTAssertNil(Function.UnsafeReference(u.erased))
  }

  func testEquality() throws {
    var m = try Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: ()))
    let g = m.declareFunction("fn", m.functionType(from: ()))
    XCTAssertEqual(f, g)

    let h = m.declareFunction("fn1", m.functionType(from: ()))
    XCTAssertNotEqual(f, h)
  }

  func testReturnEquality() throws {
    var m = try Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: ())).unsafe[].returnValue
    let g = m.declareFunction("fn", m.functionType(from: ())).unsafe[].returnValue
    XCTAssertEqual(f, g)

    let h = m.declareFunction("fn1", m.functionType(from: ())).unsafe[].returnValue
    XCTAssertNotEqual(f, h)
  }

  func testFunctionValueAsArgument() throws {
    // Note: This test may fail on other targets where the program address space isn't the default one.
    // In that case, adjust the test for the given platform.

    // Equivalent Swift:
    //
    //     func identity(_ x: Int32) -> Int32 { x }
    //     func apply(_ f: (Int32) -> Int32, _ x: Int32) -> Int32 { f(x) }
    //     func main() -> Int32 { apply(identity, 42) }
    var m = try Module("foo")

    let unaryI32FunctionType = m.functionType(from: (m.i32), to: m.i32)

    let identity = m.declareFunction("identity", unaryI32FunctionType)
    let identityEntry = m.appendBlock(to: identity)
    m.insertReturn(identity.unsafe[].parameters[0], at: m.endOf(identityEntry))

    let apply = m.declareFunction(
      "apply", m.functionType(from: (m.functionPointer, m.i32), to: m.i32))
    let applyEntry = m.appendBlock(to: apply)
    let forwardedResult = m.insertCall(
      apply.unsafe[].parameters[0].erased,
      typed: unaryI32FunctionType,
      on: (apply.unsafe[].parameters[1]),
      at: m.endOf(applyEntry))
    m.insertReturn(forwardedResult, at: m.endOf(applyEntry))

    let main = m.declareFunction("main", m.functionType(from: (), to: m.i32))
    let mainEntry = m.appendBlock(to: main)
    let result = m.insertCall(
      apply,
      on: (identity, m.i32.unsafe[].constant(42)),
      at: m.endOf(mainEntry))
    m.insertReturn(result, at: m.endOf(mainEntry))

    XCTAssertNoThrow(try m.verify())

    XCTAssertEqual(
      m.llCode(),
      """
      ; ModuleID = 'foo'
      source_filename = "foo"

      define i32 @identity(i32 %0) {
        ret i32 %0
      }

      define i32 @apply(ptr %0, i32 %1) {
        %3 = call i32 %0(i32 %1)
        ret i32 %3
      }

      define i32 @main() {
        %1 = call i32 @apply(ptr @identity, i32 42)
        ret i32 %1
      }

      """)
  }

}
