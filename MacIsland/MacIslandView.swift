//
//  MacIslandView.swift
//  MacIsland
//
//  Created by Eric Freitas Sampaio on 26/10/26.
//

import Foundation
import SwiftUI

struct MacIslandView: View {
  @ObservedObject var state: MacIslandState
  @ObservedObject var music: MusicService

  private var isExpanded: Bool { state.isExpanded }

  private var islandSize: CGSize {
    CGSize(
      width: isExpanded ? IslandLayout.expandedWidth : IslandLayout.compactWidth,
      height: state.topInset
        + (isExpanded
          ? IslandLayout.expandedContentHeight
          : IslandLayout.compactContentHeight)
    )
  }

  private var islandShape: IslandShape {
    IslandShape(
      topRadius: state.hasNotch ? 0 : (isExpanded ? 26 : 18),
      bottomRadius: isExpanded ? 26 : 18
    )
  }

  var body: some View {
    VStack(spacing: 0) {
      ZStack(alignment: .top) {
        islandShape
          .fill(backgroundGradient)

        content
          .padding(.top, state.topInset + (isExpanded ? 12 : 6))
          .padding(.horizontal, isExpanded ? 16 : 10)
          .padding(.bottom, isExpanded ? 12 : 6)

        if isExpanded {
          HStack(spacing: 0) {
            Spacer(minLength: 0)
            collapseButton
          }
          .padding(.top, state.topInset + 11)
          .padding(.trailing, 14)
          .transition(.opacity)
        }
      }
      .frame(width: islandSize.width, height: islandSize.height)
      .clipShape(islandShape)
      .contentShape(islandShape)
      .onTapGesture {
        if !isExpanded {
          state.expand()
        }
      }
      .animation(
        .spring(response: 0.36, dampingFraction: 0.86),
        value: isExpanded
      )
      .animation(
        .spring(response: 0.36, dampingFraction: 0.86),
        value: state.topInset
      )

      Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .ignoresSafeArea()
    .foregroundStyle(.white)
  }

  // MARK: - Conteúdo

  @ViewBuilder
  private var content: some View {
    if isExpanded {
      expandedContent
        .transition(
          .opacity.combined(
            with: .scale(scale: 0.97, anchor: .top)
          )
        )
    } else {
      compactContent
        .transition(.opacity)
    }
  }

  private var compactContent: some View {
    HStack(spacing: 8) {
      ArtworkView(
        url: music.track?.artworkURL,
        size: 24,
        cornerRadius: 7
      )

      VStack(alignment: .leading, spacing: 1) {
        Text(compactTitle)
          .font(.system(size: 10.5, weight: .semibold))
          .lineLimit(1)

        Text(compactSubtitle)
          .font(.system(size: 8, weight: .medium))
          .foregroundStyle(.white.opacity(0.45))
          .lineLimit(1)
      }

      Spacer(minLength: 0)

      EqualizerBars(isPlaying: music.track?.isPlaying ?? false)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .frame(height: 24)
  }

  @ViewBuilder
  private var expandedContent: some View {
    Group {
      switch music.status {
      case .ready:
        playerContent
      case .idle, .loading:
        statusMessage(
          icon: "arrow.triangle.2.circlepath",
          tint: .white.opacity(0.65),
          title: L10n.connectingTitle,
          message: L10n.connectingMessage,
          primaryTitle: nil,
          primaryAction: nil
        )
      case .spotifyNotRunning:
        statusMessage(
          icon: "music.note",
          tint: .green,
          title: L10n.spotifyClosedTitle,
          message: L10n.spotifyClosedMessage,
          primaryTitle: L10n.buttonOpenSpotify,
          primaryAction: { music.openSpotify() }
        )
      case .noTrack:
        statusMessage(
          icon: "pause.circle",
          tint: .white.opacity(0.65),
          title: L10n.nothingPlayingTitle,
          message: L10n.nothingPlayingMessage,
          primaryTitle: L10n.buttonOpenSpotify,
          primaryAction: { music.openSpotify() }
        )
      case .automationDenied:
        statusMessage(
          icon: "lock.fill",
          tint: .orange,
          title: L10n.permissionTitle,
          message: L10n.permissionMessage,
          primaryTitle: L10n.buttonOpenSettings,
          primaryAction: { music.openAutomationSettings() },
          secondaryTitle: L10n.buttonCheckAgain,
          secondaryAction: { music.retry() }
        )
      case .failed(let message):
        statusMessage(
          icon: "exclamationmark.triangle.fill",
          tint: .orange,
          title: L10n.readErrorTitle,
          message: message,
          primaryTitle: L10n.buttonTryAgain,
          primaryAction: { music.retry() }
        )
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
  }

  private var playerContent: some View {
    VStack(spacing: 0) {
      HStack(spacing: 10) {
        ArtworkView(
          url: music.track?.artworkURL,
          size: 52,
          cornerRadius: 10
        )

        VStack(alignment: .leading, spacing: 3) {
          Text(music.track?.title ?? "Spotify")
            .font(.system(size: 13, weight: .semibold))
            .lineLimit(1)

          Text(music.track?.artist ?? "")
            .font(.system(size: 10.5, weight: .medium))
            .foregroundStyle(.white.opacity(0.62))
            .lineLimit(1)

          if let album = music.track?.album, !album.isEmpty {
            Text(album)
              .font(.system(size: 9))
              .foregroundStyle(.white.opacity(0.38))
              .lineLimit(1)
          }
        }

        Spacer(minLength: 26)
      }
      .frame(height: 52)

      progressRow
        .padding(.top, 12)

      controlsRow
        .padding(.top, 12)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var progressRow: some View {
    VStack(spacing: 5) {
      GeometryReader { proxy in
        ZStack(alignment: .leading) {
          Capsule()
            .fill(.white.opacity(0.12))

          Capsule()
            .fill(.green)
            .frame(
              width: max(
                0,
                proxy.size.width * (music.track?.progress ?? 0)
              )
            )
        }
      }
      .frame(height: 3)

      HStack(spacing: 4) {
        Text(timeLabel(music.track?.position ?? 0))
        Spacer(minLength: 0)
        Text(timeLabel(music.track?.duration ?? 0))
      }
      .font(.system(size: 9, weight: .medium).monospacedDigit())
      .foregroundStyle(.white.opacity(0.38))
    }
  }

  private var controlsRow: some View {
    HStack(spacing: 0) {
      Spacer(minLength: 0)

      mediaButton("backward.fill", size: 15) {
        music.previous()
      }

      Spacer().frame(width: 26)

      Button {
        music.togglePlayback()
      } label: {
        Image(
          systemName: (music.track?.isPlaying ?? false)
            ? "pause.fill"
            : "play.fill"
        )
        .font(.system(size: 15, weight: .bold))
        .frame(width: 32, height: 32)
        .background(.white.opacity(0.14), in: Circle())
      }
      .buttonStyle(.plain)
      .disabled(!music.canControl)
      .accessibilityLabel(
        (music.track?.isPlaying ?? false)
          ? L10n.buttonPause
          : L10n.buttonPlay
      )

      Spacer().frame(width: 26)

      mediaButton("forward.fill", size: 15) {
        music.next()
      }

      Spacer(minLength: 0)
    }
    .frame(height: 38)
    .opacity(music.canControl ? 1 : 0.45)
  }

  private func statusMessage(
    icon: String,
    tint: Color,
    title: String,
    message: String,
    primaryTitle: String?,
    primaryAction: (() -> Void)?,
    secondaryTitle: String? = nil,
    secondaryAction: (() -> Void)? = nil
  ) -> some View {
    VStack(spacing: 7) {
      Image(systemName: icon)
        .font(.system(size: 19, weight: .semibold))
        .foregroundStyle(tint)

      Text(title)
        .font(.system(size: 12, weight: .semibold))

      Text(message)
        .font(.system(size: 9.5, weight: .regular))
        .foregroundStyle(.white.opacity(0.55))
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: 300)

      HStack(spacing: 8) {
        if let primaryTitle, let primaryAction {
          Button(action: primaryAction) {
            Text(primaryTitle)
              .font(.system(size: 10, weight: .semibold))
              .foregroundStyle(.black.opacity(0.85))
              .padding(.horizontal, 12)
              .frame(height: 24)
              .background(.green, in: Capsule())
          }
          .buttonStyle(.plain)
        }

        if let secondaryTitle, let secondaryAction {
          Button(action: secondaryAction) {
            Text(secondaryTitle)
              .font(.system(size: 10, weight: .semibold))
              .foregroundStyle(.white.opacity(0.8))
              .padding(.horizontal, 12)
              .frame(height: 24)
              .background(.white.opacity(0.1), in: Capsule())
          }
          .buttonStyle(.plain)
        }
      }
      .padding(.top, 2)
    }
    .frame(maxWidth: .infinity)
  }

  private var collapseButton: some View {
    Button {
      state.collapse()
    } label: {
      Image(systemName: "chevron.up")
        .font(.system(size: 9, weight: .bold))
        .foregroundStyle(.white.opacity(0.6))
        .frame(width: 22, height: 22)
        .background(.white.opacity(0.08), in: Circle())
    }
    .buttonStyle(.plain)
    .accessibilityLabel(L10n.buttonCollapse)
  }

  private func mediaButton(
    _ symbol: String,
    size: CGFloat,
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      Image(systemName: symbol)
        .font(.system(size: size, weight: .semibold))
        .frame(width: 30, height: 30)
        .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .disabled(!music.canControl)
  }

  // MARK: - Textos

  private var compactTitle: String {
    switch music.status {
    case .ready:
      return music.track?.title ?? "Spotify"
    case .automationDenied:
      return L10n.compactNoPermission
    case .spotifyNotRunning:
      return L10n.compactSpotifyClosed
    case .noTrack:
      return L10n.compactNothingPlaying
    case .failed:
      return L10n.compactUnavailable
    case .idle, .loading:
      return L10n.compactConnecting
    }
  }

  private var compactSubtitle: String {
    switch music.status {
    case .ready:
      return music.track?.artist ?? "Spotify"
    case .automationDenied:
      return L10n.compactPermissionHint
    case .spotifyNotRunning:
      return L10n.compactOpenHint
    case .noTrack:
      return "Spotify"
    case .failed:
      return L10n.compactErrorHint
    case .idle, .loading:
      return L10n.compactAppName
    }
  }

  private func timeLabel(_ seconds: TimeInterval) -> String {
    let total = max(0, Int(seconds.rounded()))
    if total >= 3600 {
      return String(
        format: "%d:%02d:%02d",
        total / 3600,
        (total % 3600) / 60,
        total % 60
      )
    }
    return String(format: "%d:%02d", total / 60, total % 60)
  }

  private var backgroundGradient: LinearGradient {
    LinearGradient(
      stops: [
        .init(color: .black, location: 0),
        .init(color: .black, location: 0.45),
        .init(color: Color(red: 0.045, green: 0.045, blue: 0.05), location: 1),
      ],
      startPoint: .top,
      endPoint: .bottom
    )
  }
}

// MARK: - Componentes

struct IslandShape: Shape {
  var topRadius: CGFloat
  var bottomRadius: CGFloat

  func path(in rect: CGRect) -> Path {
    UnevenRoundedRectangle(
      topLeadingRadius: topRadius,
      bottomLeadingRadius: bottomRadius,
      bottomTrailingRadius: bottomRadius,
      topTrailingRadius: topRadius,
      style: .continuous
    )
    .path(in: rect)
  }
}

private struct ArtworkView: View {
  let url: URL?
  let size: CGFloat
  let cornerRadius: CGFloat

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        .fill(.white.opacity(0.08))

      Image(systemName: "waveform")
        .font(.system(size: size * 0.36, weight: .semibold))
        .foregroundStyle(.green)

      if let url {
        AsyncImage(
          url: url,
          transaction: Transaction(animation: .easeInOut(duration: 0.18))
        ) { phase in
          if case .success(let image) = phase {
            image
              .resizable()
              .scaledToFill()
              .transition(.opacity)
          } else {
            Color.clear
          }
        }
      }
    }
    .frame(width: size, height: size)
    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
  }
}

private struct EqualizerBars: View {
  let isPlaying: Bool

  var body: some View {
    TimelineView(
      .animation(minimumInterval: 1 / 8, paused: !isPlaying)
    ) { timeline in
      let time = timeline.date.timeIntervalSinceReferenceDate

      HStack(alignment: .center, spacing: 2) {
        ForEach(0..<4, id: \.self) { index in
          Capsule()
            .fill(
              isPlaying
                ? Color.green
                : Color.white.opacity(0.3)
            )
            .frame(width: 2.5, height: barHeight(index, time))
        }
      }
      .frame(width: 16, height: 14)
    }
    .frame(width: 16, height: 14)
  }

  private func barHeight(_ index: Int, _ time: TimeInterval) -> CGFloat {
    guard isPlaying else { return 3 }
    let phase = time * 4.2 + Double(index) * 1.15
    let wave = (sin(phase) * 0.5 + 0.5)
    return 3 + CGFloat(wave) * 9
  }
}
