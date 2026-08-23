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

// MARK: - LinearUIKitProgressView [TODO]

// MARK: - CircularUIKitProgressView

struct CircularUIKitProgressView: UIViewRepresentable {
    @Environment(\.controlSize) private var controlSize
    @ScaledMetric private var regular: CGFloat = 20
    @ScaledMetric private var small: CGFloat = 14
    @ScaledMetric private var large: CGFloat = 37
    var tint: Color?
    var useCustomWidth: Bool

    init(tint: Color?, useCustomWidth: Bool) {
        self.tint = tint
        self.useCustomWidth = useCustomWidth
    }

    func makeUIView(context _: Context) -> UIActivityIndicatorView {
        let uiView = SwiftUIActivityIndicatorView()
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

    private class SwiftUIActivityIndicatorView: UIActivityIndicatorView {}
}

#endif
