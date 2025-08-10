//
//  PlatformViewHost.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: BAC0C59DB8B5BCCA55C0A700794CB41E (SwiftUI)

#if canImport(Darwin)
import OpenSwiftUICore
import Foundation
import OpenSwiftUI_SPI

#if canImport(AppKit)
import AppKit
typealias PlatformEdgeInsets = NSEdgeInsets
typealias PlatformConstraintBasedLayoutHostingView = _NSConstraintBasedLayoutHostingView
#elseif canImport(UIKit)
import UIKit
typealias PlatformEdgeInsets = UIEdgeInsets
typealias PlatformConstraintBasedLayoutHostingView = _UIConstraintBasedLayoutHostingView
#endif

// MARK: - PlatformViewHost [WIP]

final class PlatformViewHost<Content>: PlatformConstraintBasedLayoutHostingView, AnyPlatformViewProviderHost where Content: PlatformViewRepresentable {
    var importer: EmptyPreferenceImporter

    var environment: EnvironmentValues

    var viewPhase: _GraphInputs.Phase

    let representedViewProvider: Content.PlatformViewProvider

    weak var host: ViewRendererHost?

    enum ViewControllerParentingMode {
        case willMoveToSuperview
        case didMoveToWindow
    }

    var viewHierarchyMode: ViewControllerParentingMode?

    var focusedValues: FocusedValues = .init()

    weak var responder: PlatformViewResponder?

    #if os(iOS)
    let safeAreaHelper: UIView.SafeAreaHelper = .init()
    #endif

    var _safeAreaInsets: PlatformEdgeInsets = .zero

    var inLayoutSizeThatFits: Bool = false

    var cachedImplementsFittingSize: Bool?

    var layoutInvalidator: PlatformViewLayoutInvalidator?

    var invalidationPending: Bool = false

    var cachedLayoutTraits: _LayoutTraits?

    init(
        importer: EmptyPreferenceImporter,
        environment: EnvironmentValues,
        viewPhase: _GraphInputs.Phase,
        representedViewProvider: Content.PlatformViewProvider
    ) {
        self.importer = importer
        self.environment = environment
        self.viewPhase = .invalid
        self.representedViewProvider = representedViewProvider
        self.focusedValues = .init()
        super.init(frame: .zero)
        // TODO
        addSubview(Content.platformView(for: representedViewProvider))
        _openSwiftUIUnimplementedWarning()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func intrinsicLayoutTraits() -> _LayoutTraits {
        func dimension(value: CGFloat, axis: NSLayoutConstraint.Axis) -> _LayoutTraits.Dimension {
            if value == UIView.noIntrinsicMetric {
                return .init(min: .zero, ideal: .zero, max: .infinity)
            } else {
                let idealValue = max(value, .zero)
                let compression = contentCompressionResistancePriority(for: axis)
                let hugging = contentHuggingPriority(for: axis)
                let minValue = compression >= .defaultHigh ? idealValue : .zero
                let maxValue = hugging >= .defaultHigh ? idealValue : .infinity
                return .init(min: minValue, ideal: idealValue, max: maxValue)
            }
        }
        let width = dimension(value: intrinsicContentSize.width, axis: .horizontal)
        let height = dimension(value: intrinsicContentSize.height, axis: .vertical)
        return .init(width: width, height: height)
    }

    func layoutTraits() -> _LayoutTraits {
        guard let cachedLayoutTraits else {
            let traits = intrinsicLayoutTraits()
            cachedLayoutTraits = traits
            return traits
        }
        return cachedLayoutTraits
    }

    override var hostedView: UIView? {
        get { super.hostedView }
        set { super.hostedView = newValue }
    }

    override func didAddSubview(_ subview: PlatformView) {
        super.didAddSubview(subview)
        guard let viewController = representedViewProvider as? PlatformViewController else {
            return
        }
        let view = viewController.view
        if hostedView == nil, view != nil {
            hostedView = view
        }
    }

    override func _setHostsLayoutEngine(_ hostsLayoutEngine: Bool) {
        guard enableUnifiedLayout() else {
            return
        }
        super._setHostsLayoutEngine(hostsLayoutEngine)
    }

    func updateSafeAreaInsets(_ insets: PlatformEdgeInsets?) {
        safeAreaHelper.updateSafeAreaInsets(insets, delegate: self)
    }

    private func layoutHostedView() {
        let enableUnifiedLayout =  enableUnifiedLayout()
        guard let hostedView else {
            return
        }
        let wantsConstraintBasedLayout = hostedView._wantsConstraintBasedLayout()
        guard !enableUnifiedLayout || !wantsConstraintBasedLayout else {
            return
        }
        guard bounds.width != .zero, bounds.height != .zero else {
            return
        }
        hostedView.frame = hostedView.frame(forAlignmentRect: bounds)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutHostedView()
    }

    override func contentCompressionResistancePriority(for axis: NSLayoutConstraint.Axis) -> UILayoutPriority {
        if Content.isViewController {
            return super.contentCompressionResistancePriority(for: axis)
        } else {
            let platformView = Content.platformView(for: representedViewProvider)
            return platformView.contentCompressionResistancePriority(for: axis)
        }
    }

    override func contentHuggingPriority(for axis: NSLayoutConstraint.Axis) -> UILayoutPriority {
        if Content.isViewController {
            return super.contentHuggingPriority(for: axis)
        } else {
            let platformView = Content.platformView(for: representedViewProvider)
            return platformView.contentHuggingPriority(for: axis)
        }
    }
}

extension PlatformViewHost: SafeAreaHelperDelegate {
    var defaultSafeAreaInsets: PlatformEdgeInsets {
        super.safeAreaInsets
    }
    
    var containerView: PlatformView {
        self
    }
    
    var shouldEagerlyUpdatesSafeArea: Bool {
        Content.shouldEagerlyUpdateSafeArea(representedViewProvider)
    }
}

func enableUnifiedLayout() -> Bool {
    isLinkedOnOrAfter(.maximal) || EnableUnifiedLayoutFeature.isEnabled
}

// MARK: - EnableUnifiedLayoutFeature

private struct EnableUnifiedLayoutFeature: UserDefaultKeyedFeature {
    static var key: String {
        "org.OpenSwiftUIProject.OpenSwiftUI.EnableUnifiedLayout"
    }

    static var cachedValue: Bool?
}
#endif
