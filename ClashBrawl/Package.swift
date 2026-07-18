// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClashBrawl",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ClashBrawl",
            targets: ["ClashBrawl"]
        )
    ],
    targets: [
        .target(
            name: "ClashBrawl",
            path: "ClashBrawl",
            exclude: ["App/ClashBrawlApp.swift"]
        )
    ]
)
