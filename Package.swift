// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// ShyeTF fork: dependency URLs point to github.com/ShyeTF mirrors (tags *-shyetf.N) so the whole
// SPM graph resolves from ShyeTF repositories (Xcode Cloud). Test-only / CLI products and their
// dependencies (OHHTTPStubs, swift-snapshot-testing -> swift-syntax/pointfree, swift-argument-parser)
// are removed: _MapboxNavigationTestKit, mapbox-directions-swift CLI, MapboxDirectionsTests,
// MapboxNavigationPackageTests. Library products/modules are unchanged.

let (navNativeVersion, navNativeChecksum, navNativeRevision) = ("324.15.2", "548c96ac1d0ed8296ee3d2e8e1060407119897e16e92251474e28fcfb751cf02", "baf0b6c230cc78405dddf0b95975be73fabc04b5")
let mapsVersion: Version = "11.15.2-shyetf.1"
let navNativeShyeTFVersion: Version = "324.15.2-shyetf.1"
let turfVersion: Version = "4.0.0-shyetf.1"

let package = Package(
    name: "MapboxNavigation",
    defaultLocalization: "en",
    // The Nav SDK doesn't support macOS but declared the minimum macOS requirement with downstream deps to enable `swift run` cli tools
    platforms: [.iOS(.v14), .macOS(.v10_15)],
    products: [
        .library(
            name: "MapboxNavigationUIKit",
            targets: ["MapboxNavigationUIKit"]
        ),
        .library(
            name: "MapboxNavigationCore",
            targets: ["MapboxNavigationCore"]
        ),
        .library(
            name: "MapboxDirections",
            targets: ["MapboxDirections"]
        ),
        .library(
            name: "_MapboxNavigationLocalization",
            targets: ["_MapboxNavigationLocalization"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/ShyeTF/mapbox-navigation-native-ios.git", exact: navNativeShyeTFVersion),
        .package(url: "https://github.com/ShyeTF/mapbox-maps-ios.git", exact: mapsVersion),
        .package(url: "https://github.com/ShyeTF/turf-swift.git", exact: turfVersion),
    ],
    targets: [
        .target(
            name: "MapboxNavigationUIKit",
            dependencies: [
                "MapboxNavigationCore",
            ],
            exclude: ["Info.plist"],
            resources: [
                .copy("Resources/MBXInfo.plist"),
                .copy("Resources/PrivacyInfo.xcprivacy")
            ]
        ),
        .target(name: "_MapboxNavigationHelpers"),
        .target(
            name: "_MapboxNavigationLocalization",
            dependencies: [
                "_MapboxNavigationHelpers"
            ]),
        .target(
            name: "MapboxNavigationCore",
            dependencies: [
                "_MapboxNavigationLocalization",
                "_MapboxNavigationHelpers",
                .product(name: "MapboxNavigationNative", package: "mapbox-navigation-native-ios"),
                "MapboxDirections",
                .product(name: "MapboxMaps", package: "mapbox-maps-ios"),
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "MapboxDirections",
            dependencies: [
                .product(name: "Turf", package: "turf-swift"),
            ]
        ),

        // Test targets
        .testTarget(
            name: "MapboxNavigationCoreTests",
            dependencies: [
                "MapboxNavigationCore",
                "_MapboxNavigationTestHelpers",
            ],
            resources: [
                .copy("Fixtures"),
                .process("Resources"),
            ]
        ),
        .target(
            name: "_MapboxNavigationTestHelpers",
            dependencies: [
                "MapboxNavigationCore"
            ]
        ),
        .target(
            name: "TestHelper",
            dependencies: [
                "MapboxNavigationCore",
                "MapboxNavigationUIKit",
            ],
            exclude: ["Info.plist"],
            resources: [
                .process("Fixtures"),
            ]
        ),
        .target(
            name: "CarPlayTestHelper",
            exclude: [
                "Info.plist",
                "CarPlayTestHelper.h",
            ]
        ),
    ]
)
