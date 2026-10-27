import Foundation

enum IslandFeature: String, CaseIterable, Identifiable {
    case media
    case timer

    var id: String { rawValue }

    var title: String {
        switch self {
        case .media:
            L10n.featureMedia
        case .timer:
            L10n.featureTimer
        }
    }

    var symbolName: String {
        switch self {
        case .media:
            "play.rectangle"
        case .timer:
            "timer"
        }
    }
}
