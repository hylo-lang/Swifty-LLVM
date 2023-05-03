// swift-tools-version: 5.7
import PackageDescription

let packageTarget: [Target]

#if os(Windows)
let customLinkerSettings: Optional = [.linkedLibrary("LLVM-C")]
#else
let customLinkerSettings: [LinkerSetting]? = nil
#endif

let package = Package(
  name: "Swifty-LLVM",
  products: [
    .library(name: "LLVM", targets: ["LLVM"]),
  ],
  targets: [
    // LLVM API Wrappers.
    .target(
      name: "LLVM",
      dependencies: ["llvmc", "llvmshims"],
      linkerSettings: customLinkerSettings),
    .target(
      name: "llvmshims",
      dependencies: ["llvmc"],
      linkerSettings: customLinkerSettings),

    // Tests.
    .testTarget(name: "LLVMTests", dependencies: ["LLVM"]),

    // LLVM's C API
    .systemLibrary(name: "llvmc", pkgConfig: "llvm"),
  ],
  cxxLanguageStandard: .cxx20)
