# lightspeed-takehome
Lightspeed's mobile test take home assessment.

//
//  README
//  lightspeed-takehome
//
//  Created by Andrew So on 2025-08-22.
//

## Overview

This app was built in SwiftUI to complete the take-home task. The goal was to pull in random images from the [Picsum API](https://picsum.photos/v2/list), save them locally, and let the user manage the list.

Here’s what it does:

- **Stage 1** – Fetch a list of images, pick a random one, add it to the bottom of the list, and persist it.
- **Stage 2** – A button to add images, show each image with its author, support delete + reorder, and keep everything in sync.
- **Stage 3** – Added unit and UI tests, plus this README.

I also added a full-screen image viewer so you can tap an image to see it larger with pinch-to-zoom.

---

## How it’s put together

- **SwiftUI** for the UI
- **URLSession with async/await** for networking
- **Codable** for decoding the API response
- **UserDefaults** for simple persistence (via a `StorageManager`)
- **ObservableObject** store (`ImageListStore`) to keep the list in sync with the view
- **XCTest** for both unit and UI tests

The code is split into folders for Models, Networking, Persistence, ViewModels, Views, and Tests.

---

## Features

- **Add Random Image** – pulls a random image from the API and appends it to the list.
- **Persistence** – list is saved and restored when the app restarts.
- **Delete & Reorder** – swipe to delete, drag to reorder, “Clear All” button in edit mode.
- **Full-Screen Viewer** – tap a row to see the image full screen, zoom and pan, close to go back.
- **Polish** – empty state when no items exist, basic error handling, and smooth animations.

## Testing

- **Unit tests**:
  - Decoding sample JSON into `ImageItem`
  - Saving/loading with `StorageManager`
  - Store behavior: delete, move, deleteAll

- **UI tests**:
  - Adding an image increases rows
  - Deleting a row decreases rows
  - Reordering works in edit mode
  - Tapping a row opens the full-screen viewer, closing returns to list

---

## Running it

1. Open the project in Xcode 15+
2. Run on an iOS 17+ simulator with ⌘R
3. Run tests with ⌘U

---

## If I had more time

- Replace UserDefaults with Core Data or SwiftData
- Better error messages and retry UI
- Accessibility identifiers for even more stable UI tests
- Extra UI polish (grid layout, pull to refresh, loading placeholders)

---

## Notes

I kept the code simple and easy to follow while still layering it properly (models, networking, storage, store, views). The tests cover both the logic and the UI flows. The extra full-screen image viewer was added to show I can go a little beyond the spec and think about the user experience.

---

## Thanks 🙏
Thanks for reviewing my take-home project!  
I had fun building it and appreciate your time going through my code.
