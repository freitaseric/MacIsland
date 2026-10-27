import AppKit

struct IslandLayout: Equatable {
  static let compactWidth: CGFloat = 224
  static let expandedWidth: CGFloat = 380
  static let compactContentHeight: CGFloat = 36
  static let expandedContentHeight: CGFloat = 200

  let hasNotch: Bool
  let topInset: CGFloat
  let anchorTop: CGFloat
  let centerX: CGFloat

  func size(expanded: Bool) -> CGSize {
    CGSize(
      width: expanded ? Self.expandedWidth : Self.compactWidth,
      height: topInset + (expanded ? Self.expandedContentHeight : Self.compactContentHeight)
    )
  }

  func frame(expanded: Bool) -> NSRect {
    let size = size(expanded: expanded)
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
