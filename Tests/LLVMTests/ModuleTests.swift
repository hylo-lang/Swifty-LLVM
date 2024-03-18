import SwiftyLLVM
import XCTest

final class ModuleTests: XCTestCase {

  func testModuleName() {
    withContextAndModule(named: "foo") { (_, m) in
      XCTAssertEqual(m.name, "foo")
      m.name = "bar"
      XCTAssertEqual(m.name, "bar")
    }
  }

  func testFunctionNamed() throws {
    try withContextAndModule(named: "foo") { (llvm, m) in
      let f = m.declareFunction("fn", FunctionType(from: [], in: &llvm))
      let g = try XCTUnwrap(m.function(named: "fn"))
      XCTAssert(f == g)
    }
  }

  func testGlobalNamed() throws {
    try withContextAndModule(named: "foo") { (llvm, m) in
      let x = m.declareGlobalVariable("gl", PointerType(in: &llvm))
      let y = try XCTUnwrap(m.global(named: "gl"))
      XCTAssert(x == y)
    }
  }

  func testAddGlobalVariable() {
    withContextAndModule(named: "foo") { (llvm, m) in
      let x = m.addGlobalVariable("g", PointerType(in: &llvm))
      let y = m.addGlobalVariable("g", PointerType(in: &llvm))
      XCTAssert(x != y)
    }
  }

  func testVerify() throws {
    try withContextAndModule(named: "foo") { (llvm, m) in
      XCTAssertNoThrow(try m.verify())

      let f = m.declareFunction("fn", .init(from: [], in: &llvm))
      m.appendBlock(to: f)
      XCTAssertThrowsError(try m.verify())
    }
  }

  func testCompile() throws {
    try withContextAndModule(named: "foo") { (llvm, m) in
      let i32 = IntegerType(32, in: &llvm)

      let f = m.declareFunction("main", .init(from: [], to: i32, in: &llvm))
      let b = m.appendBlock(to: f)
      m.insertReturn(i32.zero, at: m.endOf(b))

      let t = try TargetMachine(for: .host())
      let a = try m.compile(.assembly, for: t)
      XCTAssert(a.count != 0)
    }
  }

  func testStandardModulePasses() throws {
    try withContextAndModule(named: "foo") { (llvm, m) in
      let i32 = IntegerType(32, in: &llvm)

      let f = m.declareFunction("main", .init(from: [], to: i32, in: &llvm))
      let b = m.appendBlock(to: f)
      m.insertReturn(i32.zero, at: m.endOf(b))

      let h = try Target.host()
      m.runDefaultModulePasses(for: TargetMachine(for: h))
    }
  }

}
