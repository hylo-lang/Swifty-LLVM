// swift-tools-version: 5.7
import PackageDescription

let packageTarget: [Target]

// LLVM API Wrapper.
#if os(Windows)
  packageTarget = [
    .target(name: "LLVM", dependencies: ["llvmc"], linkerSettings: [.linkedLibrary("LLVM-C")])
  ]
#else
  packageTarget = [
    .target(name: "LLVM", dependencies: ["llvmc", "llvmshims"]),
    .target(name: "llvmshims", dependencies: ["llvmc"]),
  ]
#endif

let package = Package(
  name: "Swifty-LLVM",
  products: [
    .library(name: "LLVM", targets: ["LLVM"]),
  ],
  targets: packageTarget + [
    // LLVM API Wrapper Test.
    .testTarget(name: "LLVMTests", dependencies: ["LLVM"]),

    // LLVM's C API
    .systemLibrary(name: "llvmc", pkgConfig: "llvm"),
  ],
  cxxLanguageStandard: .cxx20)
