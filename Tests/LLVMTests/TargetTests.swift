import SwiftyLLVM
import XCTest

final class TargetTests: XCTestCase {

  func testHostCPUName() {
    XCTAssertFalse(TargetSpecification.hostCPUName.isEmpty)
  }

  // MARK: - Triple Structure

  func testHostTriple() throws {
    XCTAssertEqual(try Target.host().triple, Target.hostTriple)
  }

  func testHostTripleHasAtLeastThreeComponents() throws {
    let components = try Target.host().triple.split(separator: "-")
    XCTAssertGreaterThanOrEqual(components.count, 3)
  }

  func testHostCPUFeaturesStartWithPlusOrMinus() throws {
    let f = TargetSpecification.hostCPUFeatures
    try XCTSkipIf(f.isEmpty, "Host CPU features not available on this runner")
    XCTAssertTrue(f.hasPrefix("+") || f.hasPrefix("-"))
  }

  // MARK: - Triple Normalization

  func testNormalizationIsIdempotent() throws {
    let t = try Target.host().triple
    XCTAssertEqual(Target.normalizeTriple(t), t)
  }

  func testHostFactoryProducesNormalizedTriple() throws {
    let expected = Target.normalizeTriple(Target.hostTriple)
    XCTAssertEqual(try Target.host().triple, expected)
  }

  // MARK: - Equality and Hashing

  func testTwoHostTargetsAreEqual() throws {
    XCTAssertEqual(try Target.host(), try Target.host())
  }

  func testEqualTargetsHashEqually() throws {
    let a = try Target.host()
    let b = try Target.host()
    XCTAssertEqual(a.hashValue, b.hashValue)
  }

  func testTargetFromSameTripleIsEqual() throws {
    let triple = try Target.host().triple
    XCTAssertEqual(try Target(triple), try Target(triple))
  }

  // MARK: - Invalid Triples

  func testTargetTripleInvalid() {
    XCTAssertThrowsError(try Target("not-a-real-triple"))
  }

  // MARK: - CPU Validation

  func testIsCPUValidGeneric() throws {
    let t = try Target.host()
    XCTAssertTrue(t.isCPUValid(""))
  }

  func testIsCPUValidHost() throws {
    let t = try Target.host()
    XCTAssertTrue(t.isCPUValid(TargetSpecification.hostCPUName))
  }

  func testIsCPUValidRejectsUnknown() throws {
    let t = try Target.host()
    XCTAssertFalse(t.isCPUValid("bogus_cpu_xyz"))
  }

  // MARK: - Feature Validation

  func testFirstInvalidFeatureEmpty() throws {
    let t = try Target.host()
    XCTAssertNil(t.firstInvalidFeature(in: ""))
  }

  func testFirstInvalidFeatureReturnsName() throws {
    let t = try Target.host()
    XCTAssertEqual(t.firstInvalidFeature(in: "+bogus_feat_xyz"), "bogus_feat_xyz")
  }

  func testHostFeaturesAreAllValid() throws {
    let t = try Target.host()
    XCTAssertNil(t.firstInvalidFeature(in: TargetSpecification.hostCPUFeatures))
  }

  // MARK: - Backend

  func testHostBackend() throws {
    XCTAssertEqual(try Target.host().backend, try Backend.host())
  }

  func testHostBackendHasNonEmptyName() throws {
    XCTAssertFalse(try Target.host().backend.name.isEmpty)
  }

  func testHostBackendHasAssemblyBackEnd() throws {
    XCTAssertTrue(try Target.host().backend.hasAssemblyBackEnd)
  }

  func testBackendHash() throws {
    XCTAssertEqual(try Backend.host().hashValue, try Backend.host().hashValue)
  }

  func testBackendEquality() throws {
    XCTAssertEqual(try Backend.host(), try Backend.host())
  }

  func testBackendHashDifferent() throws {
    #if !SWIFTY_LLVM_CROSS_COMPILATION_ENABLED
      throw XCTSkip()
    #else
      XCTAssertNotEqual(
        try Backend(ofTriple: "arm64-apple-macos").hashValue,
        try Backend(ofTriple: "x86_64-apple-macos").hashValue)
    #endif
  }

  func testBackendEqualityDifferent() throws {
    #if !SWIFTY_LLVM_CROSS_COMPILATION_ENABLED
      throw XCTSkip()
    #else
      XCTAssertNotEqual(
        try Backend(ofTriple: "arm64-apple-macos"), try Backend(ofTriple: "x86_64-apple-macos"))
    #endif
  }

  // MARK: - TargetSpecification

  func testNativeDriverCreation() throws {
    let t = try TargetSpecification.native()
    XCTAssertFalse(t.cpu.isEmpty)
  }

  func testTargetSpecHostCPUMatchesHostCPUName() throws {
    let s = try TargetSpecification.native()
    XCTAssertEqual(s.cpu, TargetSpecification.hostCPUName)
  }

  func testTargetSpecHostFeaturesMatchHostCPUFeatures() throws {
    let s = try TargetSpecification.native()
    XCTAssertEqual(s.features, TargetSpecification.hostCPUFeatures)
  }

  func testTargetSpecGeneric() throws {
    let s = try TargetSpecification(target: .host())
    XCTAssertTrue(s.cpu.isEmpty)
    XCTAssertTrue(s.features.isEmpty)
  }

  func testTargetSpecInvalidCPU() throws {
    XCTAssertThrowsError(
      try TargetSpecification(target: .host(), cpu: "not_a_real_cpu_12345")
    ) { error in
      let e = error as? TargetSpecificationError
      XCTAssertEqual(
        e,
        TargetSpecificationError.invalidCPU(
          "not_a_real_cpu_12345", triple: Target.hostTriple))
    }
  }

  func testTargetSpecInvalidFeature() throws {
    XCTAssertThrowsError(
      try TargetSpecification(target: .host(), features: "+not_a_real_feature_xyz")
    ) { error in
      let e = error as? TargetSpecificationError
      XCTAssertEqual(
        e,
        TargetSpecificationError.invalidFeature(
          "not_a_real_feature_xyz", triple: Target.hostTriple))
    }
  }

  func testTargetSpecErrorDescriptionContainsOffendingValue() throws {
    XCTAssertThrowsError(try TargetSpecification(target: .host(), cpu: "bogus_cpu_xyz")) { error in
      XCTAssertTrue("\(error)".contains("bogus_cpu_xyz"))
    }
  }

}
