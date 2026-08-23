//
//  CircularProgressViewStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - ProgressViewStyle + Circular

@available(OpenSwiftUI_v2_0, *)
extension ProgressViewStyle where Self == CircularProgressViewStyle {
    /// A progress view that uses a circular gauge to indicate the partial
    /// completion of an activity.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var circular: CircularProgressViewStyle {
        .init()
    }
}

// MARK: - CircularProgressViewStyle

/// A progress view that uses a circular gauge to indicate the partial
/// completion of an activity.
@available(OpenSwiftUI_v2_0, *)
public struct CircularProgressViewStyle: ProgressViewStyle {
    @Environment(\.tintColor)
    private var controlTint: Color?

    @Environment(\.labelsVisibility)
    private var labelsVisibility: Visibility

    private let tint: Color?

    @_spi(Private)
    @available(iOS, unavailable)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, deprecated: 8.0, message: "Use View.controlSize(_:) instead.")
    public enum Size: Hashable {
        case small
        case medium
        case large
    }

    /// Creates a circular progress view style.
    public init() {
        tint = nil
    }

    @_spi(Private)
    @available(iOS, unavailable)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, deprecated: 8.0, message: "Use View.controlSize(_:) instead.")
    public init(size _: Size) {
        tint = nil
    }

    /// Creates a circular progress view style with a custom tint color.
    @available(*, deprecated, message: "Use ``View/tint(_)`` instead.")
    public init(tint: Color) {
        self.tint = tint
    }

    public func makeBody(configuration: Configuration) -> some View {
        VStack {
            fractionCompletedView(configuration: configuration)
            StaticIf(idiom: .widget) {
                configuration.alwaysIndeterminate
                    ? labels(configuration: configuration)
                    : nil
            } else: {
                labels(configuration: configuration)
            }
        }
        .spacing(Spacing())
    }

    @ViewBuilder
    func fractionCompletedView(configuration: Configuration) -> some View {
        _openSwiftUIUnreachableCode()
//        StaticIf(idiom: .widget) {
//            ArchivableCircularProgressView(
//                size: 58,
//                centerFont: 30,
//                configuration: configuration,
//                tint: tint ?? controlTint
//            )
//        } else: {
//            StaticIf(idiom: MacInterfaceIdiom.mac) {
//                CircularUIKitProgressView(
//                    tint: tint ?? controlTint,
//                    useCustomWidth: false
//                )
//            } else: {
//                CircularUIKitProgressView(
//                    tint: tint ?? controlTint,
//                    useCustomWidth: true
//                )
//            }
//        }
    }

    @ViewBuilder
    func labels(configuration: Configuration) -> some View {
        if !isLinkedOnOrAfter(.v5) || labelsVisibility != .hidden {
            VStack {
                HStack {
                    configuration.label
                }
                HStack {
                    configuration.currentValueLabel
                }
                .font(.caption)
            }
            .defaultForegroundColor(.secondary)
        }
    }
}

@available(*, unavailable)
extension CircularProgressViewStyle: Sendable {}
