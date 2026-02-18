// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "Repro",
  products: [
    .executable(name: "Repro", targets: ["Repro"]),
  ],
  targets: [
    .executableTarget(
      name: "Repro",
      path: "Sources/Repro"
    ),
  ]
)
