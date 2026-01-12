# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FitAvatar is an iOS fitness application built with SwiftUI that combines workout tracking with a gamified avatar system. The app uses Core Data for persistence and follows a tab-based navigation pattern.

## Build & Development Commands

### Building the Project
```bash
# Build the app
xcodebuild -scheme FitAvatar -configuration Debug build

# Build for testing
xcodebuild -scheme FitAvatar -configuration Debug build-for-testing

# Clean build folder
xcodebuild clean -scheme FitAvatar
```

### Running Tests
```bash
# Run all unit tests
xcodebuild test -scheme FitAvatar -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test target
xcodebuild test -scheme FitAvatar -only-testing:FitAvatarTests -destination 'platform=iOS Simulator,name=iPhone 15'

# Run UI tests
xcodebuild test -scheme FitAvatar -only-testing:FitAvatarUITests -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Opening the Project
```bash
# Open in Xcode
open FitAvatar.xcodeproj
```

## Architecture

### Navigation Structure
The app uses a tab-based architecture with `MainTabView` as the root navigation component:
- **HomeView**: Dashboard showing user's avatar, today's workouts, and quick workout shortcuts
- **WorkoutView**: Exercise library and workout management
- **StatisticsView**: Training history and progress visualization
- **SettingsView**: App configuration

Entry point: `FitAvatarApp.swift` → `ContentView.swift` → `MainTabView.swift`

### Data Layer
- **Core Data**: Managed through `PersistenceController` singleton with a shared instance pattern
- **Data Model**: `FitAvatar.xcdatamodeld` contains the Core Data schema
- **Models**: Swift structs in `FitAvatar/Models/` directory for app-level data:
  - `Exercise.swift`: Exercise definitions with categories, difficulty levels, and target muscles

### View Organization
Views are being organized into a proper directory structure:
- Legacy views exist at `FitAvatar/*.swift` (being deprecated)
- New views should go in `FitAvatar/Views/`
- Models should go in `FitAvatar/Models/`

**Note**: There's currently a transition happening - duplicate view files exist in both the root `FitAvatar/` directory and `FitAvatar/Views/`. The Xcode project references the root-level files. When modifying views, ensure you're editing the files that are actually in the build (check `project.pbxproj` to confirm).

### UI Components
The app uses reusable SwiftUI components:
- `WorkoutCard`: Displays individual workout items
- `QuickWorkoutButton`: Quick access buttons for muscle group workouts

### Language
The app UI is in Japanese. When adding strings or modifying UI text, maintain consistency with the Japanese language throughout.

## Key Technologies
- **SwiftUI**: Declarative UI framework
- **Core Data**: Local persistence
- **iOS Deployment Target**: iOS 17.5+
- **Swift Version**: 5.0
- **Xcode Version**: 15.4

## File Structure Notes
The project has duplicate files in both root and subdirectories due to ongoing refactoring. Always check which file version is referenced in `project.pbxproj` before making changes.

Sample data for exercises is provided in `Exercise.swift` with the `sampleExercises` static property - useful for development and testing.
