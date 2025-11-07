//
//  VideoManager.swift
//  lm player
//
//  Created by Claude Code
//

import Foundation
import CoreData
import AVFoundation
import UIKit
import Combine

class VideoManager: ObservableObject {
    static let shared = VideoManager()
    private let persistenceController = PersistenceController.shared

    @Published var videos: [Video] = []

    private init() {
        fetchVideos()
    }

    // MARK: - Fetch Videos
    func fetchVideos() {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<Video> = Video.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]

        do {
            videos = try context.fetch(fetchRequest)
        } catch {
            print("Error fetching videos: \(error.localizedDescription)")
        }
    }

    // MARK: - Add Video
    func addVideo(from url: URL, completion: @escaping (Bool, Error?) -> Void) {
        let context = persistenceController.container.viewContext

        // Copy video to app's documents directory
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            completion(false, NSError(domain: "VideoManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot access documents directory"]))
            return
        }

        let fileName = url.lastPathComponent
        let destinationURL = documentsPath.appendingPathComponent(fileName)

        // If file already exists, generate unique name
        var finalURL = destinationURL
        var counter = 1
        while FileManager.default.fileExists(atPath: finalURL.path) {
            let nameWithoutExtension = (fileName as NSString).deletingPathExtension
            let fileExtension = (fileName as NSString).pathExtension
            finalURL = documentsPath.appendingPathComponent("\(nameWithoutExtension)_\(counter).\(fileExtension)")
            counter += 1
        }

        do {
            // Copy file
            try FileManager.default.copyItem(at: url, to: finalURL)

            // Get video metadata
            let asset = AVAsset(url: finalURL)
            let duration = asset.duration.seconds

            // Get file size
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: finalURL.path)
            let fileSize = fileAttributes[.size] as? Int64 ?? 0

            // Generate thumbnail
            let thumbnail = generateThumbnail(for: asset)

            // Create Video entity
            let video = Video(context: context)
            video.id = UUID()
            video.title = (fileName as NSString).deletingPathExtension
            video.fileURL = finalURL.path
            video.duration = duration
            video.fileSize = fileSize
            video.thumbnailData = thumbnail?.pngData()
            video.dateAdded = Date()
            video.isFavorite = false

            try context.save()
            fetchVideos()
            completion(true, nil)

        } catch {
            print("Error adding video: \(error.localizedDescription)")
            completion(false, error)
        }
    }

    // MARK: - Delete Video
    func deleteVideo(_ video: Video) {
        let context = persistenceController.container.viewContext

        // Delete physical file
        if let filePath = video.fileURL {
            try? FileManager.default.removeItem(atPath: filePath)
        }

        // Delete from Core Data
        context.delete(video)

        do {
            try context.save()
            fetchVideos()
        } catch {
            print("Error deleting video: \(error.localizedDescription)")
        }
    }

    // MARK: - Update Video
    func updateVideo(_ video: Video, title: String? = nil, isFavorite: Bool? = nil) {
        let context = persistenceController.container.viewContext

        if let title = title {
            video.title = title
        }

        if let isFavorite = isFavorite {
            video.isFavorite = isFavorite
        }

        do {
            try context.save()
            fetchVideos()
        } catch {
            print("Error updating video: \(error.localizedDescription)")
        }
    }

    // MARK: - Generate Thumbnail
    private func generateThumbnail(for asset: AVAsset) -> UIImage? {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSize(width: 300, height: 300)

        let time = CMTime(seconds: 1, preferredTimescale: 60)

        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Format Duration
    func formatDuration(_ duration: Double) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    // MARK: - Format File Size
    func formatFileSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}
