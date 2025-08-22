//
//  ContentView.swift
//  LightspeedMobileTest
//
//  Created by Andrew So on 2025-08-22.
//
//  Purpose:
//    Main SwiftUI view for displaying and managing a list of random images.
//    Supports adding, deleting, reordering, and viewing images in full screen.
//
//  Notes:
//    - Uses ImageListStore as the source of truth for image data.
//    - Provides two modes: normal (add) and editing (delete/reorder).
//    - Presents a full-screen viewer when an image row is tapped.
//

import SwiftUI

struct ContentView: View {
    // Store that manages fetching, persistence, and list updates.
    @StateObject private var store = ImageListStore()
    
    // Tracks whether the list is in editing mode.
    @State private var mode: EditMode = .inactive
    
    // Holds the currently selected image for full-screen presentation.
    @State private var selectedItem: ImageItem? = nil

    var body: some View {
        NavigationView {
            VStack {
                // Top button switches depending on edit mode
                if mode == .active {
                    Button("Clear All") {
                        store.deleteAll()
                    }
                    .buttonStyle(.bordered)
                    .padding()
                } else {
                    Button("Add Random Image") {
                        Task { try? await store.addRandomImage() }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }

                // List of images
                List {
                    ForEach(store.items) { item in
                        HStack {
                            // Thumbnail preview of the image
                            AsyncImage(url: URL(string: item.download_url)) { phase in
                                if let image = phase.image {
                                    image.resizable().scaledToFill()
                                } else if phase.error != nil {
                                    Color.red
                                } else {
                                    ProgressView()
                                }
                            }
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                            // Author name
                            Text(item.author)
                                .font(.headline)
                        }
                        // Make the whole row tappable (but disabled while editing)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            guard mode == .inactive else { return }
                            selectedItem = item
                        }
                    }
                    .onDelete(perform: store.delete)
                    .onMove(perform: store.move)
                }
                .environment(\.editMode, $mode)
            }
            .navigationTitle("Random Images")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Edit/Done toggle button
                    Button(mode == .active ? "Done" : "Edit") {
                        withAnimation {
                            mode = (mode == .active ? .inactive : .active)
                        }
                    }
                }
            }
        }
        .animation(.default, value: mode)
    }
}
