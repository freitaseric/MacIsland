import AppKit
import ServiceManagement
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
  private var windowController: MacIslandWindowController?
  private var media: MediaService?
  private var timer: TimerService?
  private var statusItem: NSStatusItem?
  private var visibilityItem: NSMenuItem?
  private var launchAtLoginItem: NSMenuItem?

  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.setActivationPolicy(.accessory)

    let state = MacIslandState()
    let media = MediaService()
    let timer = TimerService()
    let controller = MacIslandWindowController(
      state: state,
      media: media,
      timer: timer
    )

    self.media = media
    self.timer = timer
    windowController = controller

    setupStatusItem()
    controller.show()
    media.start()
  }

  func applicationWillTerminate(_ notification: Notification) {
    media?.stop()
    timer?.stop()
  }

  private func setupStatusItem() {
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    if let button = item.button, let icon = NSImage(named: "StatusIcon") {
      icon.isTemplate = true
      icon.accessibilityDescription = "MacIsland"
      button.image = icon
    }

    let menu = NSMenu()
    menu.delegate = self

    let visibility = NSMenuItem(
      title: L10n.menuHideIsland,
      action: #selector(toggleVisibility),
      keyEquivalent: ""
    )
    visibility.target = self
    menu.addItem(visibility)
    visibilityItem = visibility

    menu.addItem(.separator())

    let launchAtLogin = NSMenuItem(
      title: L10n.menuOpenAtLogin,
      action: #selector(toggleLaunchAtLogin),
      keyEquivalent: ""
    )
    launchAtLogin.target = self
    menu.addItem(launchAtLogin)
    launchAtLoginItem = launchAtLogin

    menu.addItem(.separator())

    let about = NSMenuItem(
      title: L10n.menuAbout,
      action: #selector(showAbout),
      keyEquivalent: ""
    )
    about.target = self
    menu.addItem(about)

    menu.addItem(.separator())

    let quit = NSMenuItem(
      title: L10n.menuQuit,
      action: #selector(quitApp),
      keyEquivalent: "q"
    )
    quit.target = self
    menu.addItem(quit)

    item.menu = menu
    statusItem = item

    updateMenuState()
  }

  func menuWillOpen(_ menu: NSMenu) {
    updateMenuState()
  }

  private func updateMenuState() {
    launchAtLoginItem?.state = SMAppService.mainApp.status == .enabled ? .on : .off
    visibilityItem?.title = (windowController?.isVisible ?? true)
      ? L10n.menuHideIsland
      : L10n.menuShowIsland
  }

  @objc private func toggleVisibility() {
    guard let windowController else { return }

    windowController.setVisible(!windowController.isVisible)
    updateMenuState()
  }

  @objc private func toggleLaunchAtLogin() {
    let service = SMAppService.mainApp

    switch service.status {
    case .enabled:
      do {
        try service.unregister()
      } catch {
        presentLoginItemError(error)
      }

    case .requiresApproval:
      presentAlert(
        title: L10n.menuOpenAtLogin,
        message: L10n.loginItemRequiresApproval
      )
      openLoginItemsSettings()

    default:
      do {
        try service.register()
        if service.status == .requiresApproval {
          presentAlert(
            title: L10n.menuOpenAtLogin,
            message: L10n.loginItemRequiresApproval
          )
        }
      } catch {
        presentLoginItemError(error)
      }
    }

    updateMenuState()
  }

  @objc private func showAbout() {
    NSApp.activate(ignoringOtherApps: true)

    let version = Bundle.main.object(
      forInfoDictionaryKey: "CFBundleShortVersionString"
    ) as? String ?? "1.0.0"

    let build = Bundle.main.object(
      forInfoDictionaryKey: "CFBundleVersion"
    ) as? String ?? "1"

    let repository = "https://github.com/freitaseric/MacIsland"
    let creditsText = L10n.aboutCredits + "\n" + repository
    let credits = NSMutableAttributedString(
      string: creditsText,
      attributes: [
        .font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize),
        .foregroundColor: NSColor.secondaryLabelColor,
      ]
    )
    if let range = creditsText.range(of: repository) {
      credits.addAttribute(
        .link,
        value: URL(string: repository)!,
        range: NSRange(range, in: creditsText)
      )
    }

    NSApp.orderFrontStandardAboutPanel(options: [
      .applicationName: "MacIsland",
      .applicationVersion: version,
      .version: build,
      .credits: credits,
    ])
  }

  @objc private func quitApp() {
    NSApp.terminate(nil)
  }

  private func presentLoginItemError(_ error: Error) {
    presentAlert(
      title: L10n.loginItemErrorTitle,
      message: String(format: L10n.loginItemErrorFormat, error.localizedDescription)
    )
  }

  private func presentAlert(title: String, message: String) {
    let alert = NSAlert()
    alert.messageText = title
    alert.informativeText = message
    alert.alertStyle = .warning
    alert.addButton(withTitle: "OK")

    NSApp.activate(ignoringOtherApps: true)
    alert.runModal()
  }

  private func openLoginItemsSettings() {
    let url = URL(
      string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension"
    )
    if let url {
      NSWorkspace.shared.open(url)
    }
  }
}

@main
struct MacIslandApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self)
  private var appDelegate

  var body: some Scene {
    Settings {
      EmptyView()
    }
  }
}
