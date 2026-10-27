import Foundation

nonisolated enum L10n {

  static let connectingTitle = String(
    localized: "status.connecting.title",
    defaultValue: "Connecting to media",
    comment: "Expanded island title while waiting for the current media session"
  )

  static let connectingMessage = String(
    localized: "status.connecting.message",
    defaultValue: "Waiting for media to play…",
    comment: "Expanded island message while waiting for media"
  )

  static let nothingPlayingTitle = String(
    localized: "status.nothing_playing.title",
    defaultValue: "Nothing playing",
    comment: "Title shown when no media session is active"
  )

  static let nothingPlayingMessage = String(
    localized: "status.nothing_playing.message",
    defaultValue: "Play a song or video in any app to see it here.",
    comment: "Message shown when no media session is active"
  )

  static let readErrorTitle = String(
    localized: "status.read_error.title",
    defaultValue: "Couldn't read media",
    comment: "Title shown when reading the current media session fails"
  )

  static let readErrorGeneric = String(
    localized: "status.read_error.generic",
    defaultValue: "Couldn't read the current media session.",
    comment: "Generic message when reading the media session fails"
  )

  static let readErrorUnavailable = String(
    localized: "status.read_error.unavailable",
    defaultValue: "Media controls aren't available on this macOS version.",
    comment: "Message shown when the system media service is unavailable"
  )

  static let compactNothingPlaying = String(
    localized: "compact.nothing_playing",
    defaultValue: "Nothing playing",
    comment: "Compact island title when no media session is active"
  )

  static let compactPlayHint = String(
    localized: "compact.play_hint",
    defaultValue: "Play something",
    comment: "Compact island subtitle prompting the user to play media"
  )

  static let compactUnavailable = String(
    localized: "compact.unavailable",
    defaultValue: "Media unavailable",
    comment: "Compact island title when the media session can't be read"
  )

  static let compactErrorHint = String(
    localized: "compact.error_hint",
    defaultValue: "Click to view",
    comment: "Compact island subtitle prompting the user to expand an error"
  )

  static let compactConnecting = String(
    localized: "compact.connecting",
    defaultValue: "Connecting…",
    comment: "Compact island title while connecting to the media session"
  )

  static let compactAppName = String(
    localized: "compact.app_name",
    defaultValue: "MacIsland",
    comment: "App name shown in the compact island"
  )

  static let buttonTryAgain = String(
    localized: "button.try_again",
    defaultValue: "Try again",
    comment: "Button that retries reading the media session"
  )

  static let buttonPlay = String(
    localized: "button.play",
    defaultValue: "Play",
    comment: "Accessibility label for the play button"
  )

  static let buttonPause = String(
    localized: "button.pause",
    defaultValue: "Pause",
    comment: "Accessibility label for the pause button"
  )

  static let buttonCollapse = String(
    localized: "button.collapse",
    defaultValue: "Collapse island",
    comment: "Accessibility label for collapsing the expanded island"
  )

  static let menuHideIsland = String(
    localized: "menu.hide_island",
    defaultValue: "Hide island",
    comment: "Menu item that hides the floating island"
  )

  static let menuShowIsland = String(
    localized: "menu.show_island",
    defaultValue: "Show island",
    comment: "Menu item that shows the floating island"
  )

  static let menuOpenAtLogin = String(
    localized: "menu.open_at_login",
    defaultValue: "Open at Login",
    comment: "Menu item that toggles launch at login"
  )

  static let menuAbout = String(
    localized: "menu.about",
    defaultValue: "About MacIsland",
    comment: "Menu item that opens the About panel"
  )

  static let menuQuit = String(
    localized: "menu.quit",
    defaultValue: "Quit MacIsland",
    comment: "Menu item that quits the app"
  )

  static let featureMedia = String(
    localized: "feature.media",
    defaultValue: "Media",
    comment: "Feature picker label for media playback"
  )

  static let featureTimer = String(
    localized: "feature.timer",
    defaultValue: "Timer",
    comment: "Feature picker label for the focus timer"
  )

  static let timerReady = String(
    localized: "timer.ready",
    defaultValue: "Ready",
    comment: "Timer status before it starts"
  )

  static let timerPaused = String(
    localized: "timer.paused",
    defaultValue: "Paused",
    comment: "Timer status while paused"
  )

  static let timerFocus = String(
    localized: "timer.focus",
    defaultValue: "Focus",
    comment: "Timer status while running"
  )

  static let timerDone = String(
    localized: "timer.done",
    defaultValue: "Done",
    comment: "Timer status when the countdown reaches zero"
  )

  static let timerStart = String(
    localized: "timer.start",
    defaultValue: "Start",
    comment: "Accessibility label for starting the timer"
  )

  static let timerPause = String(
    localized: "timer.pause",
    defaultValue: "Pause",
    comment: "Accessibility label for pausing the timer"
  )

  static let timerReset = String(
    localized: "timer.reset",
    defaultValue: "Reset",
    comment: "Accessibility label for resetting the timer"
  )

  static let timerMinutesFormat = String(
    localized: "timer.minutes_format",
    defaultValue: "%d min",
    comment: "Short duration label for timer presets"
  )

  static let timerNotificationTitle = String(
    localized: "timer.notification.title",
    defaultValue: "Timer finished",
    comment: "Title of the local notification when a timer ends"
  )

  static let timerNotificationBodyFormat = String(
    localized: "timer.notification.body",
    defaultValue: "Your %d-minute timer is done.",
    comment: "Body of the local notification when a timer ends"
  )

  static let buttonPrevious = String(
    localized: "button.previous",
    defaultValue: "Previous",
    comment: "Accessibility label for the previous track button"
  )

  static let buttonNext = String(
    localized: "button.next",
    defaultValue: "Next",
    comment: "Accessibility label for the next track button"
  )

  static let aboutCredits = String(
    localized: "about.credits",
    defaultValue: "A dynamic island for your Mac.\nMedia, timers, and more to come. Not affiliated with Spotify or Apple.",
    comment: "Credits shown in the About panel"
  )

  static let loginItemErrorTitle = String(
    localized: "login_item.error.title",
    defaultValue: "Couldn't update Open at Login",
    comment: "Alert title when changing the login item fails"
  )

  static let loginItemErrorFormat = String(
    localized: "login_item.error.format",
    defaultValue: "macOS reported: %@",
    comment: "Alert body when changing the login item fails"
  )

  static let loginItemRequiresApproval = String(
    localized: "login_item.requires_approval",
    defaultValue: "Approve MacIsland in System Settings › General › Login Items.",
    comment: "Message when macOS requires approval for the login item"
  )
}
