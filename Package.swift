// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OktaLogger",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_14),
        .watchOS(.v6)
    ],
    products: [
        .library(
            /// Complete library with all dependencies
            name: "OktaLogger",
            targets: ["OktaLogger"]),
        .library(
            /// Core library with no additional dependencies
            name: "OktaLoggerCore",
            targets: ["LoggerCore"]),
        .library(
            name: "OktaFileLogger",
            targets: ["FileLogger"]),
    ],
    dependencies: [
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", .upToNextMajor(from: "3.8.5")),
    ],
    targets: [
        .target(
            name: "OktaLogger",
            dependencies: [
                .target(name: "FileLogger"),
                .target(name: "LoggerCore"),
            ],
            exclude: ["FileLoggers",
                      "FirebaseCrashlyticsLogger",
                      "InstabugLogger",
                      "LoggerCore",
                      "Info.plist"]),
        .target(name: "FileLogger",
                dependencies: [
                .product(name: "CocoaLumberjackSwift", package: "CocoaLumberjack"),
                .target(name: "LoggerCore")
               ],
                path: "Sources/OktaLogger/FileLoggers"),
        .target(
            name: "LoggerCore",
            dependencies: [],
            path: "Sources/OktaLogger/LoggerCore"),
        .testTarget(
            name: "OktaLoggerTests",
            dependencies: ["OktaLogger"],
            path: "Tests/OktaLoggerTests",
            exclude: ["Info.plist"]),
    ]
)
