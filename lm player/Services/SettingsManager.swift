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
        // Load values from UserDefaults
        let savedSpeed = defaults.float(forKey: Keys.defaultPlaybackSpeed)
        let savedShowThumbnails = defaults.object(forKey: Keys.showThumbnails)

        // Initialize all properties first
        self.defaultPlaybackSpeed = savedSpeed == 0 ? 1.0 : savedSpeed
        self.autoPlayNextVideo = defaults.bool(forKey: Keys.autoPlayNextVideo)
        self.rememberPlaybackPosition = defaults.bool(forKey: Keys.rememberPlaybackPosition)
        self.showThumbnails = savedShowThumbnails == nil ? true : defaults.bool(forKey: Keys.showThumbnails)

        // Set default for showThumbnails if not set
        if savedShowThumbnails == nil {
            defaults.set(true, forKey: Keys.showThumbnails)
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
