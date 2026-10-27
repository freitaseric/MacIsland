import Foundation

struct MediaItem: Equatable {
  var title: String
  var artist: String
  var album: String
  var artworkData: Data?
  var isPlaying: Bool
  var duration: TimeInterval
  var position: TimeInterval
  var source: MediaSource
}

struct MediaSource: Equatable {
  var bundleIdentifier: String?
  var name: String
  var allowsTrackNavigation: Bool = true

  var supportsTrackNavigation: Bool {
    guard allowsTrackNavigation, let bundleIdentifier else { return false }
    return !Self.browserBundleIdentifiers.contains(bundleIdentifier)
  }

  private static let browserBundleIdentifiers: Set<String> = [
    "com.apple.Safari",
    "com.apple.SafariTechnologyPreview",
    "com.google.Chrome",
    "com.google.Chrome.canary",
    "company.thebrowser.Browser",
    "com.microsoft.edgemac",
    "org.mozilla.firefox",
    "com.brave.Browser",
    "com.vivaldi.Vivaldi",
    "com.operasoftware.Opera",
  ]
}

enum MediaStatus: Equatable {
  case idle
  case noMedia
  case ready
  case unavailable
  case failed(String)
}
