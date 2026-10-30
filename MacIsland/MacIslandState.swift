import Combine
import SwiftUI

@MainActor
final class MacIslandState: ObservableObject {
  @Published private(set) var presentation: IslandPresentation = .idle
  @Published private(set) var activeFeature: IslandFeature = .media
  @Published private(set) var layout: IslandLayout?

  var isExpanded: Bool { presentation == .expanded }
  var hasNotch: Bool { layout?.hasNotch ?? false }
  var topInset: CGFloat { layout?.topInset ?? 0 }
  var islandSize: CGSize { layout?.size(for: presentation) ?? .zero }

  func apply(layout: IslandLayout) {
    guard self.layout != layout else { return }
    self.layout = layout
  }

  func select(_ feature: IslandFeature) {
    guard activeFeature != feature else { return }
    activeFeature = feature
  }

  func showPeek() {
    guard presentation == .idle else { return }
    presentation = .peek
  }

  func rest() {
    guard presentation == .peek else { return }
    presentation = .idle
  }

  func expand() {
    guard presentation != .expanded else { return }
    presentation = .expanded
  }

  func collapse() {
    guard presentation == .expanded else { return }
    presentation = hasNotch ? .idle : .peek
  }
}
