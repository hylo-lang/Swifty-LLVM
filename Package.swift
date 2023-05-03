// swift-tools-version: 5.7
import PackageDescription

// Custom linker settings are required because Windows doesn't support pkg-config.
#if os(Windows)
let customLinkerSettings: [LinkerSetting]? = [.linkedLibrary("LLVM-C"), .linkedLibrary("LLVM-15")]
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
