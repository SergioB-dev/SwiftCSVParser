// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CSVDealer",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CSVDealer",
            targets: ["CSVDealer"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CSVDealer"),
        .testTarget(
            name: "CSVDealerTests",
            dependencies: ["CSVDealer"],
            resources: [
                .copy("Resources/personFixture.csv"),
                .copy("Resources/grammarByDua.csv")
            ]
        ),
    ]
)
