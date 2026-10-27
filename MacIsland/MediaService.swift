import Combine
import Foundation

@MainActor
final class MediaService: ObservableObject {
  @Published private(set) var item: MediaItem?
  @Published private(set) var status: MediaStatus = .idle
  @Published private(set) var isCommandInFlight = false

  private var pollTask: Task<Void, Never>?
  private var isRefreshing = false
  private(set) var positionReferenceDate = Date.distantPast

  var canControl: Bool {
    status == .ready && item != nil && !isCommandInFlight
  }

  var canSkip: Bool {
    item?.source.supportsTrackNavigation ?? false
  }

  func start() {
    guard pollTask == nil else { return }

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
  }

  func refresh() async {
    guard !isRefreshing, !isCommandInFlight else { return }
    isRefreshing = true
    defer { isRefreshing = false }

    guard MediaRemote.shared.isAvailable else {
      item = nil
      if status != .unavailable {
        status = .unavailable
      }
      return
    }

    do {
      guard let snapshot = try await MediaRemote.shared.snapshot() else {
        clear()
        return
      }
      apply(snapshot)
    } catch MediaRemoteError.unavailable {
      item = nil
      status = .unavailable
    } catch {
      item = nil
      status = .failed(L10n.readErrorGeneric)
    }
  }

  func togglePlayback() {
    guard canControl, let current = item else { return }

    updateLocalPlayback(!current.isPlaying)
    send(.togglePlayPause)
  }

  func next() {
    guard canControl, canSkip else { return }
    send(.nextTrack)
  }

  func previous() {
    guard canControl, canSkip else { return }
    send(.previousTrack)
  }

  func retry() {
    Task { await refresh() }
  }

  func position(at date: Date = Date()) -> TimeInterval {
    guard let item else { return 0 }

    let elapsed =
      item.isPlaying && positionReferenceDate != .distantPast
      ? max(0, date.timeIntervalSince(positionReferenceDate))
      : 0

    let position = max(item.position + elapsed, 0)
    return item.duration > 0 ? min(position, item.duration) : position
  }

  private func apply(_ snapshot: MediaRemoteSnapshot) {
    let newItem = MediaItem(
      title: snapshot.title.isEmpty
        ? snapshot.sourceName
        : snapshot.title,
      artist: snapshot.artist,
      album: snapshot.album,
      artworkData: snapshot.artworkData,
      isPlaying: snapshot.isPlaying,
      duration: snapshot.duration,
      position: snapshot.elapsedTime,
      source: MediaSource(
        bundleIdentifier: snapshot.bundleIdentifier,
        name: snapshot.sourceName,
        allowsTrackNavigation: !snapshot.prohibitsSkip
      )
    )

    if item != newItem {
      item = newItem
    }
    positionReferenceDate = Date()
    if status != .ready {
      status = .ready
    }
  }

  private func clear() {
    item = nil
    if status != .noMedia {
      status = .noMedia
    }
  }

  private func updateLocalPlayback(_ isPlaying: Bool) {
    guard var updated = item else { return }

    updated.position = position(at: Date())
    updated.isPlaying = isPlaying
    item = updated
    positionReferenceDate = Date()
  }

  private func send(_ command: MediaRemoteCommand) {
    guard !isCommandInFlight else { return }

    isCommandInFlight = true

    Task { [weak self] in
      guard let self else { return }

      let sent = await MediaRemote.shared.send(command)
      if sent {
        try? await Task.sleep(for: .milliseconds(350))
      }

      self.isCommandInFlight = false
      await self.refresh()
    }
  }
}
