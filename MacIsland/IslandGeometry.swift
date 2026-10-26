//
//  IslandGeometry.swift
//  MacIsland
//
//  Calcula onde a ilha deve ficar na tela. Em MacBooks com notch, a ilha
//  encosta no topo da tela e o conteúdo começa abaixo da menu bar. Em
//  monitores sem notch, ela flutua logo abaixo da menu bar.
//

import AppKit

struct IslandLayout: Equatable {
  static let compactWidth: CGFloat = 224
  static let expandedWidth: CGFloat = 380
  static let compactContentHeight: CGFloat = 36
  static let expandedContentHeight: CGFloat = 166

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

    // safeAreaInsets.top nem sempre inclui a menu bar inteira, então
    // usamos o maior valor entre ele e a diferença frame/visibleFrame.
    let menuBarHeight = max(0, screen.frame.maxY - screen.visibleFrame.maxY)
    let topInset =
      hasNotch
      ? max(menuBarHeight, screen.safeAreaInsets.top)
      : 0

    // Com notch: topo absoluto da tela, para a ilha "nascer" do notch.
    // Sem notch: 6 pt abaixo da menu bar para não cobrir os ícones.
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
