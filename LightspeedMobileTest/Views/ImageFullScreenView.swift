//
//  ImageFullScreenView.swift
//  Lightspeed_iOS_TakeHome
//
//  Created by Andrew So on 2025-08-22.
//
//  Purpose:
//    Displays a single image in full screen with support for zooming, panning,
//    double-tap zoom toggle, and a dismiss button.
//
//  Notes:
//    - Uses AsyncImage for remote loading.
//    - Supports pinch-to-zoom (1x–4x), drag-to-pan, and double-tap to reset/zoom.
//    - Status bar is hidden for an immersive experience.
//

import SwiftUI

struct ImageFullScreenView: View {
    let item: ImageItem
    
    // Environment dismiss action for closing the full-screen view.
    @Environment(\.dismiss) private var dismiss

    // Zoom and pan state variables.
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        ZStack {
            // Black background for immersive full-screen.
            Color.black.ignoresSafeArea()

            GeometryReader { _ in
                AsyncImage(url: URL(string: item.download_url)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(panGesture)
                            .gesture(zoomGesture)
                            .onTapGesture(count: 2) {
                                // Double-tap toggles between zoomed-in and reset.
                                withAnimation(.easeInOut) {
                                    if scale > 1 {
                                        // Reset to default
                                        scale = 1
                                        lastScale = 1
                                        offset = .zero
                                        lastOffset = .zero
                                    } else {
                                        scale = 2
                                        lastScale = 2
                                    }
                                }
                            }
                        
                        // Image attribution overlay.
                        Text(item.author)
                            .font(.headline)
                            .foregroundColor(.white)

                    case .failure(_):
                        // Error state if the image fails to load.
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 40, weight: .bold))
                            Text("Failed to load image.")
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    default:
                        // Loading state while fetching the image.
                        ProgressView()
                            .tint(.white)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            // Close button overlay (top-right).
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                            .shadow(radius: 4)
                            .padding(12)
                    }
                }
                Spacer()
            }
        }
        .statusBarHidden(true) // Hide status bar for full immersion
    }

    // MARK: - Gestures

    // Pinch-to-zoom gesture, clamped between 1x and 4x.
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = min(max(lastScale * value, 1), 4)
            }
            .onEnded { _ in
                lastScale = scale
                // Reset pan when zoomed back to 1x.
                if scale <= 1.01 {
                    offset = .zero
                    lastOffset = .zero
                }
            }
    }

    // Pan gesture for dragging the zoomed-in image.
    private var panGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard scale > 1 else { return }
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                guard scale > 1 else { return }
                lastOffset = offset
            }
    }
}
