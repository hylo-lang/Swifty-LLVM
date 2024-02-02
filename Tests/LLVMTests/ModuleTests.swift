import SwiftyLLVM
import XCTest

final class ModuleTests: XCTestCase {

  func testModuleName() {
    var m = Module("foo")
    XCTAssertEqual(m.name, "foo")
    m.name = "bar"
    XCTAssertEqual(m.name, "bar")
  }

  func testTypeNamed() throws {
    var m = Module("foo")
    let t = StructType(named: "T", [], in: &m)
    let u = try XCTUnwrap(m.type(named: "T"))
    XCTAssert(t == u)
    XCTAssertNil(m.type(named: "U"))
  }

  func testFunctionNamed() throws {
    var m = Module("foo")
    let f = m.declareFunction("fn", FunctionType(from: [], in: &m))
    let g = try XCTUnwrap(m.function(named: "fn"))
    XCTAssert(f == g)
    XCTAssertNil(m.type(named: "gn"))
  }

  func testGlobalNamed() throws {
    var m = Module("foo")
    let x = m.declareGlobalVariable("gl", PointerType(in: &m))
    let y = try XCTUnwrap(m.global(named: "gl"))
    XCTAssert(x == y)
    XCTAssertNil(m.type(named: "gn"))
  }

  func testAddGlobalVariable() {
    var m = Module("foo")
    let x = m.addGlobalVariable("g", PointerType(in: &m))
    let y = m.addGlobalVariable("g", PointerType(in: &m))
    XCTAssert(x != y)
  }

  func testVerify() {
    var m = Module("foo")
    XCTAssertNoThrow(try m.verify())

    let f = m.declareFunction("fn", .init(from: [], in: &m))
    m.appendBlock(to: f)
    XCTAssertThrowsError(try m.verify())
  }

  func testCompile() throws {
    var m = Module("foo")
    let i32 = IntegerType(32, in: &m)

    let f = m.declareFunction("main", .init(from: [], to: i32, in: &m))
    let b = m.appendBlock(to: f)
    m.insertReturn(i32.zero, at: m.endOf(b))

    let t = try TargetMachine(for: .host())
    let a = try m.compile(.assembly, for: t)
    XCTAssert(a.count != 0)
  }

  func testStandardModulePasses() throws {
    var m = Module("foo")
    let i32 = IntegerType(32, in: &m)

    let f = m.declareFunction("main", .init(from: [], to: i32, in: &m))
    let b = m.appendBlock(to: f)
    m.insertReturn(i32.zero, at: m.endOf(b))

    let h = try Target.host()
    m.runDefaultModulePasses(for: TargetMachine(for: h))
  }

}
