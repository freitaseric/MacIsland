import Foundation

nonisolated enum L10n {

  static let connectingTitle = String(
    localized: "status.connecting.title",
    defaultValue: "Connecting to Spotify",
    comment: "Expanded island title while waiting for Spotify data"
  )

  static let connectingMessage = String(
    localized: "status.connecting.message",
    defaultValue: "Waiting for permission and the current track…",
    comment: "Expanded island message while waiting for Spotify"
  )

  static let spotifyClosedTitle = String(
    localized: "status.spotify_closed.title",
    defaultValue: "Spotify isn't open",
    comment: "Title shown when Spotify is not running"
  )

  static let spotifyClosedMessage = String(
    localized: "status.spotify_closed.message",
    defaultValue: "Open Spotify to control your music from here.",
    comment: "Message shown when Spotify is not running"
  )

  static let nothingPlayingTitle = String(
    localized: "status.nothing_playing.title",
    defaultValue: "Nothing playing",
    comment: "Title shown when Spotify is open but no track is playing"
  )

  static let nothingPlayingMessage = String(
    localized: "status.nothing_playing.message",
    defaultValue: "Play a song in Spotify to see the details.",
    comment: "Message shown when Spotify is open but nothing is playing"
  )

  static let permissionTitle = String(
    localized: "status.permission.title",
    defaultValue: "Permission needed",
    comment: "Title shown when Automation permission is denied"
  )

  static let permissionMessage = String(
    localized: "status.permission.message",
    defaultValue: "Allow MacIsland in System Settings › Privacy & Security › Automation.",
    comment: "Instructions to grant Automation permission"
  )

  static let readErrorTitle = String(
    localized: "status.read_error.title",
    defaultValue: "Couldn't read Spotify",
    comment: "Title shown when reading Spotify fails"
  )

  static let readErrorTimeout = String(
    localized: "status.read_error.timeout",
    defaultValue: "Spotify took too long to respond. Try again.",
    comment: "Message shown when Spotify times out"
  )

  static let readErrorMalformed = String(
    localized: "status.read_error.malformed",
    defaultValue: "Spotify returned an unexpected response.",
    comment: "Message shown when Spotify returns malformed data"
  )

  static let readErrorGeneric = String(
    localized: "status.read_error.generic",
    defaultValue: "Couldn't talk to Spotify.",
    comment: "Generic message when Spotify communication fails"
  )

  static let compactNoPermission = String(
    localized: "compact.no_permission",
    defaultValue: "No permission",
    comment: "Compact island title when Automation permission is denied"
  )

  static let compactPermissionHint = String(
    localized: "compact.permission_hint",
    defaultValue: "Click to authorize",
    comment: "Compact island subtitle prompting the user to grant permission"
  )

  static let compactSpotifyClosed = String(
    localized: "compact.spotify_closed",
    defaultValue: "Spotify closed",
    comment: "Compact island title when Spotify is not running"
  )

  static let compactOpenHint = String(
    localized: "compact.open_hint",
    defaultValue: "Click to open",
    comment: "Compact island subtitle prompting the user to open Spotify"
  )

  static let compactNothingPlaying = String(
    localized: "compact.nothing_playing",
    defaultValue: "Nothing playing",
    comment: "Compact island title when no track is playing"
  )

  static let compactUnavailable = String(
    localized: "compact.unavailable",
    defaultValue: "Spotify unavailable",
    comment: "Compact island title when Spotify can't be read"
  )

  static let compactErrorHint = String(
    localized: "compact.error_hint",
    defaultValue: "Click to view",
    comment: "Compact island subtitle prompting the user to expand an error"
  )

  static let compactConnecting = String(
    localized: "compact.connecting",
    defaultValue: "Connecting…",
    comment: "Compact island title while connecting to Spotify"
  )

  static let compactAppName = String(
    localized: "compact.app_name",
    defaultValue: "MacIsland",
    comment: "App name shown in the compact island"
  )

  static let buttonOpenSpotify = String(
    localized: "button.open_spotify",
    defaultValue: "Open Spotify",
    comment: "Button that launches Spotify"
  )

  static let buttonOpenSettings = String(
    localized: "button.open_settings",
    defaultValue: "Open Settings",
    comment: "Button that opens Automation settings"
  )

  static let buttonCheckAgain = String(
    localized: "button.check_again",
    defaultValue: "Check again",
    comment: "Button that retries reading Spotify"
  )

  static let buttonTryAgain = String(
    localized: "button.try_again",
    defaultValue: "Try again",
    comment: "Button that retries after an error"
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

  static let menuExpandIsland = String(
    localized: "menu.expand_island",
    defaultValue: "Expand island",
    comment: "Menu item that expands the island"
  )

  static let menuCollapseIsland = String(
    localized: "menu.collapse_island",
    defaultValue: "Collapse island",
    comment: "Menu item that collapses the island"
  )

  static let menuShowIsland = String(
    localized: "menu.show_island",
    defaultValue: "Show island",
    comment: "Menu item that shows the floating island"
  )

  static let menuOpenSpotify = String(
    localized: "menu.open_spotify",
    defaultValue: "Open Spotify",
    comment: "Menu item that launches Spotify"
  )

  static let menuRefresh = String(
    localized: "menu.refresh",
    defaultValue: "Check again",
    comment: "Menu item that refreshes Spotify data"
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

  static let menuAppName = String(
    localized: "menu.app_name",
    defaultValue: "MacIsland",
    comment: "App name shown as the menu title"
  )

  static let featureSpotify = String(
    localized: "feature.spotify",
    defaultValue: "Spotify",
    comment: "Feature picker label for Spotify"
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

  static let menuShowTimer = String(
    localized: "menu.show_timer",
    defaultValue: "Show Timer",
    comment: "Menu item that switches the island to the timer feature"
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
    defaultValue: "A dynamic island for your Mac.\nMusic, timers, and more to come. Not affiliated with Spotify or Apple.",
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

  static let errorAppleScriptCodeFormat = String(
    localized: "error.applescript_code.format",
    defaultValue: "AppleScript returned error %d.",
    comment: "Fallback error message including an AppleScript error code"
  )

  static let errorNoResponse = String(
    localized: "error.no_response",
    defaultValue: "Spotify didn't return a response.",
    comment: "Fallback error when Spotify returns no response"
  )
}
