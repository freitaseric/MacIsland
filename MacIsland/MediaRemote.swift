import AppKit
import Foundation

enum MediaRemoteError: Error {
  case unavailable
  case failed
}

struct MediaRemoteSnapshot {
  var title: String
  var artist: String
  var album: String
  var artworkData: Data?
  var isPlaying: Bool
  var duration: TimeInterval
  var elapsedTime: TimeInterval
  var sourceName: String
  var bundleIdentifier: String?
  var prohibitsSkip: Bool
}

enum MediaRemoteCommand: Int32 {
  case togglePlayPause = 2
  case nextTrack = 4
  case previousTrack = 5
}

final class MediaRemote {
  static let shared = MediaRemote()

  private let scriptURL: URL?
  private let frameworkURL: URL?

  private init() {
    scriptURL = Bundle.main.url(
      forResource: "mediaremote-adapter",
      withExtension: "pl"
    )
    frameworkURL = Bundle.main.privateFrameworksURL?
      .appendingPathComponent("MediaRemoteAdapter.framework")
  }

  var isAvailable: Bool {
    guard let scriptURL, let frameworkURL else { return false }

    let fileManager = FileManager.default
    return fileManager.fileExists(atPath: scriptURL.path)
      && fileManager.fileExists(atPath: frameworkURL.path)
      && fileManager.isExecutableFile(atPath: "/usr/bin/perl")
  }

  func snapshot() async throws -> MediaRemoteSnapshot? {
    guard isAvailable, let scriptURL, let frameworkURL else {
      throw MediaRemoteError.unavailable
    }

    let data = try await Self.runAdapter(
      scriptURL: scriptURL,
      frameworkURL: frameworkURL,
      arguments: ["get"]
    )

    guard let object = try? JSONSerialization.jsonObject(with: data) else {
      throw MediaRemoteError.failed
    }

    guard let info = object as? [String: Any] else {
      return nil
    }

    let title = text("title", in: info)
    guard !title.isEmpty else { return nil }

    let bundleIdentifier =
      text("parentApplicationBundleIdentifier", in: info).nilIfEmpty
      ?? text("bundleIdentifier", in: info).nilIfEmpty

    let application = bundleIdentifier.flatMap {
      NSRunningApplication.runningApplications(withBundleIdentifier: $0).first
    }

    let playing = bool("playing", in: info)
      ?? ((number("playbackRate", in: info) ?? 0) > 0)

    let artworkData = text("artworkData", in: info).nilIfEmpty
      .flatMap { Data(base64Encoded: $0) }

    return MediaRemoteSnapshot(
      title: title,
      artist: text("artist", in: info),
      album: text("album", in: info),
      artworkData: artworkData,
      isPlaying: playing,
      duration: max(0, number("duration", in: info) ?? 0),
      elapsedTime: max(0, number("elapsedTime", in: info) ?? 0),
      sourceName: application?.localizedName
        ?? bundleIdentifier
        ?? L10n.featureMedia,
      bundleIdentifier: bundleIdentifier,
      prohibitsSkip: bool("prohibitsSkip", in: info) ?? false
    )
  }

  func send(_ command: MediaRemoteCommand) async -> Bool {
    guard isAvailable, let scriptURL, let frameworkURL else {
      return false
    }

    do {
      _ = try await Self.runAdapter(
        scriptURL: scriptURL,
        frameworkURL: frameworkURL,
        arguments: ["send", String(command.rawValue)]
      )
      return true
    } catch {
      return false
    }
  }

  private static func runAdapter(
    scriptURL: URL,
    frameworkURL: URL,
    arguments: [String]
  ) async throws -> Data {
    try await Task.detached(priority: .userInitiated) {
      let process = Process()
      process.executableURL = URL(fileURLWithPath: "/usr/bin/perl")
      process.arguments =
        [scriptURL.path, frameworkURL.path] + arguments

      let output = Pipe()
      process.standardOutput = output
      process.standardError = FileHandle.nullDevice

      try process.run()

      let watchdog = DispatchWorkItem {
        if process.isRunning {
          process.terminate()
        }
      }
      DispatchQueue.global(qos: .userInitiated)
        .asyncAfter(deadline: .now() + 4, execute: watchdog)

      let data = output.fileHandleForReading.readDataToEndOfFile()
      process.waitUntilExit()
      watchdog.cancel()

      guard process.terminationStatus == 0 else {
        throw MediaRemoteError.failed
      }

      return data
    }.value
  }

  private func text(_ key: String, in info: [String: Any]) -> String {
    (info[key] as? String)?
      .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
  }

  private func number(_ key: String, in info: [String: Any]) -> Double? {
    (info[key] as? NSNumber)?.doubleValue
  }

  private func bool(_ key: String, in info: [String: Any]) -> Bool? {
    (info[key] as? NSNumber)?.boolValue
  }
}

private extension String {
  var nilIfEmpty: String? {
    isEmpty ? nil : self
  }
}
