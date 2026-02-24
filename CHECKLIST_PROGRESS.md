# TravelJournal Progress Tracker

Last updated: 2026-02-24 03:40 Europe/Paris

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
- [ ] Edit Visit
- [ ] Spots CRUD
- [ ] Tags

## Notes / blockers
- This environment cannot run Xcode simulator/device verification directly.
- Swift toolchain is unavailable in this environment (`swift: not found`), so unit tests could not be executed here.
- We can continue autonomous code implementation and git pushes; runtime iOS verification must be done on a macOS/Xcode runner.
