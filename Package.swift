// swift-tools-version: 5.7
import PackageDescription

var packageTarget = [Target]()

// LLVM API Wrapper.
#if os(Windows)
  packageTarget.append(
    .target(name: "LLVM", dependencies: ["llvmc"], linkerSettings: [.linkedLibrary("LLVM-C")])
  )
#else
  packageTarget.append(
    .target(name: "LLVM", dependencies: ["llvmc"])
  )
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
  ])