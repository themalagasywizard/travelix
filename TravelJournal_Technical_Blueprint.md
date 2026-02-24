# Travel Journal iOS App — Technical Blueprint (Swift, Native)

## 1) Architecture
- **SwiftUI** for UI (premium animations + clean hierarchy)
- **SceneKit** or **RealityKit** for 3D globe rendering (choose one; see §2)
- **Swift Concurrency (async/await)** for data + image pipelines
- **Local storage**: SQLite via **GRDB** *or* Core Data (recommend GRDB for explicit schemas + migrations)
- **Sync (optional)**: CloudKit (private db)
- **Dependency Injection**: lightweight (protocols + Environment)

### Suggested module layout
- App
- Core (utilities, logging, design system tokens)
- Data (DB, repositories, models, migrations)
- Domain (use cases)
- UI (features: Globe, PlaceStory, VisitDetail, Trips, Search)

## 2) Globe rendering options (pick 1)
### Option A — SceneKit (recommended for speed to ship)
- Pros: mature, straightforward sphere + texture + nodes for pins, easier hit-testing
- Cons: slightly older API

Implementation notes:
- Sphere node with Earth texture (4K) + optional night lights layer.
- Pins: small cylinders/cones/sprites aligned to surface normal.
- Convert lat/lon → 3D position on sphere.
- Hit testing for pin taps: `hitTest(_:options:)`.
- Camera: orbit control with custom gestures (pan/rotate/pinch).

### Option B — RealityKit
- Pros: modern, great performance
- Cons: more setup, hit-testing/pin management slightly different

## 3) Data model (SQLite schema)
### Tables
- places(
  - id TEXT PRIMARY KEY,
  - name TEXT NOT NULL,
  - country TEXT,
  - latitude REAL NOT NULL,
  - longitude REAL NOT NULL,
  - created_at REAL NOT NULL,
  - updated_at REAL NOT NULL
)
- trips(
  - id TEXT PRIMARY KEY,
  - name TEXT NOT NULL,
  - start_date REAL,
  - end_date REAL,
  - cover_media_id TEXT,
  - created_at REAL NOT NULL,
  - updated_at REAL NOT NULL
)
- visits(
  - id TEXT PRIMARY KEY,
  - place_id TEXT NOT NULL REFERENCES places(id),
  - trip_id TEXT REFERENCES trips(id),
  - start_date REAL NOT NULL,
  - end_date REAL NOT NULL,
  - summary TEXT,
  - notes TEXT,
  - created_at REAL NOT NULL,
  - updated_at REAL NOT NULL
)
- spots(
  - id TEXT PRIMARY KEY,
  - visit_id TEXT NOT NULL REFERENCES visits(id),
  - name TEXT NOT NULL,
  - category TEXT, -- e.g., restaurant, cafe, hike
  - latitude REAL,
  - longitude REAL,
  - address TEXT,
  - rating INTEGER, -- 0..5
  - note TEXT,
  - created_at REAL NOT NULL,
  - updated_at REAL NOT NULL
)
- media(
  - id TEXT PRIMARY KEY,
  - visit_id TEXT NOT NULL REFERENCES visits(id),
  - local_identifier TEXT, -- Photos framework ID or local file name
  - file_url TEXT,         -- app sandbox file if copied
  - width INTEGER,
  - height INTEGER,
  - created_at REAL NOT NULL,
  - updated_at REAL NOT NULL
)
- tags(
  - id TEXT PRIMARY KEY,
  - name TEXT NOT NULL UNIQUE
)
- visit_tags(
  - visit_id TEXT NOT NULL REFERENCES visits(id),
  - tag_id TEXT NOT NULL REFERENCES tags(id),
  - PRIMARY KEY (visit_id, tag_id)
)

### Migrations
- v1: create tables + indices
- indices:
  - visits(place_id), visits(trip_id), spots(visit_id), media(visit_id)
  - FTS (optional v1.1): virtual table for search across names/notes

## 4) Core services & repositories
### Repositories (protocols)
- PlaceRepository
  - upsertPlace(...)
  - fetchPlacesWithVisitCounts(filter: ...)
  - fetchPlace(id:)
- VisitRepository
  - createVisit(...)
  - updateVisit(...)
  - deleteVisit(id:)
  - fetchVisits(forPlace:)
  - fetchVisits(forTrip:)
- TripRepository
  - createTrip(...)
  - updateTrip(...)
  - fetchTrips()
- SpotRepository
  - addSpot(...)
  - updateSpot(...)
  - deleteSpot(...)
- MediaRepository
  - importMedia(from PhotosPickerItem)
  - fetchMedia(forVisit:)
  - image(forMediaID, targetSize)

### Use cases (Domain)
- LoadGlobePinsUseCase
- FocusPlaceUseCase
- CreateVisitUseCase
- AddSpotUseCase
- SearchUseCase
- ExportTripUseCase (v1.1)
- SyncUseCase (optional)

## 5) Image pipeline (premium performance)
- Import via **PhotosPicker**:
  - Store Photos localIdentifier AND optionally copy file to app container
- Caching:
  - In-memory `NSCache` for decoded thumbnails
  - On-disk thumbnail cache (e.g., 512px, 1024px)
- Decode off-main-thread; deliver `Image`/`UIImage` on main actor
- Preheat thumbnails when opening VisitDetail

## 6) Location handling
- Use CoreLocation:
  - For “Add Visit”: request When-In-Use only when user taps “Use current location”
  - Do not background track
- Geocoding:
  - Use `CLGeocoder` to resolve city/country for coordinates (cache results)

## 7) UI implementation details
### Design system (Core)
- Spacing scale (4, 8, 12, 16, 24, 32)
- Corner radius tokens (12, 16, 24)
- Shadows: subtle, consistent
- Materials: use `ultraThinMaterial` sparingly (avoid cheap blur look)
- Haptics: `UISelectionFeedbackGenerator`, `UINotificationFeedbackGenerator`

### Navigation
- SwiftUI NavigationStack
- Deep links:
  - place://{placeID}
  - visit://{visitID}
  - trip://{tripID}

### Feature screens
- GlobeView: SceneKit wrapper via `UIViewRepresentable`
- PlaceStoryView: list of visits grouped by year
- VisitDetailView: sections (photos, notes, spots, recommendations)
- AddVisitFlow: multi-step modal (Location → Dates → Content)

## 8) Sync (optional, behind feature flag)
- CloudKit private database
- Record types mirroring tables: Place, Trip, Visit, Spot, Media, Tag
- Sync strategy:
  - Local is source of truth
  - Push local changes; pull remote changes
  - Conflict: last-write-wins by updated_at
- Media sync: only if copied to app container; otherwise keep Photos references local

## 9) Testing strategy
- Unit tests:
  - lat/lon ↔ 3D conversion
  - repositories CRUD
  - migrations
  - search/filter logic
- Snapshot tests (optional): key screens in light/dark
- Performance tests:
  - load 200 pins
  - open VisitDetail with 100 photos thumbnails

## 10) Observability & crash safety
- Structured logs (os.Logger)
- Graceful error UI (non-blocking banners)
- Database writes on serial queue
- Automatic DB backups on version upgrades (optional)

## 11) Security & privacy
- On-device database encrypted (optional): SQLCipher or iOS Data Protection classes
- FaceID lock (v1.1)
- No third-party trackers in v1

## 12) “Verifiable outputs” for the AI agent
- Running app with seeded demo data: 50 places, 120 visits, 400 photos (thumbnails)
- Globe:
  - pinch/rotate works
  - pin tap selects correct PlaceID
- CRUD:
  - create visit persists + appears instantly on globe
- Offline:
  - airplane mode still shows visits + thumbnails
