//
//  PlayerControlsView.swift
//  lm player
//
//  Created by Claude Code
//

import SwiftUI
import AVKit

struct PlayerControlsView: View {
    @Binding var isPlaying: Bool
    @Binding var currentTime: Double
    @Binding var duration: Double
    @Binding var volume: Float
    @Binding var playbackSpeed: Float

    var onPlayPause: () -> Void
    var onSeek: (Double) -> Void
    var onSkipForward: () -> Void
    var onSkipBackward: () -> Void
    var onSpeedChange: (Float) -> Void

    @State private var isDragging = false
    @State private var localTime: Double = 0
    @State private var showSpeedMenu = false

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            // Progress Bar
            VStack(spacing: 8) {
                Slider(
                    value: Binding(
                        get: { isDragging ? localTime : currentTime },
                        set: { newValue in
                            localTime = newValue
                            if !isDragging {
                                onSeek(newValue)
                            }
                        }
                    ),
                    in: 0...max(duration, 1),
                    onEditingChanged: { dragging in
                        isDragging = dragging
                        if !dragging {
                            onSeek(localTime)
                        }
                    }
                )
                .tint(.white)

                HStack {
                    Text(formatTime(isDragging ? localTime : currentTime))
                        .font(.caption)
                        .foregroundColor(.white)

                    Spacer()

                    Text(formatTime(duration))
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)

            // Controls
            HStack(spacing: 40) {
                Button(action: onSkipBackward) {
                    Image(systemName: "gobackward.10")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }

                Button(action: onPlayPause) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 56))
                        .foregroundColor(.white)
                }

                Button(action: onSkipForward) {
                    Image(systemName: "goforward.10")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }
            }
            .padding(.bottom, 8)

            // Volume and Speed Controls
            HStack(spacing: 20) {
                // Volume Control
                HStack(spacing: 12) {
                    Image(systemName: volume == 0 ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)

                    Slider(value: Binding(
                        get: { volume },
                        set: { volume = $0 }
                    ), in: 0...1)
                        .tint(.white)
                        .frame(width: 100)
                }

                Spacer()

                // Speed Control
                Button(action: {
                    showSpeedMenu.toggle()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "gauge")
                            .font(.system(size: 14))
                        Text(getSpeedLabel(playbackSpeed))
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                }
                .confirmationDialog("Playback Speed", isPresented: $showSpeedMenu, titleVisibility: .visible) {
                    ForEach(SettingsManager.availablePlaybackSpeeds, id: \.self) { speed in
                        Button(getSpeedLabel(speed)) {
                            onSpeedChange(speed)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func formatTime(_ time: Double) -> String {
        guard !time.isNaN && !time.isInfinite else { return "0:00" }

        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    private func getSpeedLabel(_ speed: Float) -> String {
        if speed == 1.0 {
            return "1x"
        }
        return String(format: "%.2gx", speed)
    }
}
