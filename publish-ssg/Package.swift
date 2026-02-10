// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "RealWorldSSG",
  platforms: [
    .macOS(.v12),
  ],
  dependencies: [
    .package(url: "https://github.com/JohnSundell/Publish", from: "0.9.0"),
  ],
  targets: [
    .executableTarget(
      name: "RealWorldSSG",
      dependencies: [
        "Publish",
      ]
    ),
  ]
)
