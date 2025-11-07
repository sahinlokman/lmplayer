# LM Player 📱

A modern iOS video player application built with SwiftUI that allows you to import, organize, and play your video collection.

## Features ✨

### Video Management
- 📥 Import videos from Files app or Photos library
- 🗂️ Organize videos with favorites
- ✏️ Rename videos
- 🗑️ Delete videos with file cleanup
- 🖼️ Automatic thumbnail generation
- 📊 View video information (duration, file size, date added)

### Video Playback
- ▶️ Full-featured video player with custom controls
- ⚡ Playback speed control (0.5x, 0.75x, 1x, 1.25x, 1.5x, 2x)
- ⏩ Skip forward/backward (15 seconds)
- 🔊 Volume control
- 📱 Full-screen playback
- 🎯 Precise timeline scrubbing
- ⏸️ Play/Pause with tap gesture
- 🕹️ Auto-hide controls

### Settings
- ⚙️ Customizable default playback speed
- 🎬 Auto-play next video (coming soon)
- 💾 Remember playback position (coming soon)
- 🖼️ Toggle thumbnail display
- 📈 Storage statistics

## Requirements 📋

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## Architecture 🏗️

The app follows a clean architecture pattern with:

- **SwiftUI** for the user interface
- **Core Data** for persistent storage
- **AVFoundation** for video playback
- **MVVM** pattern for view models
- **UserDefaults** for app settings

### Project Structure

```
lm player/
├── Services/
│   ├── VideoManager.swift        # Video CRUD operations
│   ├── VideoImportService.swift  # Import from Files/Photos
│   └── SettingsManager.swift     # App settings management
├── Views/
│   ├── VideoListView.swift       # Main video list
│   ├── VideoCardView.swift       # Video card component
│   ├── VideoPlayerView.swift     # Video player
│   ├── PlayerControlsView.swift  # Player controls UI
│   └── SettingsView.swift        # Settings screen
├── Persistence.swift             # Core Data stack
└── lm_playerApp.swift           # App entry point
```

## Installation 🚀

1. Clone the repository:
```bash
git clone <repository-url>
cd lmplayer
```

2. Open the project in Xcode:
```bash
open "lm player.xcodeproj"
```

3. Select your target device or simulator

4. Press `Cmd + R` to build and run

## Usage 💡

### Importing Videos

1. Tap the **+** button at the bottom right
2. Choose **From Files** or **From Photos**
3. Select the video you want to import
4. Wait for the import to complete

### Playing Videos

1. Tap on any video card to start playback
2. Tap the screen to show/hide controls
3. Use the playback speed button (gauge icon) to adjust speed
4. Drag the timeline to seek
5. Swipe down or tap the close button to exit

### Managing Videos

- **Long press** or **right-click** on a video card to:
  - Add/remove from favorites
  - Rename the video
  - Delete the video

### Adjusting Settings

1. Tap the **gear** icon in the top right
2. Adjust your preferences:
   - Default playback speed
   - Auto-play settings
   - Display options
3. Tap **Done** to save

## Data Storage 💾

- Videos are stored in the app's Documents directory
- Metadata is stored using Core Data
- Settings are persisted using UserDefaults
- Thumbnails are generated and stored as binary data

## Future Enhancements 🎯

- [ ] Search and filter videos
- [ ] Sort options (name, date, size, duration)
- [ ] Playlists and folders
- [ ] Share videos
- [ ] Picture-in-Picture support
- [ ] Subtitle support
- [ ] Video quality selection
- [ ] Playback statistics (view count, last watched)
- [ ] Dark mode optimization
- [ ] iPad optimization with multiple columns
- [ ] Video preview on hover
- [ ] Batch import
- [ ] Cloud sync (iCloud)

## Technologies Used 🛠️

- **SwiftUI**: Modern declarative UI framework
- **AVFoundation**: Video playback and processing
- **Core Data**: Local database
- **PhotosUI**: Photo library access
- **UniformTypeIdentifiers**: File type handling

## License 📄

[Add your license here]

## Author 👨‍💻

Created by Lokman Şahin

## Version History 📝

### Version 1.0
- Initial release
- Video import and management
- Custom video player
- Playback speed control
- Settings screen
