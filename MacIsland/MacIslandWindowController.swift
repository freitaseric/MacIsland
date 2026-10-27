import AppKit
import Combine
import SwiftUI

private final class MacIslandPanel: NSPanel {
  override var canBecomeKey: Bool { true }
  override var canBecomeMain: Bool { false }

  override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
    frameRect
  }
}

private final class IslandHostingView<Content: View>: NSHostingView<Content> {
  var onHoverChange: ((Bool) -> Void)?
  var onCompactClick: (() -> Void)?
  var isExpanded: (() -> Bool)?

  private var hoverTrackingArea: NSTrackingArea?

  override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
    true
  }

  override func updateTrackingAreas() {
    super.updateTrackingAreas()

    if let hoverTrackingArea {
      removeTrackingArea(hoverTrackingArea)
    }

    let area = NSTrackingArea(
      rect: .zero,
      options: [
        .mouseEnteredAndExited,
        .activeAlways,
        .inVisibleRect,
      ],
      owner: self,
      userInfo: nil
    )
    addTrackingArea(area)
    hoverTrackingArea = area
  }

  override func mouseEntered(with event: NSEvent) {
    onHoverChange?(true)
  }

  override func mouseExited(with event: NSEvent) {
    onHoverChange?(false)
  }

  override func mouseDown(with event: NSEvent) {
    window?.makeKey()

    if isExpanded?() == false {
      onCompactClick?()
      return
    }

    super.mouseDown(with: event)
  }
}

@MainActor
final class MacIslandWindowController {
  private let state: MacIslandState
  private let music: MusicService
  private let timer: TimerService

  private var panel: MacIslandPanel?
  private var layout: IslandLayout?
  private var collapseTask: Task<Void, Never>?
  private var hoverTask: Task<Void, Never>?
  private var escapeMonitor: Any?
  private var cancellables = Set<AnyCancellable>()
  private var isManuallyHidden = false

  init(state: MacIslandState, music: MusicService, timer: TimerService) {
    self.state = state
    self.music = music
    self.timer = timer
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

    panel.isFloatingPanel = true
    panel.level = .statusBar
    panel.backgroundColor = .clear
    panel.isOpaque = false
    panel.hasShadow = false
    panel.hidesOnDeactivate = false
    panel.isReleasedWhenClosed = false
    panel.isMovableByWindowBackground = false
    panel.becomesKeyOnlyIfNeeded = true
    panel.acceptsMouseMovedEvents = true
    panel.animationBehavior = .none
    panel.collectionBehavior = [
      .canJoinAllSpaces,
      .stationary,
      .ignoresCycle,
    ]

    let hostingView = IslandHostingView(
      rootView: MacIslandView(
        state: state,
        music: music,
        timer: timer
      )
    )
    hostingView.onHoverChange = { [weak self] hovering in
      self?.handleHover(hovering)
    }
    hostingView.onCompactClick = { [weak self] in
      self?.state.expand()
    }
    hostingView.isExpanded = { [weak self] in
      self?.state.isExpanded ?? false
    }
    panel.contentView = hostingView

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

    NotificationCenter.default.publisher(
      for: NSWindow.didResignKeyNotification,
      object: panel
    )
    .sink { [weak self] _ in
      guard let self, self.state.isExpanded else { return }
      self.state.collapse()
    }
    .store(in: &cancellables)

    escapeMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
      [weak self] event in
      guard let self, self.panel?.isKeyWindow == true else {
        return event
      }

      if event.keyCode == 53, self.state.isExpanded {
        self.state.collapse()
        return nil
      }

      return event
    }

    updateVisibility()
  }

  func setVisible(_ visible: Bool) {
    isManuallyHidden = !visible
    updateVisibility()
  }

  private func updateVisibility() {
    guard let panel else { return }

    if isManuallyHidden {
      panel.orderOut(nil)
    } else {
      panel.orderFrontRegardless()
    }
  }

  private func targetScreen() -> NSScreen? {
    NSScreen.screens.first(where: {
      $0.auxiliaryTopLeftArea != nil && $0.auxiliaryTopRightArea != nil
    }) ?? NSScreen.main ?? NSScreen.screens.first
  }

  private func handleHover(_ hovering: Bool) {
    hoverTask?.cancel()

    if hovering {
      guard !state.isExpanded else { return }

      hoverTask = Task { [weak self] in
        try? await Task.sleep(for: .milliseconds(150))
        guard !Task.isCancelled, let self else { return }
        self.state.expand()
      }
    } else if state.isExpanded {
      hoverTask = Task { [weak self] in
        try? await Task.sleep(for: .milliseconds(400))
        guard !Task.isCancelled, let self, self.state.isExpanded else {
          return
        }
        self.state.collapse()
      }
    }
  }

  private func handleExpansionChange(_ expanded: Bool) {
    collapseTask?.cancel()

    if expanded {
      applyExpandedFrameAfterStateCommit()
      return
    }

    collapseTask = Task { [weak self] in
      try? await Task.sleep(for: .milliseconds(420))
      guard !Task.isCancelled, let self, !self.state.isExpanded else {
        return
      }
      self.applyFrame(expanded: false)
    }
  }

  private func applyExpandedFrameAfterStateCommit() {
    DispatchQueue.main.async { [weak self] in
      guard let self, self.state.isExpanded else { return }
      self.applyFrame(expanded: true)
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
