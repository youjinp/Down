// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Down",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "Down", targets: ["Down"]),
    ],
    dependencies: [],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "libcmark",
            path: "Sources/libcmark/src",
            resources: [
                .process("entities.inc"),
                .process("case_fold_switch.inc")
            ],
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath(".")
            ]
        ),
        .target(
            name: "libmd4c",
            path: "Sources/libmd4c/src",
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath(".")
            ]
        ),
        .target(
            name: "Down",
            dependencies: [
                .target(name: "libcmark"),
                .target(name: "libmd4c"),
            ],
            path: "Sources/Down"
        ),
        .testTarget(
            name: "DownTests",
            dependencies: ["Down"]
        ),
    ]
)
