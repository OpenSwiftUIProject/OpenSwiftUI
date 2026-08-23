//
//  LinearProgressViewStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 6399EAC5515CA9566698FD9D51220283 (SwiftUI)

public import OpenSwiftUICore

// MARK: - ProgressViewStyle + Linear

@available(OpenSwiftUI_v2_0, *)
extension ProgressViewStyle where Self == LinearProgressViewStyle {
    /// A progress view that visually indicates its progress using a horizontal
    /// bar.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var linear: LinearProgressViewStyle {
        .init()
    }
}

// MARK: - LinearProgressViewStyle

/// A progress view that visually indicates its progress using a horizontal
/// bar.
@available(OpenSwiftUI_v2_0, *)
public struct LinearProgressViewStyle: ProgressViewStyle {
    @Environment(\.tintColor)
    private var controlTint: Color?

    @Environment(\.labelsVisibility)
    private var labelsVisibility: Visibility

    private let tint: Color?

    /// Creates a linear progress view style.
    public init() {
        tint = nil
    }

    /// Creates a linear progress view style with a custom tint color.
    @available(*, deprecated, message: "Use ``View/tint(_)`` instead.")
    public init(tint: Color) {
        self.tint = tint
    }

    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if !isLinkedOnOrAfter(.v5) || labelsVisibility != .hidden {
                configuration.label
            }
            progressBar(configuration: configuration)
            if !isLinkedOnOrAfter(.v5) || labelsVisibility != .hidden {
                configuration.currentValueLabel
                    .defaultForegroundColor(.secondary)
                    .font(.caption)
                    .monospacedDigit()
            }
        }
    }

    private func progressBar(configuration: Configuration) -> some View {
        _openSwiftUIUnimplementedFailure()
//        StaticIf(idiom: .widget) {
//            ArchivableLinearProgressView(
//                configuration: configuration,
//                tint: tint ?? controlTint
//            )
//        } else: {
//            LinearUIKitProgressView(
//                configuration: configuration,
//                tint: tint ?? controlTint
//            )
//        }
    }
}

@available(*, unavailable)
extension LinearProgressViewStyle: Sendable {}
