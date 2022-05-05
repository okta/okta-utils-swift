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
            targets: ["LoggerCore"])
    ],
    dependencies: [
        .package(url: "https://github.com/Instabug/Instabug-SP", .upToNextMajor(from: "10.7.0")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "8.0.0")),
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", .upToNextMajor(from: "3.6.0"))
    ],
    targets: [
        .target(
            name: "OktaLogger",
            dependencies: [
                .target(name: "FileLogger"),
                .target(name: "FirebaseCrashlyticsLogger"),
                .target(name: "InstabugLogger"),
                .target(name: "LoggerCore")
            ],
            exclude: ["AppCenterLogger",
                      "FileLoggers",
                      "FirebaseCrashlyticsLogger",
                      "InstabugLogger",
                      "LoggerCore",
                      "Info.plist"]),
        .target(name: "FileLogger",
                dependencies: [
                .product(name: "CocoaLumberjack", package: "CocoaLumberjack"),
                .product(name: "CocoaLumberjackSwift", package: "CocoaLumberjack"),
                .target(name: "LoggerCore")
               ],
                path: "Sources/OktaLogger/FileLoggers"),
        .target(name: "FirebaseCrashlyticsLogger",
                dependencies: [
                    .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                    .target(name: "LoggerCore")
                ],
                path: "Sources/OktaLogger/FirebaseCrashlyticsLogger"),
        .target(name: "InstabugLogger",
               dependencies: [
                    .product(name: "Instabug", package: "Instabug-SP"),
                    .target(name: "LoggerCore")
               ],
                path: "Sources/OktaLogger/InstabugLogger"),
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
