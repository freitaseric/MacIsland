import AppKit
import Combine
import Foundation

struct SpotifyTrack: Equatable {
  var title: String
  var artist: String
  var album: String
  var artworkURL: URL?
  var isPlaying: Bool
  var duration: TimeInterval
  var position: TimeInterval

}

enum PlaybackStatus: Equatable {
  case idle
  case loading
  case spotifyNotRunning
  case noTrack
  case ready
  case automationDenied
  case failed(String)
}

private enum AppleScriptFailure: Error {
  case automationDenied
  case spotifyNotRunning
  case noTrack
  case timedOut
  case malformed
  case other(String)

  static func classify(_ error: NSDictionary?) -> AppleScriptFailure {
    guard let error else {
      return .other(L10n.errorNoResponse)
    }

    let code = error[NSAppleScript.errorNumber] as? Int ?? 0
    let message =
      error[NSAppleScript.errorMessage] as? String
      ?? String(format: L10n.errorAppleScriptCodeFormat, code)

    switch code {
    case -1743, -10004:
      return .automationDenied
    case -600:
      return .spotifyNotRunning
    case -1728:
      return .noTrack
    case -1712:
      return .timedOut
    default:
      return .other(message)
    }
  }
}

private struct SpotifySnapshot {
  let title: String
  let artist: String
  let album: String
  let artworkURL: URL?
  let isPlaying: Bool
  let duration: TimeInterval
  let position: TimeInterval
}

private enum SpotifyCommand {
  case playPause
  case next
  case previous

  var source: String {
    let action: String
    switch self {
    case .playPause:
      action = "playpause"
    case .next:
      action = "next track"
    case .previous:
      action = "previous track"
    }

    return """
      with timeout of 2 seconds
          tell application "Spotify" to \(action)
      end timeout
      """
  }
}

@MainActor
final class MusicService: ObservableObject {
  static let spotifyBundleID = "com.spotify.client"

  @Published private(set) var track: SpotifyTrack?
  @Published private(set) var status: PlaybackStatus = .idle
  @Published private(set) var isCommandInFlight = false

  private var pollTask: Task<Void, Never>?
  private var isRefreshing = false
  private var workspaceObservers: [NSObjectProtocol] = []
  private(set) var positionReferenceDate = Date.distantPast

  var canControl: Bool {
    status == .ready && track != nil && !isCommandInFlight
  }

  func start() {
    guard pollTask == nil else { return }

    observeSpotifyLifecycle()

    pollTask = Task { [weak self] in
      while !Task.isCancelled {
        guard let self else { return }
        await self.refresh()
        try? await Task.sleep(for: .seconds(2))
      }
    }
  }

  func stop() {
    pollTask?.cancel()
    pollTask = nil

    let center = NSWorkspace.shared.notificationCenter
    workspaceObservers.forEach(center.removeObserver)
    workspaceObservers.removeAll()
  }

  func refresh() async {
    guard !isRefreshing, !isCommandInFlight else { return }
    isRefreshing = true
    defer { isRefreshing = false }

    guard isSpotifyRunning else {
      track = nil
      if status != .spotifyNotRunning {
        status = .spotifyNotRunning
      }
      return
    }

    if track == nil, status == .idle || status == .spotifyNotRunning {
      status = .loading
    }

    do {
      let snapshot = try await Self.fetchSnapshot()
      apply(snapshot)
    } catch {
      handle(error)
    }
  }

  func togglePlayback() {
    guard canControl else { return }

    if var updated = track {
      updated.isPlaying.toggle()
      track = updated
    }

    send(.playPause)
  }

  func next() {
    guard canControl else { return }
    send(.next)
  }

  func previous() {
    guard canControl else { return }
    send(.previous)
  }

  func retry() {
    Task { await refresh() }
  }

  func position(at date: Date = Date()) -> TimeInterval {
    guard let track else { return 0 }

    let elapsed =
      track.isPlaying && positionReferenceDate != .distantPast
      ? max(0, date.timeIntervalSince(positionReferenceDate))
      : 0

    return min(max(track.position + elapsed, 0), track.duration)
  }

  func openSpotify() {
    if let url = NSWorkspace.shared.urlForApplication(
      withBundleIdentifier: Self.spotifyBundleID
    ) {
      NSWorkspace.shared.openApplication(
        at: url,
        configuration: NSWorkspace.OpenConfiguration()
      ) { _, _ in }
    } else if let webURL = URL(string: "https://open.spotify.com") {
      NSWorkspace.shared.open(webURL)
    }
  }

  func openAutomationSettings() {
    let raw = "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation"
    guard let url = URL(string: raw) else { return }
    NSWorkspace.shared.open(url)
  }

  private func observeSpotifyLifecycle() {
    let center = NSWorkspace.shared.notificationCenter
    let bundleID = Self.spotifyBundleID
    let names: [Notification.Name] = [
      NSWorkspace.didLaunchApplicationNotification,
      NSWorkspace.didTerminateApplicationNotification,
    ]

    for name in names {
      let token = center.addObserver(
        forName: name,
        object: nil,
        queue: .main
      ) { [weak self] notification in
        guard
          let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey]
            as? NSRunningApplication,
          app.bundleIdentifier == bundleID
        else {
          return
        }

        Task { @MainActor in
          await self?.refresh()
        }
      }
      workspaceObservers.append(token)
    }
  }

  private var isSpotifyRunning: Bool {
    NSWorkspace.shared.runningApplications.contains {
      $0.bundleIdentifier == Self.spotifyBundleID
    }
  }

  private func apply(_ snapshot: SpotifySnapshot) {
    guard !snapshot.title.isEmpty else {
      track = nil
      if status != .noTrack {
        status = .noTrack
      }
      return
    }

    let newTrack = SpotifyTrack(
      title: snapshot.title,
      artist: snapshot.artist,
      album: snapshot.album,
      artworkURL: snapshot.artworkURL,
      isPlaying: snapshot.isPlaying,
      duration: snapshot.duration,
      position: snapshot.position
    )

    if track != newTrack {
      track = newTrack
    }
    positionReferenceDate = Date()
    if status != .ready {
      status = .ready
    }
  }

  private func handle(_ error: Error) {
    let failure =
      error as? AppleScriptFailure
      ?? .other(error.localizedDescription)

    switch failure {
    case .automationDenied:
      status = .automationDenied
    case .spotifyNotRunning:
      track = nil
      status = .spotifyNotRunning
    case .noTrack:
      track = nil
      status = .noTrack
    case .timedOut:
      status = .failed(L10n.readErrorTimeout)
    case .malformed:
      status = .failed(L10n.readErrorMalformed)
    case .other(let message):
      status = .failed(message.isEmpty ? L10n.readErrorGeneric : message)
    }
  }

  private func send(_ command: SpotifyCommand) {
    guard !isCommandInFlight else { return }

    isCommandInFlight = true
    let source = command.source

    Task { [weak self] in
      guard let self else { return }

      do {
        try await Self.execute(source)
        self.isCommandInFlight = false

        try? await Task.sleep(for: .milliseconds(350))
        await self.refresh()
      } catch {
        self.isCommandInFlight = false
        self.handle(error)
      }
    }
  }

  nonisolated private static func execute(_ source: String) async throws {
    try await Task.detached(priority: .userInitiated) {
      guard let script = NSAppleScript(source: source) else {
        throw AppleScriptFailure.malformed
      }

      var error: NSDictionary?
      guard script.compileAndReturnError(&error) else {
        throw AppleScriptFailure.classify(error)
      }

      _ = script.executeAndReturnError(&error)
      if let error {
        throw AppleScriptFailure.classify(error)
      }
    }.value
  }

  nonisolated private static func fetchSnapshot() async throws -> SpotifySnapshot {
    try await Task.detached(priority: .userInitiated) {
      let source = """
        with timeout of 3 seconds
            tell application "Spotify"
                set tName to name of current track
                set tArtist to artist of current track
                set tAlbum to ""
                try
                    set tAlbum to album of current track
                end try
                set tArtwork to ""
                try
                    set tArtwork to artwork url of current track
                end try
                if player state is playing then
                    set playingFlag to 1
                else
                    set playingFlag to 0
                end if
                set totalSeconds to (duration of current track) div 1000
                set currentSeconds to (player position) as integer
                return {tName, tArtist, tAlbum, tArtwork, playingFlag, totalSeconds, currentSeconds}
            end tell
        end timeout
        """

      guard let script = NSAppleScript(source: source) else {
        throw AppleScriptFailure.malformed
      }

      var error: NSDictionary?
      guard script.compileAndReturnError(&error) else {
        throw AppleScriptFailure.classify(error)
      }

      let result = script.executeAndReturnError(&error)
      if let error {
        throw AppleScriptFailure.classify(error)
      }

      guard result.numberOfItems >= 7 else {
        throw AppleScriptFailure.malformed
      }

      func field(_ index: Int) -> String {
        result.atIndex(index)?.stringValue ?? ""
      }

      let title = field(1).trimmingCharacters(in: .whitespacesAndNewlines)
      let artist = field(2).trimmingCharacters(in: .whitespacesAndNewlines)
      let album = field(3).trimmingCharacters(in: .whitespacesAndNewlines)
      let artworkString = field(4).trimmingCharacters(in: .whitespacesAndNewlines)
      let isPlaying = (result.atIndex(5)?.int32Value ?? 0) == 1
      let duration = TimeInterval(max(0, result.atIndex(6)?.int32Value ?? 0))
      let position = TimeInterval(max(0, result.atIndex(7)?.int32Value ?? 0))

      let artworkURL: URL?
      if artworkString.hasPrefix("https://") || artworkString.hasPrefix("http://") {
        artworkURL = URL(string: artworkString)
      } else {
        artworkURL = nil
      }

      return SpotifySnapshot(
        title: title,
        artist: artist,
        album: album,
        artworkURL: artworkURL,
        isPlaying: isPlaying,
        duration: duration,
        position: position
      )
    }.value
  }
}
