import SwiftyLLVM
import XCTest

final class StringConstantTests: XCTestCase {

  func testInit() {
    Context.withNew { (llvm) in
      let t = StringConstant("Bonjour!", in: &llvm)
      XCTAssertEqual(t.value, "Bonjour!")
    }
  }

  func testInitWithoutNullTerminator() {
    Context.withNew { (llvm) in
      let t = StringConstant("Bonjour!", nullTerminated: false, in: &llvm)
      XCTAssertEqual(t.value, "Bonjour!")
    }
  }

  func testConversion() {
    Context.withNew { (llvm) in
      let t: IRValue = StringConstant("Bonjour!", in: &llvm)
      XCTAssertNotNil(StringConstant(t))
      let u: IRValue = IntegerType(64, in: &llvm).zero
      XCTAssertNil(StringConstant(u))
    }
  }

  func testEquality() {
    Context.withNew { (llvm) in
      let t = StringConstant("Bonjour!", in: &llvm)
      let u = StringConstant("Bonjour!", in: &llvm)
      XCTAssertEqual(t, u)

      let v = StringConstant("Guten Tag!", in: &llvm)
      XCTAssertNotEqual(t, v)
    }
  }

}
