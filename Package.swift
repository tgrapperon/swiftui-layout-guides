// swift-tools-version:5.4
import PackageDescription

let package = Package(
  name: "swiftui-layout-guides",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    .library(
      name: "SwiftUILayoutGuides",
      targets: ["SwiftUILayoutGuides"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "SwiftUILayoutGuides",
      dependencies: [])
  ]
)
