//
//  VideoCardView.swift
//  lm player
//
//  Created by Claude Code
//

import SwiftUI

struct VideoCardView: View {
    let video: Video
    @ObservedObject var videoManager = VideoManager.shared

    @State private var showingEditAlert = false
    @State private var newTitle = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Thumbnail
            ZStack(alignment: .bottomTrailing) {
                if let thumbnailData = video.thumbnailData,
                   let uiImage = UIImage(data: thumbnailData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 180)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 180)
                        .cornerRadius(12)
                        .overlay(
                            Image(systemName: "video.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.6))
                        )
                }

                // Duration badge
                Text(videoManager.formatDuration(video.duration))
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(6)
                    .padding(8)
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

                HStack(spacing: 8) {
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
            }
        }
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
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
