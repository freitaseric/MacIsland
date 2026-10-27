# MacIsland — Agent Instructions

## Project Context
MacIsland is a native macOS app that brings Dynamic Island-inspired functionality to MacBook notches. It is built with Swift, SwiftUI, and AppKit, targeting macOS exclusively.

The app integrates with other applications through native macOS APIs, including AppleScript for Spotify playback state.

## Development Guidelines
- Follow native macOS conventions and existing project patterns.
- Write simple, readable, maintainable code with clear names and focused responsibilities.
- Prefer straightforward solutions over unnecessary abstractions or premature generalization.
- Avoid comments that merely explain code. Add comments only when necessary to clarify non-obvious behavior.
- Respond to the user in Portuguese. Write all code, documentation, identifiers, and necessary comments in technical English.
- Respect the user's requirements and avoid unrequested scope expansion.

## Protected Files and Structure
Do not modify the project structure or the following files without the user's explicit approval:

- `Config/`, `MacIsland.xcodeproj/`, `Assets.xcassets/`
- `InfoPlist.xcstrings`, `Localizable.xcstrings`, `MacIsland.entitlements`
- `MacIslandApp.swift`, `MacIslandState.swift`, `MacIslandView.swift`, `MacIslandWindowController.swift`, `IslandFeature.swift`

This restriction includes moving, renaming, deleting, or changing protected files. Inspect existing implementations before proposing changes.

Before requesting approval, explain:
1. Why the change is necessary.
2. Its expected benefits.
3. The available alternatives.
4. Why the proposed approach is preferred.

Do not proceed with protected changes until approval is granted.