// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GeoTrackKit",
    products: [
        .library(
            name: "GeoTrackKit",
            targets: ["GeoTrackKit"]),
    ],
    targets: [
        .target(
            name: "GeoTrackKit",
            dependencies: []),
        .testTarget(
            name: "GeoTrackKitTests",
            dependencies: ["GeoTrackKit"]),
    ]
)
