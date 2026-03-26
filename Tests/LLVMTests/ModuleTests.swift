import XCTest

@testable import SwiftyLLVM

final class ModuleTests: XCTestCase {

  func testModuleName() throws {
    var m = try Module("foo")
    XCTAssertEqual(m.name, "foo")
    m.name = "bar"
    XCTAssertEqual(m.name, "bar")
  }

  func testTypeNamed() throws {
    var m = try Module("foo")
    let t = m.structType(named: "T", ())
    let u = try XCTUnwrap(m.type(named: "T"))
    XCTAssert(t.erased == u)
    XCTAssertNil(m.type(named: "U"))
  }

  func testFunctionNamed() throws {
    var m = try Module("foo")
    let f = m.declareFunction("fn", m.functionType(from: ()))
    let g = try XCTUnwrap(m.function(named: "fn"))
    XCTAssert(f == g)
    XCTAssertNil(m.type(named: "gn"))
  }

  func testIntrinsicNamed() throws {
    var m = try Module("foo")
    let f = try XCTUnwrap(m.intrinsic(named: IntrinsicFunction.llvm.trap))
    let g = try XCTUnwrap(m.intrinsic(named: IntrinsicFunction.llvm.trap))
    XCTAssert(f == g)
  }

  func testGlobalNamed() throws {
    var m = try Module("foo")
    let x = m.declareGlobalVariable("gl", m.ptr)
    let y = try XCTUnwrap(m.global(named: "gl"))
    XCTAssert(x == y)
    XCTAssertNil(m.type(named: "gn"))

    let z = m.declareGlobalVariable("gl", m.ptr)
    XCTAssert(x == z)
  }

  func testAddGlobalVariable() throws {
    var m = try Module("foo")
    let x = m.addGlobalVariable("g", m.ptr)
    let y = m.addGlobalVariable("g", m.ptr)
    XCTAssert(x != y)
  }

  func testVerify() throws {
    var m = try Module("foo")
    XCTAssertNoThrow(try m.verify())

    let f = m.declareFunction("fn", m.functionType(from: []))
    m.appendBlock(to: f)
    XCTAssertThrowsError(try m.verify())
  }

  func testCompile() throws {
    var m = try Module("foo")
    let i32 = m.integerType(32)

    let f = m.declareFunction("main", m.functionType(from: (), to: i32))
    let b = m.appendBlock(to: f)
    m.insertReturn(i32.unsafe[].zero, at: m.endOf(b))

    let a = try m.compile(.assembly)
    XCTAssert(a.count != 0)
  }

  func testStandardModulePasses() throws {
    var m = try Module("foo")
    let i32 = m.integerType(32)

    let f = m.declareFunction("main", m.functionType(from: (), to: i32))
    let b = m.appendBlock(to: f)
    m.insertReturn(m.i32.unsafe[].zero, at: m.endOf(b))

    m.runDefaultModulePasses()
  }

}
