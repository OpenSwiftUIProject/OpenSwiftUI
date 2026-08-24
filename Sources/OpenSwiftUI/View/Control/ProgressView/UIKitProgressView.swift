//
//  UIKitProgressView.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 593A28E6B13910E9C78D52974AE7D9AF (SwiftUI)

#if os(iOS) || os(visionOS)
import COpenSwiftUI
import OpenSwiftUICore
import UIKit

// MARK: - LinearUIKitProgressView

struct LinearUIKitProgressView: View {
    var configuration: ProgressViewStyleConfiguration
    var tint: Color?

    var body: some View {
        switch configuration.value {
        case let .absolute(fractionCompleted, _):
            Base(
                fractionCompleted: fractionCompleted ?? 0,
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

    struct Base: UIViewRepresentable, TimelineProgressViewBase {
        var fractionCompleted: Double
        var tint: Color?

        func makeUIView(context _: Context) -> UIProgressView {
            OpenSwiftUIProgressView(progressViewStyle: .default)
        }

        func updateUIView(_ uiView: UIProgressView, context: Context) {
            uiView.setProgress(
                Float(fractionCompleted),
                animated: context.transaction.animation != nil
            )
            let newTintColor = tint.map {
                $0.resolve(in: context.environment).kitColor as! UIColor
            }
            if newTintColor != uiView.progressTintColor {
                uiView.progressTintColor = newTintColor
            }
        }

        private class OpenSwiftUIProgressView: UIProgressView {}
    }
}

// MARK: - CircularUIKitProgressView

struct CircularUIKitProgressView: UIViewRepresentable {
    @Environment(\.controlSize) private var controlSize
    @ScaledMetric private var regular: CGFloat = 20.0
    @ScaledMetric private var small: CGFloat = 14.0
    @ScaledMetric private var large: CGFloat = 37.0
    var tint: Color?
    var useCustomWidth: Bool

    init(tint: Color?, useCustomWidth: Bool) {
        self.tint = tint
        self.useCustomWidth = useCustomWidth
    }

    func makeUIView(context _: Context) -> UIActivityIndicatorView {
        let uiView = OpenSwiftUIActivityIndicatorView()
        uiView.style = if useCustomWidth {
            .init(rawValue: 16)!
        } else {
            switch controlSize {
            case .mini, .small:
                .init(rawValue: 3)!
            case .regular:
                .medium
            case .large, .extraLarge:
                .large
            }
        }
        uiView.startAnimating()
        return uiView
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        if useCustomWidth {
            uiView._setCustomWidth(resolvedWidth)
        }
        let tintColor = tint ?? (useCustomWidth ? .secondary : nil)
        let newColor = tintColor.map {
            $0.resolve(in: context.environment).kitColor as! UIColor
        }
        if newColor != uiView.color {
            uiView.color = newColor
        }
    }

    private var resolvedWidth: CGFloat {
        switch controlSize {
        case .mini, .small:
            small
        case .regular:
            regular
        case .large, .extraLarge:
            large
        }
    }

    private class OpenSwiftUIActivityIndicatorView: UIActivityIndicatorView {}
}

#endif
