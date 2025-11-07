//
//  SettingsManager.swift
//  lm player
//
//  Created by Claude Code
//

import Foundation
import Combine

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    private let defaults = UserDefaults.standard

    // Keys
    private enum Keys {
        static let defaultPlaybackSpeed = "defaultPlaybackSpeed"
        static let autoPlayNextVideo = "autoPlayNextVideo"
        static let rememberPlaybackPosition = "rememberPlaybackPosition"
        static let showThumbnails = "showThumbnails"
    }

    // MARK: - Published Properties
    @Published var defaultPlaybackSpeed: Float {
        didSet {
            defaults.set(defaultPlaybackSpeed, forKey: Keys.defaultPlaybackSpeed)
        }
    }

    @Published var autoPlayNextVideo: Bool {
        didSet {
            defaults.set(autoPlayNextVideo, forKey: Keys.autoPlayNextVideo)
        }
    }

    @Published var rememberPlaybackPosition: Bool {
        didSet {
            defaults.set(rememberPlaybackPosition, forKey: Keys.rememberPlaybackPosition)
        }
    }

    @Published var showThumbnails: Bool {
        didSet {
            defaults.set(showThumbnails, forKey: Keys.showThumbnails)
        }
    }

    // MARK: - Initialization
    private init() {
        self.defaultPlaybackSpeed = defaults.float(forKey: Keys.defaultPlaybackSpeed)
        if self.defaultPlaybackSpeed == 0 {
            self.defaultPlaybackSpeed = 1.0
        }

        self.autoPlayNextVideo = defaults.bool(forKey: Keys.autoPlayNextVideo)
        self.rememberPlaybackPosition = defaults.bool(forKey: Keys.rememberPlaybackPosition)

        // Show thumbnails is true by default
        if defaults.object(forKey: Keys.showThumbnails) == nil {
            self.showThumbnails = true
            defaults.set(true, forKey: Keys.showThumbnails)
        } else {
            self.showThumbnails = defaults.bool(forKey: Keys.showThumbnails)
        }
    }

    // MARK: - Playback Speeds
    static let availablePlaybackSpeeds: [Float] = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]

    func getSpeedLabel(for speed: Float) -> String {
        if speed == 1.0 {
            return "Normal"
        }
        return String(format: "%.2fx", speed)
    }

    // MARK: - Reset Settings
    func resetToDefaults() {
        defaultPlaybackSpeed = 1.0
        autoPlayNextVideo = false
        rememberPlaybackPosition = false
        showThumbnails = true
    }
}
