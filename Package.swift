// swift-tools-version:6.3

import PackageDescription

let package = Package(
  name: "Swifty-LLVM",
  platforms: [
    .macOS(.v15),
  ],
  products: [
    .library(name: "SwiftyLLVM", targets: ["SwiftyLLVM"]),
  ],
  targets: [
    // LLVM API Wrappers.
    .target(
      name: "SwiftyLLVM",
      dependencies: ["llvmc", "llvmshims"],
      swiftSettings: [.unsafeFlags(["-enable-experimental-feature", "AccessLevelOnImport"])]),

    .target(
      name: "llvmshims",
      dependencies: ["llvmc"]),

    // Tests.
    .testTarget(name: "LLVMTests", dependencies: ["SwiftyLLVM"]),

    // LLVM's C API
    .systemLibrary(name: "llvmc", pkgConfig: "llvm"),
  ],
  cxxLanguageStandard: .cxx20)
