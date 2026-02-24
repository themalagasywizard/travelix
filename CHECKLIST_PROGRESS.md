# TravelJournal Progress Tracker

Last updated: 2026-02-24 02:20 Europe/Paris

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
- [ ] Camera + gestures
- [ ] Render pins
- [ ] Pin hit-testing
- [ ] Performance benchmark

## Notes / blockers
- This environment cannot run Xcode simulator/device verification directly.
- Swift toolchain is unavailable in this environment (`swift: not found`), so unit tests could not be executed here.
- We can continue autonomous code implementation and git pushes; runtime iOS verification must be done on a macOS/Xcode runner.
