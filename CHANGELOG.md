# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0] - 2026-10-30

### Changed

- The island now rests as a 280 pt wide band on the menu bar, centered on the
  notch and exactly as tall as it, showing only the artwork on the left and a
  single indicator on the right (the playback equalizer, or the timer progress
  bar). It adds no height below the menu bar and renders no text.
- Hovering the island reveals the title and artist as a compact peek and
  clicking expands it, replacing the previous hover-to-expand behavior.
- Expanding and collapsing are now anchored to the top edge of the screen and
  driven by a single spring, so the island unfurls downward from the notch
  instead of jumping or sliding into place.
- The expanded panel is smaller and denser: 320×170 pt of content instead of
  380×200 pt, with tighter artwork, controls, and feature picker.

<!-- 1.2.0 is source-only for now: no tag or GitHub release until the app can be notarized. -->
## [1.1.0] - 2026-10-27

### Added

- Media integration backed by the macOS Now Playing session. It works with
  Spotify, Apple Music, Podcasts, Safari (YouTube, Netflix, Instagram), Chrome,
  and any other app that publishes media to the system. Direct access is
  provided by the bundled BSD-3-licensed `mediaremote-adapter`, loaded through
  `/usr/bin/perl` because macOS 15.4+ restricts direct MediaRemote access.
- Playback controls now use the same system channel as the media keys, with
  previous/next shown only when the current source supports them.

### Changed

- Renamed the Spotify feature to Media throughout the app, including the feature
  picker, service, models, statuses, and localization.
- Removed the AppleScript integration and the Automation permission prompt;
  media metadata is read locally from the system Now Playing session.
- Removed the unused Apple Events automation entitlement and its usage
  description from the app and Xcode project.
- Simplified the menu bar menu to show/hide the island, Open at Login, About,
  and Quit. Redundant Spotify, timer, refresh, and expand/collapse commands
  were removed because the island exposes those actions directly.
- The menu bar icon now shows the MacIsland logo instead of a generic waveform
  symbol. It ships as a vector template image, so macOS tints it automatically
  for light and dark menu bars.
- The app icon now ships as an Icon Composer document with layered Liquid Glass
  artwork, giving the Dock, Finder, and Launchpad native default, dark, tinted,
  and clear appearances.

<!-- 1.0.1 is a source-only hotfix: no tag or GitHub release until the app can be notarized. -->
## [1.0.1] - 2026-10-27

### Fixed

- Expanding the island now renders the expanded content immediately when
  Spotify is paused, has no track loaded, or is closed. Previously the window
  frame grew but the compact content remained visible until a playback update
  forced a redraw.

## [1.0.0] - 2026-10-26

### Added

- Notch-anchored dynamic island for the Mac; Spotify is the first integration.
- Compact and expanded island states with album artwork, title, artist, album,
  progress, and playback controls.
- Focus timer with 5, 15, and 25-minute presets, start/pause/reset, local
  notifications, and a compact countdown.
- Feature switcher between Spotify and the timer.
- Hover to expand, Escape and click-outside to collapse.
- Expand or collapse from the menu bar at any time, including when Spotify is
  paused or not running.
- The island stays out of native full-screen apps and returns when you go back
  to the desktop.
- Smooth progress interpolation between Spotify polls.
- Play/pause, previous, and next controls with optimistic UI updates.
- Automatic refresh when Spotify opens or quits.
- Clear permission, Spotify-closed, no-track, and error states.
- Menu bar item with show/hide, refresh, Open at Login, About, and Quit.
- English and Brazilian Portuguese localization, including timer strings.
- Native app icon.
- Open at Login support (`SMAppService`).
- Single-instance protection.
- Hardened Runtime with the Apple Events automation entitlement.
- GitHub Actions build workflow and signed/notarized release workflow.
- A product structure designed to grow beyond a single integration.

### Known limitations

- Spotify is the only music source; the focus timer is the first non-music
  integration.
- There is no plugin system for third-party features yet.
- The timer stops if the app quits.
- The app is distributed outside the App Store and runs without the App Sandbox.
- Automatic updates are not implemented.
- Requires macOS 14 Sonoma or later.

[Unreleased]: https://github.com/freitaseric/MacIsland/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/freitaseric/MacIsland/releases/tag/v1.2.0
[1.1.0]: https://github.com/freitaseric/MacIsland/releases/tag/v1.1.0
[1.0.0]: https://github.com/freitaseric/MacIsland/releases/tag/v1.0.0
