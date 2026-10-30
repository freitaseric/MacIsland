import SwiftUI

struct TimerCompactView: View {
  @ObservedObject var timer: TimerService

  var body: some View {
    HStack(spacing: 8) {
      Image(systemName: "timer")
        .font(.system(size: 13, weight: .semibold))
        .foregroundStyle(.orange)
        .frame(width: 20, height: 20)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 6))

      VStack(alignment: .leading, spacing: 0) {
        Text(IslandTime.label(timer.remaining))
          .font(.system(size: 10.5, weight: .semibold).monospacedDigit())

        Text(statusText)
          .font(.system(size: 8, weight: .medium))
          .foregroundStyle(.white.opacity(0.45))
      }

      Spacer(minLength: 0)

      TimerProgressBar(progress: timer.elapsedFraction, tint: .orange)
        .frame(width: 32, height: 3)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .frame(height: 24)
  }

  private var statusText: String {
    if timer.isFinished { return L10n.timerDone }
    if timer.isRunning { return L10n.timerFocus }
    if timer.remaining < timer.duration { return L10n.timerPaused }
    return L10n.timerReady
  }
}

struct TimerExpandedView: View {
  @ObservedObject var timer: TimerService

  var body: some View {
    VStack(spacing: 6) {
      HStack(alignment: .firstTextBaseline, spacing: 8) {
        Image(systemName: "timer")
          .font(.system(size: 15, weight: .semibold))
          .foregroundStyle(.orange)

        Text(IslandTime.label(timer.remaining))
          .font(.system(size: 30, weight: .semibold).monospacedDigit())

        Spacer(minLength: 0)

        Text(statusText)
          .font(.system(size: 9, weight: .medium))
          .foregroundStyle(.white.opacity(0.4))
      }
      .frame(height: 38)

      TimerProgressBar(progress: timer.elapsedFraction, tint: .orange)
        .frame(height: 4)

      HStack(spacing: 6) {
        ForEach(TimerService.presets) { preset in
          let selected = abs(timer.duration - preset.seconds) < 0.5

          Button {
            timer.select(preset)
          } label: {
            Text(String(format: L10n.timerMinutesFormat, preset.minutes))
              .font(.system(size: 9, weight: .semibold))
              .foregroundStyle(
                selected ? .black.opacity(0.85) : .white.opacity(0.55)
              )
              .padding(.horizontal, 10)
              .frame(height: 22)
              .background(
                selected ? .orange : .white.opacity(0.07),
                in: Capsule()
              )
          }
          .buttonStyle(.plain)
          .disabled(timer.isRunning)
          .opacity(timer.isRunning && !selected ? 0.5 : 1)
          .accessibilityLabel(
            String(format: L10n.timerMinutesFormat, preset.minutes)
          )
        }

        Spacer(minLength: 0)
      }

      ZStack {
        HStack(spacing: 0) {
          Button {
            timer.reset()
          } label: {
            Image(systemName: "arrow.counterclockwise")
              .font(.system(size: 13, weight: .semibold))
              .frame(width: 30, height: 30)
          }
          .buttonStyle(.plain)
          .disabled(isResetDisabled)
          .opacity(isResetDisabled ? 0.35 : 1)
          .accessibilityLabel(L10n.timerReset)

          Spacer(minLength: 0)

          Text(String(format: L10n.timerMinutesFormat, timer.selectedMinutes))
            .font(.system(size: 10, weight: .medium).monospacedDigit())
            .foregroundStyle(.white.opacity(0.35))
        }

        Button {
          timer.toggle()
        } label: {
          Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(.black.opacity(0.85))
            .frame(width: 34, height: 34)
            .background(.orange, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
          timer.isRunning ? L10n.timerPause : L10n.timerStart
        )
      }
      .frame(height: 34)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
  }

  private var statusText: String {
    if timer.isFinished { return L10n.timerDone }
    if timer.isRunning { return L10n.timerFocus }
    if timer.remaining < timer.duration { return L10n.timerPaused }
    return L10n.timerReady
  }

  private var isResetDisabled: Bool {
    !timer.isRunning
      && !timer.isFinished
      && abs(timer.remaining - timer.duration) < 0.5
  }
}

struct TimerProgressBar: View {
  let progress: Double
  let tint: Color

  var body: some View {
    GeometryReader { proxy in
      ZStack(alignment: .leading) {
        Capsule()
          .fill(.white.opacity(0.12))

        Capsule()
          .fill(tint)
          .frame(
            width: proxy.size.width * min(max(progress, 0), 1)
          )
      }
    }
  }
}
