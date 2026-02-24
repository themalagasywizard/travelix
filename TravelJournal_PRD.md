# Travel Journal iOS App — PRD (v1)

## 1) Product summary
A premium iOS-native travel journal that visualizes your life’s travels on an interactive 3D globe with pinpoints. Tapping a pin opens a rich “Place Story” with photos, notes, restaurants, recommendations, and trip details. The experience should feel minimal, precise, and expensive: calm typography, restrained motion, excellent haptics, fast offline browsing, and flawless interactions.

## 2) Goals and non-goals
### Goals
- **Capture**: Quickly log a visit (location + date range + notes + photos + places).
- **Recall**: Explore via **interactive globe** and timeline/search to find past adventures.
- **Curate**: Build “Place Stories” and “Trip Stories” with restaurants and recommendations.
- **Premium feel**: Native performance, elegant UI, reliable offline-first behavior.
- **Privacy**: Local-first storage by default; optional cloud sync.

### Non-goals (v1)
- Social feed, following, public sharing network.
- AI itinerary generation.
- Android version.

## 3) Target users & core use cases
### Primary user
- Frequent traveler who wants a personal archive and a beautiful way to revisit memories.

### Core use cases (ranked)
1. **View globe** with pins of visited places; pan/zoom/rotate smoothly.
2. Tap pin → see “Place Story” with photos + notes + restaurants + recommendations.
3. Add a new visit in <30 seconds (location + one note + optional photos).
4. Create/edit a **Trip** grouping multiple visits (e.g., “Japan 2025”).
5. Search by city/country/restaurant/tag; filter by year.
6. Offline viewing of past content (including cached images).

## 4) Information architecture
### Entities
- **Place**: A geographic point (city-level) + metadata.
- **Visit**: A time-bounded stay at a Place (single city visit) with journal content.
- **Trip**: A collection of Visits (one journey).
- **Spot**: A saved location within a Visit (restaurant/cafe/activity/viewpoint).
- **Media**: Photos (v1), optional videos (v1.1).
- **Tag**: User labels (e.g., “food”, “work”, “beach”).

### Relationships
- Place 1—* Visit
- Trip 1—* Visit
- Visit 1—* Spot
- Visit 1—* Media
- Visit *—* Tag (via join table)

## 5) Key screens (v1)
1. **Globe (Home)**
   - 3D globe with pins
   - Search bar + filter chip (Year/Trip/Tag)
   - “Add” (+) floating button
2. **Place Story**
   - Header: place name, country, visit count
   - Map/globe mini-preview
   - Timeline of Visits at this Place
3. **Visit Detail**
   - Date range, summary
   - Photos grid
   - Notes (rich text-lite: headings + bullets)
   - Spots list (restaurants etc.) with rating + quick notes
   - Recommendations section (“Do again”, “Avoid”, “Tips”)
4. **Add / Edit Visit**
   - Location picker (search + current GPS)
   - Date range
   - Add photos (Photos picker)
   - Quick note
   - Save
5. **Trips**
   - List of trips + cover photo
   - Trip detail: route line + visits list
6. **Search**
   - Global search across places, trips, spots, tags

## 6) Premium design principles (non-negotiables)
- **One primary action per screen** (no clutter).
- **Typography**: system fonts (SF Pro) with disciplined hierarchy.
- **Motion**: subtle, purposeful; 60/120fps; no gimmicks.
- **Haptics**: selection feedback on pin focus, success on save.
- **Color**: restrained palette; dark mode first-class.
- **Sound**: none by default.
- **Performance**: globe interactions never stutter; image decoding async.

## 7) Functional requirements
### Globe & pins
- Render a 3D globe with:
  - Inertial rotation, pinch zoom, double-tap focus.
  - Pins for Places with at least one Visit.
  - Pin clustering at far zoom levels (optional v1.0; required v1.1 if >200 pins).
- Tap pin:
  - Focus animation to pin
  - Present Place Story
- “Visited countries” optional overlay (v1.1)

### Add / edit
- Create/edit/delete Visit
- Attach photos (from Photos library)
- Add/edit Spots within a Visit:
  - name, category, address (optional), GPS (optional), rating (0–5), note
- Tags: create and assign tags to visits/spots

### Search & filters
- Search by place, trip, spot, tag
- Filter pins by year, trip, tag

### Offline-first
- All text data stored locally.
- Photos cached locally (user-controlled storage setting: “Cache originals” on/off).

### Sync (optional, behind a toggle)
- iCloud sync with CloudKit (private database)
- Conflict resolution: last-write-wins per record (v1); improve later.

### Export (v1.1)
- Export a Trip as PDF (cover + route + highlights)
- Export data as JSON (privacy-friendly)

## 8) Non-functional requirements
- **App start**: Home rendered < 1.5s on modern devices.
- **Globe FPS**: 60fps minimum; 120fps on ProMotion when possible.
- **Storage**: no runaway caching; surface cache size + clear button.
- **Privacy**: No analytics by default; if added, opt-in only.
- **Reliability**: Safe writes, crash-free, robust migrations.
- **Accessibility**: Dynamic Type, VoiceOver labels for pins and lists.
- **Localization-ready**: strings externalized (v1 supports EN only).

## 9) Monetization (optional)
- Freemium:
  - Free: up to N visits (e.g., 50), limited photo storage.
  - Pro: unlimited, iCloud sync, export, advanced filters.
- App Store subscription with trial.

## 10) Acceptance criteria (v1 must pass)
- Globe shows pins for at least 50 places without stutter on iPhone 13+.
- Add Visit flow: location + date + note + 3 photos saved and visible offline.
- Tap pin → Place Story loads in <300ms after focus.
- Search returns correct results for place name and spot name.
- Dark mode looks intentional (no washed grays).
- No visible UI jank while scrolling photo grids or opening details.
