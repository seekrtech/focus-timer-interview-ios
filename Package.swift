// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "FocusTimerAnalytics",
    targets: [
        .target(
            name: "FocusTimerAnalytics",
            path: "Sources/FocusTimerAnalytics"
        ),
        .testTarget(
            name: "FocusTimerAnalyticsTests",
            dependencies: ["FocusTimerAnalytics"],
            path: "Tests/FocusTimerAnalyticsTests"
        ),
    ]
)
