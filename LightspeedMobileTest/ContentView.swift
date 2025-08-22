//
//  ContentView.swift
//  LightspeedMobileTest
//
//  Created by Andrew So on 2025-08-22.
//
//  Purpose:
//    Main SwiftUI view for browsing and managing a gallery of images.
//    Supports adding a random image, deleting, reordering, and full-screen viewing.
//
//  Notes:
//    - Uses ImageListStore as the source of truth.
//    - Inline styling aims for a clean, modern gallery look.
//    - Title updated from "Random Images" to "Image Gallery" with inline display.
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
            VStack(spacing: 0) {
                
                // Primary action switches depending on edit mode.
                Group {
                    if mode == .active {
                        Button {
                            store.deleteAll()
                        } label: {
                            Label("Clear All", systemImage: "trash")
                        }
                        .buttonStyle(.bordered)
                        .padding(.vertical, 12)
                        .padding(.horizontal)
                    } else {
                        Button {
                            Task { try? await store.addRandomImage() }
                        } label: {
                            Label("Add Random Image", systemImage: "sparkles")
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.vertical, 12)
                        .padding(.horizontal)
                    }
                }

                // Gallery list
                List {
                    ForEach(store.items) { item in
                        HStack(spacing: 16) {
                            // Thumbnail preview
                            AsyncImage(url: URL(string: item.download_url)) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } else if phase.error != nil {
                                    Color.red
                                } else {
                                    ProgressView()
                                }
                            }
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 4)

                            // Metadata
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.author)
                                    .font(.headline)
                                Text("ID: \(item.id)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .lineLimit(1)
                        }
                        // Make the whole row tappable (disabled while editing)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            guard mode == .inactive else { return }
                            selectedItem = item
                        }
                    }
                    .onDelete(perform: store.delete)
                    .onMove(perform: store.move)
                }
                .listStyle(.insetGrouped)
                .environment(\.editMode, $mode)
            }
            .navigationTitle("Image Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Edit/Done toggle
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(mode == .active ? "Done" : "Edit") {
                        withAnimation {
                            mode = (mode == .active ? .inactive : .active)
                        }
                    }
                }
            }
        }
        // Animate mode changes for a smoother UX.
        .animation(.default, value: mode)

        // Presents a full-screen image viewer when an item is selected.
        .fullScreenCover(item: $selectedItem) { item in
            ImageFullScreenView(item: item)
        }
    }
}
