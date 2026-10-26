//
//  MacIslandWindowController.swift
//  MacIsland
//
//  Created by Eric Freitas Sampaio on 26/10/26.
//

import AppKit
import Combine
import SwiftUI

private final class MacIslandPanel: NSPanel {
  override var canBecomeKey: Bool { true }
  override var canBecomeMain: Bool { false }

  // Por padrão o AppKit empurra a janela para baixo da menu bar. Como a
  // ilha precisa encostar no topo (e cobrir o notch), liberamos o frame.
  override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
    frameRect
  }
}

/// Faz o primeiro clique funcionar mesmo com a ilha sem foco.
private final class IslandHostingView<Content: View>: NSHostingView<Content> {
  override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
    true
  }
}

@MainActor
final class MacIslandWindowController {
  private let state: MacIslandState
  private let music: MusicService

  private var panel: MacIslandPanel?
  private var layout: IslandLayout?
  private var collapseTask: Task<Void, Never>?
  private var cancellables = Set<AnyCancellable>()

  init(state: MacIslandState, music: MusicService) {
    self.state = state
    self.music = music
  }

  var isVisible: Bool {
    panel?.isVisible ?? false
  }

  func show() {
    if let panel {
      panel.orderFrontRegardless()
      return
    }

    guard let screen = targetScreen() else { return }

    let layout = IslandLayout.make(for: screen)
    self.layout = layout
    state.apply(layout: layout)

    let panel = MacIslandPanel(
      contentRect: layout.frame(expanded: state.isExpanded),
      styleMask: [.borderless, .nonactivatingPanel],
      backing: .buffered,
      defer: false
    )

    // isFloatingPanel muda o nível para .floating; por isso ele vem
    // ANTES de fixarmos o nível acima da menu bar.
    panel.isFloatingPanel = true
    panel.level = .statusBar
    panel.backgroundColor = .clear
    panel.isOpaque = false
    panel.hasShadow = false
    panel.hidesOnDeactivate = false
    panel.isReleasedWhenClosed = false
    panel.isMovableByWindowBackground = false
    panel.becomesKeyOnlyIfNeeded = true
    panel.animationBehavior = .none
    panel.collectionBehavior = [
      .canJoinAllSpaces,
      .fullScreenAuxiliary,
      .stationary,
      .ignoresCycle,
    ]

    panel.contentView = IslandHostingView(
      rootView: MacIslandView(state: state, music: music)
    )

    self.panel = panel

    state.$isExpanded
      .removeDuplicates()
      .dropFirst()
      .sink { [weak self] expanded in
        self?.handleExpansionChange(expanded)
      }
      .store(in: &cancellables)

    NotificationCenter.default.publisher(
      for: NSApplication.didChangeScreenParametersNotification
    )
    .sink { [weak self] _ in
      self?.reposition()
    }
    .store(in: &cancellables)

    panel.orderFrontRegardless()
  }

  func setVisible(_ visible: Bool) {
    guard let panel else { return }

    if visible {
      panel.orderFrontRegardless()
    } else {
      panel.orderOut(nil)
    }
  }

  // MARK: - Layout

  private func targetScreen() -> NSScreen? {
    // A ilha pertence ao MacBook: prioriza a tela com notch e só depois
    // a tela principal (evita ela pular para um monitor externo).
    NSScreen.screens.first(where: {
      $0.auxiliaryTopLeftArea != nil && $0.auxiliaryTopRightArea != nil
    }) ?? NSScreen.main ?? NSScreen.screens.first
  }

  private func handleExpansionChange(_ expanded: Bool) {
    collapseTask?.cancel()

    if expanded {
      applyFrame(expanded: true)
      return
    }

    // Deixa o SwiftUI terminar de encolher antes de diminuir a janela:
    // assim nada é cortado no meio da animação.
    collapseTask = Task { [weak self] in
      try? await Task.sleep(for: .milliseconds(420))
      guard !Task.isCancelled, let self, !self.state.isExpanded else {
        return
      }
      self.applyFrame(expanded: false)
    }
  }

  private func applyFrame(expanded: Bool) {
    guard let panel, let layout else { return }
    panel.setFrame(
      layout.frame(expanded: expanded),
      display: true,
      animate: false
    )
  }

  private func reposition() {
    guard let panel, let screen = targetScreen() else { return }

    let layout = IslandLayout.make(for: screen)
    self.layout = layout
    state.apply(layout: layout)
    panel.setFrame(
      layout.frame(expanded: state.isExpanded),
      display: true,
      animate: false
    )
  }
}
