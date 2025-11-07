//
//  VideoListView.swift
//  lm player
//
//  Created by Claude Code
//

import SwiftUI

struct VideoListView: View {
    @StateObject private var videoManager = VideoManager.shared

    @State private var showingFilePicker = false
    @State private var showingPhotoPicker = false
    @State private var showingImportOptions = false
    @State private var selectedVideo: Video?
    @State private var showingPlayer = false
    @State private var isImporting = false
    @State private var showingSettings = false

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationView {
            ZStack {
                if videoManager.videos.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(videoManager.videos, id: \.id) { video in
                                VideoCardView(video: video)
                                    .onTapGesture {
                                        selectedVideo = video
                                        showingPlayer = true
                                    }
                            }
                        }
                        .padding()
                    }
                }

                // Loading overlay
                if isImporting {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()

                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)

                            Text("Importing video...")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(32)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(radius: 20)
                    }
                }

                // Add button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingImportOptions = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Videos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gear")
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $showingFilePicker) {
                DocumentPicker(isPresented: $showingFilePicker) { url in
                    importVideo(from: url)
                }
            }
            .sheet(isPresented: $showingPhotoPicker) {
                PhotoPicker(isPresented: $showingPhotoPicker) { url in
                    importVideo(from: url)
                }
            }
            .fullScreenCover(item: $selectedVideo) { video in
                VideoPlayerView(video: video)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .confirmationDialog("Import Video", isPresented: $showingImportOptions) {
                Button("From Files") {
                    showingFilePicker = true
                }

                Button("From Photos") {
                    showingPhotoPicker = true
                }

                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Choose where to import your video from")
            }
        }
        .navigationViewStyle(.stack)
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "video.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(.gray)

            Text("No Videos Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Tap the + button to add your first video")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private func importVideo(from url: URL) {
        isImporting = true

        videoManager.addVideo(from: url) { success, error in
            DispatchQueue.main.async {
                isImporting = false

                if let error = error {
                    print("Error importing video: \(error.localizedDescription)")
                    // You could show an alert here
                }
            }
        }
    }
}

struct VideoListView_Previews: PreviewProvider {
    static var previews: some View {
        VideoListView()
    }
}
