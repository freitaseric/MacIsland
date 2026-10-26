# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-10-26

### Added

- Notch-anchored dynamic island for the Mac; Spotify is the first integration.
- Compact and expanded island states with album artwork, title, artist, album,
  progress, and playback controls.
- Focus timer with 5, 15, and 25-minute presets, start/pause/reset, local
  notifications, and a compact countdown.
- Feature switcher between Spotify and the timer.
- Hover to expand, Escape and click-outside to collapse.
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

[Unreleased]: https://github.com/freitaseric/MacIsland/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/freitaseric/MacIsland/releases/tag/v1.0.0
