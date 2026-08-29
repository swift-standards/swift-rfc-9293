// swift-tools-version: 6.4
import PackageDescription

extension String {
    static let rfc9293 = "RFC 9293"
    static let rfc9293Shared = "RFC 9293 Shared"
    static let rfc9293Section3 = "RFC 9293 3 Functional Specification"
    static let rfc9293SLI = "RFC 9293 Standard Library Integration"
}

extension Target.Dependency {
    static let rfc9293 = Self.target(name: .rfc9293)
    static let rfc9293Shared = Self.target(name: .rfc9293Shared)
    static let rfc9293Section3 = Self.target(name: .rfc9293Section3)
    static let standards = Self.product(
        name: "Standard Library Extensions",
        package: "swift-standard-library-extensions"
    )
    static let binary = Self.product(name: "Binary", package: "swift-binary")
    static let binarySerializable = Self.product(
        name: "Binary Serializable",
        package: "swift-binary-serializer"
    )
    static let incits41986 = Self.product(
        name: "ASCII",
        package: "swift-ascii"
    )
    static let rfc791 = Self.product(name: "RFC 791", package: "swift-rfc-791")
    static let bytePrimitivesSLI = Self.product(
        name: "Byte Standard Library Integration",
        package: "swift-byte"
    )
}

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
            dependencies: [.standards, .binary, .binarySerializable]
        ),

        .target(
            name: "RFC 9293 3 Functional Specification",
            dependencies: [.rfc9293Shared, .standards, .incits41986, .binarySerializable]
        ),

        .target(
            name: "RFC 9293",
            dependencies: [
                .rfc9293Shared, .rfc9293Section3, .standards, .rfc791, .binarySerializable,
            ]
        ),

        .target(
            name: "RFC 9293 Standard Library Integration",
            dependencies: [.rfc9293, .rfc9293Section3, .bytePrimitivesSLI]
        ),
        .testTarget(
            name: "RFC 9293 Tests",
            dependencies: [
                "RFC 9293"
            ]
        ),
        .testTarget(
            name: "RFC 9293 Standard Library Integration Tests",
            dependencies: [
                "RFC 9293",
                "RFC 9293 Standard Library Integration",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
}

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
