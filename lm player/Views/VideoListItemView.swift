//
//  VideoListItemView.swift
//  lm player
//
//  Created by Claude Code
//

import SwiftUI

struct VideoListItemView: View {
    let video: Video
    @ObservedObject var videoManager = VideoManager.shared
    @State private var showingShareSheet = false
    @State private var showingEditAlert = false
    @State private var newTitle = ""

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            ZStack(alignment: .bottomTrailing) {
                if let thumbnailData = video.thumbnailData,
                   let uiImage = UIImage(data: thumbnailData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 80)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 80)
                        .cornerRadius(8)
                        .overlay(
                            Image(systemName: "video.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.6))
                        )
                }

                // Duration badge
                Text(videoManager.formatDuration(video.duration))
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(4)
                    .padding(4)
            }

            // Video Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(video.title ?? "Unknown")
                        .font(.headline)
                        .lineLimit(2)
                        .foregroundColor(.primary)

                    Spacer()

                    if video.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }

                HStack(spacing: 6) {
                    Text(videoManager.formatFileSize(video.fileSize))
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(formatDate(video.dateAdded))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let lastWatched = video.lastWatchedDate {
                    HStack(spacing: 6) {
                        Image(systemName: "eye.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Text("\(video.viewCount) views")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Text("•")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Text("Last watched: \(formatRelativeDate(lastWatched))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                // Progress bar if video was partially watched
                let position = video.lastPlaybackPosition
                if position > 0 {
                    let progress = position / video.duration
                    if progress < 0.95 { // Don't show if almost finished
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 3)

                                Rectangle()
                                    .fill(Color.accentColor)
                                    .frame(width: geometry.size.width * progress, height: 3)
                            }
                            .cornerRadius(1.5)
                        }
                        .frame(height: 3)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .contextMenu {
            Button(action: {
                videoManager.updateVideo(video, isFavorite: !video.isFavorite)
            }) {
                Label(
                    video.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                    systemImage: video.isFavorite ? "heart.slash" : "heart"
                )
            }

            Button(action: {
                newTitle = video.title ?? ""
                showingEditAlert = true
            }) {
                Label("Rename", systemImage: "pencil")
            }

            Button(action: {
                showingShareSheet = true
            }) {
                Label("Share", systemImage: "square.and.arrow.up")
            }

            Divider()

            Button(role: .destructive, action: {
                videoManager.deleteVideo(video)
            }) {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert("Rename Video", isPresented: $showingEditAlert) {
            TextField("Video name", text: $newTitle)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                if !newTitle.isEmpty {
                    videoManager.updateVideo(video, title: newTitle)
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let fileURL = video.fileURL {
                let url = URL(fileURLWithPath: fileURL)
                ShareSheet(items: [url])
            }
        }
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
