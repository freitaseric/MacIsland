//
//  MacIslandState.swift
//  MacIsland
//
//  Created by Eric Freitas Sampaio on 26/10/26.
//

import Combine
import SwiftUI

@MainActor
final class MacIslandState: ObservableObject {
  @Published private(set) var isExpanded = false
  @Published private(set) var hasNotch = false
  @Published private(set) var topInset: CGFloat = 0

  func apply(layout: IslandLayout) {
    if hasNotch != layout.hasNotch {
      hasNotch = layout.hasNotch
    }
    if topInset != layout.topInset {
      topInset = layout.topInset
    }
  }

  func expand() {
    guard !isExpanded else { return }
    isExpanded = true
  }

  func collapse() {
    guard isExpanded else { return }
    isExpanded = false
  }

}
