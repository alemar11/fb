// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Localization001",
  defaultLocalization: "en",
  platforms: [.iOS(.v16), .macOS(.v13)],
  products: [
    .library(name: "LocalizedPackage1", targets: ["LocalizedPackage1"]),
    .library(name: "LocalizedPackage2", targets: ["LocalizedPackage2"])
  ],
  targets: [
    .target(name: "LocalizedPackage1"),
    .target(name: "LocalizedPackage2")
  ]
)
