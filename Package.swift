// swift-tools-version: 5.7
import PackageDescription

#if os(Windows)
  let package = Package(
  name: "Swifty-LLVM",
  products: [
    .library(name: "LLVM", targets: ["LLVM"]),
  ],
  targets: [
    // LLVM API Wrapper.
    .target(name: "LLVM", dependencies: ["llvmc"], linkerSettings: [.linkedLibrary("LLVM-C")]),
    .testTarget(name: "LLVMTests", dependencies: ["LLVM"]),

    // LLVM's C API
    .systemLibrary(name: "llvmc", pkgConfig: "llvm"),
  ])
#else
  let package = Package(
    name: "Swifty-LLVM",
    products: [
      .library(name: "LLVM", targets: ["LLVM"]),
    ],
    targets: [
      // LLVM API Wrapper.
      .target(name: "LLVM", dependencies: ["llvmc"]),
      .testTarget(name: "LLVMTests", dependencies: ["LLVM"]),

      // LLVM's C API
      .systemLibrary(name: "llvmc", pkgConfig: "llvm"),
    ])
#endif