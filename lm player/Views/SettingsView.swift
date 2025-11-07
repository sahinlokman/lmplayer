//
//  SettingsView.swift
//  lm player
//
//  Created by Claude Code
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var settingsManager = SettingsManager.shared
    @StateObject private var videoManager = VideoManager.shared

    @State private var showingResetConfirmation = false

    var body: some View {
        NavigationView {
            Form {
                // Playback Section
                Section(header: Text("Playback")) {
                    Picker("Default Speed", selection: $settingsManager.defaultPlaybackSpeed) {
                        ForEach(SettingsManager.availablePlaybackSpeeds, id: \.self) { speed in
                            Text(settingsManager.getSpeedLabel(for: speed))
                                .tag(speed)
                        }
                    }

                    Toggle("Auto-play Next Video", isOn: $settingsManager.autoPlayNextVideo)

                    Toggle("Remember Playback Position", isOn: $settingsManager.rememberPlaybackPosition)
                }

                // Display Section
                Section(header: Text("Display")) {
                    Toggle("Show Thumbnails", isOn: $settingsManager.showThumbnails)
                }

                // Storage Section
                Section(header: Text("Storage")) {
                    HStack {
                        Text("Total Videos")
                        Spacer()
                        Text("\(videoManager.videos.count)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Total Size")
                        Spacer()
                        Text(getTotalSize())
                            .foregroundColor(.secondary)
                    }
                }

                // About Section
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Bundle Identifier")
                        Spacer()
                        Text("com.lmplayer.lm-player")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }

                // Reset Section
                Section {
                    Button(action: {
                        showingResetConfirmation = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Reset All Settings")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Reset Settings", isPresented: $showingResetConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    settingsManager.resetToDefaults()
                }
            } message: {
                Text("Are you sure you want to reset all settings to their default values?")
            }
        }
    }

    private func getTotalSize() -> String {
        let totalSize = videoManager.videos.reduce(0) { $0 + $1.fileSize }
        return videoManager.formatFileSize(totalSize)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
