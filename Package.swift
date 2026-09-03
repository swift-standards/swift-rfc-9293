// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "swift-rfc-9293",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
    ],
    products: [
        .library(name: "RFC 9293", targets: ["RFC 9293"]),
        .library(name: "RFC 9293 Shared", targets: ["RFC 9293 Shared"]),
        .library(
            name: "RFC 9293 3 Functional Specification",
            targets: ["RFC 9293 3 Functional Specification"]
        ),
        .library(
            name: "RFC 9293 Standard Library Integration",
            targets: ["RFC 9293 Standard Library Integration"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-standard-library-extensions.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-binary.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-binary-serializer.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-byte.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-ascii.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swift-ietf/swift-rfc-791.git", branch: "main"),
    ],
    targets: [

        .target(
            name: "RFC 9293 Shared",
            dependencies: [.product(name: "Standard Library Extensions", package: "swift-standard-library-extensions"), .product(name: "Binary", package: "swift-binary"), .product(name: "Binary Serializable", package: "swift-binary-serializer")]
        ),

        .target(
            name: "RFC 9293 3 Functional Specification",
            dependencies: [.target(name: "RFC 9293 Shared"), .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions"), .product(name: "ASCII", package: "swift-ascii"), .product(name: "Binary Serializable", package: "swift-binary-serializer")]
        ),

        .target(
            name: "RFC 9293",
            dependencies: [
                .target(name: "RFC 9293 Shared"), .target(name: "RFC 9293 3 Functional Specification"), .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions"), .product(name: "RFC 791", package: "swift-rfc-791"), .product(name: "Binary Serializable", package: "swift-binary-serializer"),
            ]
        ),

        .target(
            name: "RFC 9293 Standard Library Integration",
            dependencies: [.target(name: "RFC 9293"), .target(name: "RFC 9293 3 Functional Specification"), .product(name: "Byte Standard Library Integration", package: "swift-byte")]
        ),
        .testTarget(
            name: "RFC 9293 Tests",
            dependencies: [
                .target(name: "RFC 9293")
            ]
        ),
        .testTarget(
            name: "RFC 9293 Standard Library Integration Tests",
            dependencies: [
                .target(name: "RFC 9293"),
                .target(name: "RFC 9293 Standard Library Integration"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
