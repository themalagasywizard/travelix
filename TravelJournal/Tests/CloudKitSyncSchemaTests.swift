import Foundation
import XCTest
@testable import TravelJournalData

final class CloudKitSyncSchemaTests: XCTestCase {
    func testRecordTypeRoundTripForAllKinds() {
        let kinds = SyncRecordEnvelope.Kind.allCases

        for kind in kinds {
            let recordType = CloudKitSyncSchema.recordType(for: kind)
            XCTAssertEqual(CloudKitSyncSchema.kind(for: recordType), kind)
        }
    }

    func testRecordNameRoundTrip() {
        let id = UUID()
        let recordName = CloudKitSyncSchema.recordName(for: .visit, id: id)

        let parsed = CloudKitSyncSchema.parseRecordName(recordName)

        XCTAssertEqual(parsed?.kind, .visit)
        XCTAssertEqual(parsed?.id, id)
    }

    func testCodecEncodesAndDecodesTombstoneEnvelope() {
        let envelope = SyncRecordEnvelope(
            kind: .spot,
            id: UUID(),
            updatedAt: Date(timeIntervalSince1970: 1_234),
            payload: Data(),
            isDeleted: true
        )

        let codec = CloudKitSyncRecordCodec()
        let encoded = codec.encode(envelope)
        let decoded = codec.decode(encoded)

        XCTAssertEqual(decoded, envelope)
    }

    func testDecodeFallsBackToRecordTypeWhenRecordNameIsRawUUID() {
        let id = UUID()
        let encoded = CloudKitSyncRecordCodec.EncodedRecord(
            recordType: CloudKitSyncSchema.recordType(for: .tag),
            recordName: id.uuidString,
            updatedAt: Date(timeIntervalSince1970: 77),
            payload: Data("food".utf8),
            isDeleted: false
        )

        let decoded = CloudKitSyncRecordCodec().decode(encoded)

        XCTAssertEqual(decoded?.kind, .tag)
        XCTAssertEqual(decoded?.id, id)
        XCTAssertEqual(decoded?.payload, Data("food".utf8))
    }
}

private extension SyncRecordEnvelope.Kind {
    static let allCases: [SyncRecordEnvelope.Kind] = [.place, .trip, .visit, .spot, .media, .tag]
}
