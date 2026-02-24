// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "TravelJournal",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "TravelJournalCore", targets: ["TravelJournalCore"]),
        .library(name: "TravelJournalData", targets: ["TravelJournalData"]),
        .library(name: "TravelJournalDomain", targets: ["TravelJournalDomain"]),
        .library(name: "TravelJournalUI", targets: ["TravelJournalUI"])
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "7.0.0")
    ],
    targets: [
        .target(name: "TravelJournalCore", path: "TravelJournal/Core"),
        .target(name: "TravelJournalDomain", dependencies: ["TravelJournalCore"], path: "TravelJournal/Domain"),
        .target(name: "TravelJournalData", dependencies: ["TravelJournalCore", "TravelJournalDomain", .product(name: "GRDB", package: "GRDB.swift")], path: "TravelJournal/Data"),
        .target(name: "TravelJournalUI", dependencies: ["TravelJournalCore", "TravelJournalDomain", "TravelJournalData"], path: "TravelJournal/UI"),
        .testTarget(name: "TravelJournalTests", dependencies: ["TravelJournalData", "TravelJournalDomain"], path: "TravelJournal/Tests")
    ]
)
