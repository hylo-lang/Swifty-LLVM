import LLVM
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

  func testVerify() {
    var m = Module("foo")
    XCTAssertNoThrow(try m.verify())

    let f = m.declareFunction("fn", .init(from: [], in: &m))
    m.appendBlock(to: f)
    XCTAssertThrowsError(try m.verify())
  }

}
