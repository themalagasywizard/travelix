# TravelJournal Progress Tracker

Last updated: 2026-02-24 06:11 Europe/Paris

## Phase 0 — Repo & foundations
- [ ] Create Xcode project
- [x] Set up modules / folders
- [x] Add dependencies scaffold (Swift Package with GRDB)

## Phase 1 — Data layer
- [x] Define initial domain entities (Place, Visit, Trip, Spot, Media, Tag)
- [x] Implement initial DB migration schema (v1 tables + indices)
- [x] Repository CRUD (implemented Place/Visit/Trip/Spot/Media repositories with CRUD unit tests; execution pending on Swift/Xcode-capable runner)
- [x] Seed demo data (implemented `DemoDataSeeder` with deterministic counts and added developer UI action `Load Demo Data`; runtime/UI verification pending on Xcode)

## Phase 2 — Globe MVP
- [~] Lat/Lon → 3D conversion utility (implemented `GlobeCoordinateConverter` + sanity unit tests; test execution pending on Swift/Xcode-capable runner)
- [~] SceneKit globe view wrapper (implemented `GlobeSceneView` with sphere, texture hook, camera, and lighting setup; runtime validation pending on iOS/macOS SceneKit environment)
- [~] Camera + gestures (added pan rotate, pinch zoom, and inertial deceleration in `GlobeSceneView.Coordinator`; runtime tuning/verification pending on Xcode runner)
- [~] Render pins (added `GlobePin` model + pin container rendering pipeline in `GlobeSceneView`, with lat/lon placement via `GlobeCoordinateConverter`; visual/runtime validation pending on SceneKit runner)
- [~] Pin hit-testing (implemented tap hit-test on SceneKit nodes with `onPinSelected` callback and selected-pin highlight state in `GlobeSceneView`; runtime validation pending on Xcode runner)
- [~] Performance benchmark (added CPU-side benchmark utility `GlobePinRenderBenchmark` for 200-pin generation path + benchmark tests; Instruments/SceneKit FPS capture still pending on macOS/Xcode)

## Phase 3 — Core UI flows
- [~] Home = GlobeView + top search bar + filters (implemented `HomeView` + `HomeViewModel` with search field, filter chips, globe embedding, and pin selection state; runtime UI validation pending on Xcode)
- [~] Place Story screen (implemented `PlaceStoryView` + `PlaceStoryViewModel` structure and wired Home pin selection to present Place Story sheet; repository-backed visit data wiring pending)
- [~] Visit Detail screen (implemented `VisitDetailView` + `VisitDetailViewModel` sections for dates/summary/photos/notes/spots/recommendations with view-model tests; navigation/data wiring and runtime validation pending)

## Phase 4 — Create/Edit content
- [~] Add Visit flow (modal) (implemented `AddVisitFlowView` + `AddVisitFlowViewModel` with 3-step flow: Location → Dates → Content and step-navigation tests; persistence + globe refresh wiring pending)
- [~] Edit Visit (implemented `EditVisitView` + `EditVisitViewModel` edit form and date-range validation with tests; persistence/relaunch verification pending)
- [~] Spots CRUD (implemented repository-backed `VisitSpotsEditorViewModel` add/update/delete/load operations and unit tests with in-memory repository; Visit Detail UI action wiring pending)
- [~] Tags (implemented `GRDBTagRepository` create/assign/remove/fetch operations, place IDs by tag query for deterministic globe filtering, and tests in `TagRepositoryTests` + `HomeViewModelTests`; runtime verification on Xcode runner and local Swift test execution still pending)

## Phase 5 — Media pipeline
- [~] PhotosPicker import (implemented repository-level import entry point `importMedia(from:forVisit:importedAt:)` with `MediaImportPayload` mapping to persisted `Media` records; added `testImportMediaCreatesRecordFromPayload`; real PhotosPicker UI integration/runtime verification pending on Xcode runner)
- [~] Thumbnail generator + cache (implemented `DefaultThumbnailCache` with in-memory `NSCache` + on-disk cache file persistence keyed by media ID and pixel size; added `ThumbnailCacheTests` for store/load roundtrip and cache clear behavior; image decode/generation pipeline integration + runtime verification pending on Xcode runner)
- [~] Offline validation (implemented `OfflineVisitValidator` producing `OfflineVisitValidationReport` by checking required thumbnail sizes per media item against `ThumbnailCache`; added `OfflineVisitValidatorTests` covering missing-thumbnail detection and all-cached success paths; airplane-mode UI/runtime validation still pending on Xcode runner)

## Phase 6 — Search & filters
- [~] Search index (implemented `GRDBSearchRepository` with SQL LIKE-based global search across places, visits, spots, and tags with deterministic ordering and limit; added `SearchRepositoryTests` for entity coverage and result limiting; runtime UI wiring and Swift test execution on a Swift/Xcode runner still pending)
- [~] Filter chips (extended `HomeViewModel` filter state with explicit year/trip/tag selections and deterministic intersection logic across active chips; disabling a chip now clears its associated selection and recomputes visible pins; expanded `HomeViewModelTests` for multi-chip intersection and filter-disable behavior; runtime UI wiring verification pending on Xcode runner)

## Phase 7 — Premium polish
- [~] Design system tokens (expanded `DesignTokens.swift` with typography and shadow token families in addition to spacing/radius; added `DesignTokensTests` for token scale/hierarchy/subtle-shadow constraints; Swift test execution and runtime visual verification pending on Xcode runner)
- [~] Haptics (added `HapticsClient` with injectable `HapticsEngine` and default UIKit-backed implementation using `UISelectionFeedbackGenerator`/`UINotificationFeedbackGenerator`, plus non-UIKit no-op fallback; added `HapticsClientTests` to verify event routing for selection/success/warning/error; runtime tactile verification pending on iOS device/simulator via Xcode)
- [~] Motion (added `TJMotion` tokens with bounded durations and explicit curve presets via `MotionTokens.swift`, including globe-focus-specific spring timing; added `MotionTokensTests` covering duration bounds, ordering hierarchy, and curve selection; runtime animation tuning/verification pending on Xcode runner)
- [~] Accessibility pass (added centralized accessibility tokens in `TJAccessibility` and applied identifiers/labels to key Home and Visit Detail UI elements: search field, filter chips, selected-place badge, and visit detail sections/header; added `AccessibilityTokensTests` for token stability and label semantics; VoiceOver/dynamic-type runtime validation still pending on Xcode runner)

## Phase 8 — Hardening
- [~] Error handling (added `TJAppError` + `ErrorPresentationMapper` to produce user-facing non-crashing banner models for database/media/input/unknown failures; added `ErrorPresentationTests` for mapping determinism and safe fallbacks; runtime banner integration in UI flows pending on Xcode runner)
- [~] Migrations + version bump (added `v2_add_visits_mood` migration in `DatabaseManager.makeMigrator()` introducing a dummy `visits.mood` column with default `""`; expanded `MigrationsTests` to assert latest schema column presence and to simulate v1→v2 upgrade path via migration table priming; Swift test execution still blocked in this environment)
- [~] Performance final (added `DatabasePerformanceBenchmark` with deterministic measurements for DB cold start and visit-read path over seeded rows; added `DatabasePerformanceBenchmarkTests` for non-negative timing assertions and operation identity; Instruments traces for cold start + globe interaction still pending on macOS/Xcode)

## Notes / blockers
- `Create Xcode project` remains open: this Linux environment cannot generate/validate an iOS Xcode project build/run lifecycle (simulator/device) directly.
- Swift toolchain is unavailable in this environment (`swift: not found`), so unit tests could not be executed here.
- We can continue autonomous code implementation and git pushes; runtime iOS verification must be done on a macOS/Xcode runner.
