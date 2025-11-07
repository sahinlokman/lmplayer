//
//  VideoPlayerView.swift
//  lm player
//
//  Created by Claude Code
//

import SwiftUI
import AVKit
import AVFoundation
import Combine

// MARK: - AVPlayer UIKit Wrapper
struct PlayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        view.layer.addSublayer(playerLayer)

        // Store layer in context for layout updates
        context.coordinator.playerLayer = playerLayer

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.playerLayer?.frame = uiView.bounds
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var playerLayer: AVPlayerLayer?
    }
}

// MARK: - Video Player View
struct VideoPlayerView: View {
    let video: Video
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @StateObject private var viewModel: VideoPlayerViewModel

    @State private var showControls = true
    @State private var hideControlsTask: Task<Void, Never>?

    init(video: Video) {
        self.video = video
        _viewModel = StateObject(wrappedValue: VideoPlayerViewModel(video: video))
    }

    var body: some View {
        ZStack {
            // Player
            PlayerView(player: viewModel.player)
                .ignoresSafeArea()
                .onTapGesture {
                    toggleControls()
                }

            // Top Bar
            if showControls {
                VStack {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.down")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(.black.opacity(0.6)))
                        }
                        .padding()

                        Spacer()

                        Text(video.title ?? "Unknown")
                            .font(.headline)
                            .foregroundColor(.white)
                            .lineLimit(1)

                        Spacer()

                        // Placeholder for symmetry
                        Color.clear
                            .frame(width: 60, height: 60)
                    }
                    .padding(.horizontal)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.black.opacity(0.6), .clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    Spacer()
                }
                .transition(.opacity)
            }

            // Controls
            if showControls {
                PlayerControlsView(
                    isPlaying: $viewModel.isPlaying,
                    currentTime: $viewModel.currentTime,
                    duration: $viewModel.duration,
                    volume: $viewModel.volume,
                    playbackSpeed: $viewModel.playbackSpeed,
                    onPlayPause: { viewModel.togglePlayPause() },
                    onSeek: { time in viewModel.seek(to: time) },
                    onSkipForward: { viewModel.skip(seconds: 15) },
                    onSkipBackward: { viewModel.skip(seconds: -15) },
                    onSpeedChange: { speed in viewModel.setPlaybackSpeed(speed) }
                )
                .transition(.opacity)
            }
        }
        .background(Color.black)
        .statusBar(hidden: true)
        .onAppear {
            viewModel.play()
            scheduleHideControls()
        }
        .onDisappear {
            viewModel.pause()
        }
    }

    private func toggleControls() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showControls.toggle()
        }

        if showControls {
            scheduleHideControls()
        }
    }

    private func scheduleHideControls() {
        hideControlsTask?.cancel()
        hideControlsTask = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            if !Task.isCancelled {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showControls = false
                }
            }
        }
    }
}

// MARK: - View Model
class VideoPlayerViewModel: ObservableObject {
    let player: AVPlayer
    private var timeObserver: Any?

    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var volume: Float = 1.0 {
        didSet {
            player.volume = volume
        }
    }
    @Published var playbackSpeed: Float = 1.0 {
        didSet {
            player.rate = isPlaying ? playbackSpeed : 0
        }
    }

    init(video: Video) {
        guard let urlString = video.fileURL,
              let url = URL(fileURLWithPath: urlString) as URL? else {
            self.player = AVPlayer()
            return
        }

        self.player = AVPlayer(url: url)
        self.player.volume = volume

        // Set default playback speed from settings
        let defaultSpeed = SettingsManager.shared.defaultPlaybackSpeed
        self.playbackSpeed = defaultSpeed

        setupTimeObserver()
        loadDuration()
    }

    deinit {
        if let observer = timeObserver {
            player.removeTimeObserver(observer)
        }
    }

    private func setupTimeObserver() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
        }
    }

    private func loadDuration() {
        guard let currentItem = player.currentItem else { return }

        if currentItem.duration.isIndefinite == false {
            duration = currentItem.duration.seconds
        } else {
            // Observe when duration becomes available
            currentItem.asset.loadValuesAsynchronously(forKeys: ["duration"]) { [weak self] in
                DispatchQueue.main.async {
                    if let duration = self?.player.currentItem?.duration {
                        self?.duration = duration.seconds
                    }
                }
            }
        }
    }

    func play() {
        player.rate = playbackSpeed
        isPlaying = true
    }

    func pause() {
        player.pause()
        isPlaying = false
    }

    func setPlaybackSpeed(_ speed: Float) {
        playbackSpeed = speed
        if isPlaying {
            player.rate = speed
        }
    }

    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: cmTime)
    }

    func skip(seconds: Double) {
        let newTime = max(0, min(currentTime + seconds, duration))
        seek(to: newTime)
    }
}
