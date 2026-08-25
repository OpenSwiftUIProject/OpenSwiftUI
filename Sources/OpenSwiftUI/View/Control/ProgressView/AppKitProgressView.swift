//
//  AppKitProgressView.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if os(macOS)
import AppKit
import COpenSwiftUI
import OpenSwiftUICore

// MARK: - AppKitProgressView

struct AppKitProgressView: NSViewRepresentable {
    var fractionCompleted: Double?
    var style: NSProgressIndicator.Style
    var tint: Color?

    @Environment(\.controlSize)
    private var controlSize

    @Environment(\.effectiveFont)
    private var font

    func makeNSView(context _: Context) -> NSProgressIndicator {
        let nsView = NSProgressIndicator()
        nsView.minValue = 0
        nsView.maxValue = 1
        return nsView
    }

    func updateNSView(_ nsView: NSProgressIndicator, context: Context) {
        nsView.style = style
        if fractionCompleted == nil {
            nsView.startAnimation(nil)
        } else {
            nsView.stopAnimation(nil)
        }
        nsView.isIndeterminate = fractionCompleted == nil
        nsView.doubleValue = fractionCompleted ?? 0

        let controlSize = NSControl.ControlSize(controlSize)
        if nsView.controlSize != controlSize {
            nsView.controlSize = controlSize
        }

        nsView.font = font.platformFont(in: context.environment)
        if let superview = nsView.superview {
            let appearance = superview.effectiveAppearance
            nsView.appearance = if let tint, tint != Color.accentColor {
                appearance.applyingTintColor(.init(tint))
            } else {
                nil
            }
        }
    }
}

// MARK: - LinearAppKitProgressView

struct LinearAppKitProgressView: View {
    var configuration: ProgressViewStyleConfiguration
    var tint: Color?

    var body: some View {
        switch configuration.value {
        case let .absolute(fractionCompleted, _):
            Base(
                fractionCompleted: fractionCompleted,
                tint: tint
            )
        case let .dateRelative(interval, countdown):
            TimelineProgressView<Base>(
                interval: interval,
                updateStyle: .default,
                countdown: countdown,
                tint: tint,
                isCircular: false,
                extendedState: .init()
            )
        }
    }

    struct Base: TimelineProgressViewBase {
        var fractionCompleted: Double?
        var tint: Color?

        init(fractionCompleted: Double?, tint: Color?) {
            self.fractionCompleted = fractionCompleted
            self.tint = tint
        }

        init(fractionCompleted: Double, tint: Color?) {
            self.fractionCompleted = fractionCompleted
            self.tint = tint
        }

        var body: some View {
            AppKitProgressView(
                fractionCompleted: fractionCompleted,
                style: .bar,
                tint: tint
            )
        }
    }
}
#endif
