# Travel Journal iOS App — Checklist & Roadmap (Small Tasks, Verifiable Outputs)

> Rule: **Do not move to the next step until outputs are verified.**  
> Each task must produce a tangible artifact: code, screen, test, benchmark, or demo clip.

## Phase 0 — Repo & foundations (0.5 day)
1. **Create Xcode project**
   - Output: builds & runs on simulator + physical device.
2. **Set up modules / folders**
   - Output: Core/Data/Domain/UI folder structure committed.
3. **Add dependencies**
   - GRDB (or Core Data), SwiftLint (optional)
   - Output: `Package.resolved` committed, app builds.

## Phase 1 — Data layer (1 day)
1. **Define data models**
   - Place, Visit, Trip, Spot, Media, Tag
   - Output: Swift structs + mapping to DB records.
2. **Implement DB + migrations**
   - Output: DB file created, migration runs on first launch.
   - Verification: unit test `testMigrationsCreateAllTables`.
3. **Repositories (CRUD)**
   - PlaceRepository: upsert/fetch pins list
   - VisitRepository: create/update/delete + fetch by place
   - Output: unit tests for each repository CRUD.
4. **Seed demo data (developer mode)**
   - Output: one button “Load Demo Data” seeds 50 places, 120 visits.

## Phase 2 — Globe MVP (1–2 days)
1. **Lat/Lon → 3D conversion utility**
   - Output: unit test for known coordinate conversions (sanity checks).
2. **SceneKit globe view wrapper**
   - Output: sphere with earth texture displayed.
3. **Camera + gestures**
   - Rotate (pan), zoom (pinch), inertial deceleration.
   - Output: screen recording showing smooth interaction.
4. **Render pins**
   - Pins placed correctly given lat/lon.
   - Output: 50 pins visible; no overlap explosions.
5. **Pin hit-testing**
   - Tap pin → returns PlaceID reliably.
   - Output: debug overlay shows selected place name on tap.
6. **Performance benchmark**
   - Output: Instruments capture showing stable FPS with 200 pins.

## Phase 3 — Core UI flows (2–3 days)
1. **Home = GlobeView + top search bar + filters**
   - Output: UI matches spec; dark mode OK.
2. **Place Story screen**
   - Shows place header + list of visits.
   - Output: tapping a pin navigates to Place Story with correct visits.
3. **Visit Detail screen**
   - Sections: dates, summary, photos grid, notes, spots list, recommendations.
   - Output: renders for seeded data; scroll is smooth.

## Phase 4 — Create/Edit content (2–3 days)
1. **Add Visit flow (modal)**
   - Step 1: location search + “use current location”
   - Step 2: date range picker
   - Step 3: note + photos
   - Output: create visit → pin appears on globe immediately.
2. **Edit Visit**
   - Output: update notes/dates persists after relaunch.
3. **Spots CRUD**
   - Add spot (restaurant/activity) inside visit.
   - Output: spot list updates, persisted.
4. **Tags**
   - Create tag; assign to visit; filter globe by tag.
   - Output: filter reduces pins deterministically.

## Phase 5 — Media pipeline (1–2 days)
1. **PhotosPicker import**
   - Output: import 10 photos; stored as Media records.
2. **Thumbnail generator + cache**
   - Output: thumbnails shown instantly on reopen (no re-decode jank).
3. **Offline validation**
   - Output: airplane mode shows thumbnails + notes for imported media.

## Phase 6 — Search & filters (1 day)
1. **Search index**
   - Simple LIKE search (v1) or FTS (v1.1).
   - Output: searching “Tokyo” returns place + visits; “Sushi” returns spot.
2. **Filter chips**
   - Year / Trip / Tag
   - Output: filter state affects pins + lists consistently.

## Phase 7 — Premium polish (1–2 days)
1. **Design system tokens**
   - Output: single source of spacing, radius, typography styles.
2. **Haptics**
   - Output: selection haptic on pin focus, success haptic on save.
3. **Motion**
   - Output: matched transitions; no “spring soup”.
4. **Accessibility pass**
   - Output: VoiceOver can select pins via list fallback; Dynamic Type doesn’t break layout.

## Phase 8 — Hardening (1 day)
1. **Error handling**
   - Output: simulated DB failure shows friendly banner, no crash.
2. **Migrations + version bump**
   - Output: add a dummy column migration, prove upgrade works.
3. **Performance final**
   - Output: Instruments trace of cold start + globe interaction.

## Optional Phase 9 — iCloud sync (2–4 days)
1. **Feature flag**
   - Output: toggle in settings enables/disables sync.
2. **CloudKit schema + sync engine**
   - Output: create visit on device A appears on device B.
3. **Conflict policy**
   - Output: last-write-wins test passes.

## Definition of Done (v1)
- AppStore-ready build configuration
- All “Acceptance criteria” from PRD satisfied
- Seed data demo mode removed or behind debug flag
- Basic privacy policy text ready (even if local-first)

## Quick QA checklist (binary)
- [ ] Cold launch shows globe < 1.5s on iPhone 13+
- [ ] Pin tap always selects correct place
- [ ] Create Visit works end-to-end with photos
- [ ] Offline mode shows content
- [ ] Dark mode looks deliberate
- [ ] No stutter while rotating globe or scrolling photos
