import SwiftyLLVM
import XCTest

final class TargetMachineTests: XCTestCase {

  func testHostMachineTripleMatchesNormalizedHostTriple() throws {
    let m = try TargetMachine.host()
    XCTAssertEqual(m.triple, Target.normalizeTriple(Target.hostTriple))
  }

  func testMachineFromSpecPreservesTriple() throws {
    let s = try TargetSpecification.host()
    let m = TargetMachine(target: s)
    XCTAssertEqual(m.triple, s.target.triple)
  }

  func testMachineFromSpecPreservesCPUAndFeatures() throws {
    let s = try TargetSpecification.host()
    let m = TargetMachine(target: s)
    XCTAssertEqual(m.cpu, s.cpu)
    XCTAssertEqual(m.features, s.features)
  }

  func testMachineWithOptionsPreservesCPU() throws {
    let s = try TargetSpecification.host()
    let m = TargetMachine(target: s, optimization: .aggressive, relocation: .pic, codeModel: .small)
    XCTAssertEqual(m.cpu, s.cpu)
    XCTAssertEqual(m.triple, s.target.triple)
  }

  func testMachineBackendMatchesSpecBackend() throws {
    let s = try TargetSpecification.host()
    let m = TargetMachine(target: s)
    XCTAssertEqual(m.backend.name, s.target.backend.name)
  }

}
