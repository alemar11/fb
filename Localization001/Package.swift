// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Localization001",
  defaultLocalization: "en",
  platforms: [.iOS(.v16), .macOS(.v13)],
  products: [.library(name: "Localization001", targets: ["Localization001"]),],
  targets: [
    .target(
      name: "Localization001"
    )
  ]
)
