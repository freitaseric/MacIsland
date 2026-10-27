import Foundation

enum IslandFeature: String, CaseIterable, Identifiable {
    case spotify
    case timer

    var id: String { rawValue }

    var title: String {
        switch self {
        case .spotify:
            L10n.featureSpotify
        case .timer:
            L10n.featureTimer
        }
    }

    var symbolName: String {
        switch self {
        case .spotify:
            "music.note"
        case .timer:
            "timer"
        }
    }
}
