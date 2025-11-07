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

    // Search and Filter
    @State private var searchText = ""
    @State private var selectedFilter: VideoFilter = .all
    @State private var selectedSort: VideoSortOption = .dateAddedNewest
    @State private var viewMode: VideoViewMode = .grid
    @State private var showingFilterSheet = false

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var filteredAndSortedVideos: [Video] {
        var videos = searchText.isEmpty ? videoManager.videos : videoManager.searchVideos(query: searchText)
        videos = videoManager.filterVideos(by: selectedFilter)
        videos = videoManager.sortVideos(videos, by: selectedSort)

        // Apply search on filtered results
        if !searchText.isEmpty {
            videos = videos.filter { video in
                (video.title?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }

        return videos
    }

    var body: some View {
        NavigationView {
            ZStack {
                if videoManager.videos.isEmpty {
                    emptyStateView
                } else {
                    VStack(spacing: 0) {
                        // Filter bar
                        filterBar

                        // Video List/Grid
                        if filteredAndSortedVideos.isEmpty {
                            noResultsView
                        } else {
                            videoContentView
                        }
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
            .searchable(text: $searchText, prompt: "Search videos...")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Picker("View Mode", selection: $viewMode) {
                            ForEach(VideoViewMode.allCases, id: \.self) { mode in
                                Label(mode.rawValue, systemImage: mode == .grid ? "square.grid.2x2" : "list.bullet")
                                    .tag(mode)
                            }
                        }
                    } label: {
                        Image(systemName: viewMode == .grid ? "square.grid.2x2" : "list.bullet")
                            .foregroundColor(.primary)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {
                            showingFilterSheet = true
                        }) {
                            Image(systemName: selectedFilter == .all && selectedSort == .dateAddedNewest ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                                .foregroundColor(.primary)
                        }

                        Button(action: {
                            showingSettings = true
                        }) {
                            Image(systemName: "gear")
                                .foregroundColor(.primary)
                        }
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
            .sheet(isPresented: $showingFilterSheet) {
                filterSheet
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

    // MARK: - Filter Bar
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(VideoFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        isSelected: selectedFilter == filter
                    ) {
                        selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Video Content View
    @ViewBuilder
    private var videoContentView: some View {
        if viewMode == .grid {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(filteredAndSortedVideos, id: \.id) { video in
                        VideoCardView(video: video)
                            .onTapGesture {
                                selectedVideo = video
                                showingPlayer = true
                            }
                    }
                }
                .padding()
            }
        } else {
            List {
                ForEach(filteredAndSortedVideos, id: \.id) { video in
                    VideoListItemView(video: video)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .onTapGesture {
                            selectedVideo = video
                            showingPlayer = true
                        }
                }
            }
            .listStyle(.plain)
        }
    }

    // MARK: - Filter Sheet
    private var filterSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("Filter")) {
                    Picker("Show", selection: $selectedFilter) {
                        ForEach(VideoFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.inline)
                }

                Section(header: Text("Sort By")) {
                    Picker("Sort", selection: $selectedSort) {
                        ForEach(VideoSortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.inline)
                }

                Section {
                    Button("Reset to Defaults") {
                        selectedFilter = .all
                        selectedSort = .dateAddedNewest
                    }
                }
            }
            .navigationTitle("Filter & Sort")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingFilterSheet = false
                    }
                }
            }
        }
    }

    // MARK: - No Results View
    private var noResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Videos Found")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Try adjusting your search or filters")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button("Clear Filters") {
                searchText = ""
                selectedFilter = .all
                selectedSort = .dateAddedNewest
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty State View
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

    // MARK: - Import Video
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

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .cornerRadius(20)
        }
    }
}

struct VideoListView_Previews: PreviewProvider {
    static var previews: some View {
        VideoListView()
    }
}
