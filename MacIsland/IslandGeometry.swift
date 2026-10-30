import AppKit

enum IslandPresentation: Equatable {
  case idle
  case peek
  case expanded
}

struct IslandLayout: Equatable {
  static let idleWidth: CGFloat = 280
  static let peekWidth: CGFloat = 280
  static let peekContentHeight: CGFloat = 34
  static let expandedWidth: CGFloat = 320
  static let expandedContentHeight: CGFloat = 170
  static let noNotchWidth: CGFloat = 200
  static let noNotchIdleHeight: CGFloat = 29

  let hasNotch: Bool
  let topInset: CGFloat
  let anchorTop: CGFloat
  let centerX: CGFloat

  func size(for presentation: IslandPresentation) -> CGSize {
    switch presentation {
    case .idle:
      return CGSize(
        width: hasNotch ? Self.idleWidth : Self.noNotchWidth,
        height: hasNotch ? topInset : Self.noNotchIdleHeight
      )
    case .peek:
      return CGSize(
        width: hasNotch ? Self.peekWidth : Self.noNotchWidth,
        height: topInset + Self.peekContentHeight
      )
    case .expanded:
      return CGSize(
        width: Self.expandedWidth,
        height: topInset + Self.expandedContentHeight
      )
    }
  }

  func frame(for presentation: IslandPresentation) -> NSRect {
    let size = size(for: presentation)
    return NSRect(
      x: (centerX - size.width / 2).rounded(),
      y: (anchorTop - size.height).rounded(),
      width: size.width,
      height: size.height
    )
  }

  static func make(for screen: NSScreen) -> IslandLayout {
    let hasNotch =
      screen.auxiliaryTopLeftArea != nil
      && screen.auxiliaryTopRightArea != nil

    let menuBarHeight = max(0, screen.frame.maxY - screen.visibleFrame.maxY)
    let topInset =
      hasNotch
      ? max(menuBarHeight, screen.safeAreaInsets.top)
      : 0

    let anchorTop =
      hasNotch
      ? screen.frame.maxY
      : screen.visibleFrame.maxY - 6

    return IslandLayout(
      hasNotch: hasNotch,
      topInset: topInset,
      anchorTop: anchorTop,
      centerX: screen.frame.midX
    )
  }
}
