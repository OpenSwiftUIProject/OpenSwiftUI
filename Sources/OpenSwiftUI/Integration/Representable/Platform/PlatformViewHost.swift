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

#if os(iOS)
import UIKit
typealias PlatformConstraintBasedLayoutHostingView = _UIConstraintBasedLayoutHostingView
#elseif os(macOS)
import AppKit
typealias PlatformConstraintBasedLayoutHostingView = _NSConstraintBasedLayoutHostingView
#endif

// MARK: - PlatformViewHost [WIP]

final class PlatformViewHost<Content>:
    PlatformConstraintBasedLayoutHostingView,
    AnyPlatformViewHost,
    AnyPlatformViewProviderHost
where Content: PlatformViewRepresentable {
    var importer: EmptyPreferenceImporter

    var environment: EnvironmentValues

    var viewPhase: _GraphInputs.Phase

    let representedViewProvider: Content.PlatformViewProvider

    weak var host: ViewRendererHost? = nil

    enum ViewControllerParentingMode {
        case willMoveToSuperview
        case didMoveToWindow
    }

    var viewHierarchyMode: ViewControllerParentingMode?

    var focusedValues: FocusedValues

    weak var responder: PlatformViewResponder?

    let safeAreaHelper: PlatformView.SafeAreaHelper = .init()

    #if os(iOS)
    var _safeAreaInsets: PlatformEdgeInsets = .init(
        top: .greatestFiniteMagnitude,
        left: .greatestFiniteMagnitude,
        bottom: .greatestFiniteMagnitude,
        right: .greatestFiniteMagnitude
    )
    #endif

    #if os(macOS)
    var recursiveIgnoreHitTest: Bool = false

    var customAcceptsFirstMouse: Bool?
    #endif

    var inLayoutSizeThatFits: Bool = false

    var cachedImplementsFittingSize: Bool?

    var layoutInvalidator: PlatformViewLayoutInvalidator?

    var invalidationPending: Bool = false

    var cachedLayoutTraits: _LayoutTraits?

    // FIXME: macOS
    init(
        _ provider: Content.PlatformViewProvider,
        host: ViewRendererHost?,
        environment: EnvironmentValues,
        viewPhase: _GraphInputs.Phase,
        importer: EmptyPreferenceImporter
    ) {
        self.environment = environment
        self.viewPhase = viewPhase
        self.representedViewProvider = provider
        self.host = host
        self.focusedValues = .init()
        self.importer = importer
        super.init(hostedView: nil)
        if Content.isViewController {
            viewHierarchyMode = isLinkedOnOrAfter(.v6) ? .willMoveToSuperview : .didMoveToWindow
        }
        #if os(iOS)
        if isLinkedOnOrAfter(.v6) {
            layer.allowsGroupOpacity = false
            layer.allowsGroupBlending = false
        }
        #endif
        if !Content.isViewController {
            hostedView = Content.platformView(for: representedViewProvider)
        }
        updateEnvironment(environment, viewPhase: viewPhase)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func intrinsicLayoutTraits() -> _LayoutTraits {
        #if os(iOS)
        func dimension(value: CGFloat, axis: NSLayoutConstraint.Axis) -> _LayoutTraits.Dimension {
            if value == PlatformView.noIntrinsicMetric {
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
        #elseif os(macOS)
        let selector = Selector(("measureMin:max:ideal:stretchingPriority:"))
        // TODO
        return .init()
        #endif
    }

    func layoutTraits() -> _LayoutTraits {
        guard let cachedLayoutTraits else {
            let traits = intrinsicLayoutTraits()
            cachedLayoutTraits = traits
            return traits
        }
        return cachedLayoutTraits
    }

    func updateEnvironment(_ environment: EnvironmentValues, viewPhase: _GraphInputs.Phase) {
        _openSwiftUIUnimplementedWarning()
    }

    func updateSafeAreaInsets(_ insets: PlatformEdgeInsets?) {
        safeAreaHelper.updateSafeAreaInsets(insets, delegate: self)
    }

    override var hostedView: PlatformView? {
        get { super.hostedView }
        set { super.hostedView = newValue }
    }

    #if os(iOS)
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

    override func didMoveToWindow() {
        defer { super.didMoveToWindow() }
        guard window != nil else { return }
        guard let viewController = representedViewProvider as? PlatformViewController else {
            return
        }
        let view = viewController.view
        guard let host, let controllerProvider = host.as(UIViewControllerProvider.self) else {
            return
        }
        let parentController = if isLinkedOnOrAfter(.v6_4) {
            controllerProvider.containingViewController
        } else {
            controllerProvider.uiViewController
        }
        guard let parentController, let viewHierarchyMode else { return }
        switch viewHierarchyMode {
        case .willMoveToSuperview:
            if viewController.parent !== parentController {
                parentController.addChild(viewController)
            }
            let notCurrentContext = viewController.presentedViewController?.modalPresentationStyle != .currentContext
            let isBeingDismissed = viewController.presentedViewController?.isBeingDismissed ?? false
            guard hostedView == nil, notCurrentContext || isBeingDismissed else {
                return
            }
        case .didMoveToWindow:
            parentController.addChild(viewController)
        }
        hostedView = view
        viewController.didMove(toParent: parentController)
    }

    override func _setHostsLayoutEngine(_ hostsLayoutEngine: Bool) {
        guard enableUnifiedLayout() else {
            return
        }
        super._setHostsLayoutEngine(hostsLayoutEngine)
    }
    #else
    override func viewWillMove(toSuperview newSuperview: NSView?) {
        defer { super.viewWillMove(toSuperview: newSuperview) }
        guard let newSuperview else {
            return
        }
        guard let viewController = representedViewProvider as? PlatformViewController else {
            return
        }
        let view = viewController.view
        guard view.superview != newSuperview else {
            return
        }
        hostedView = view
        needsUpdateConstraints = true
    }

    override func viewDidMoveToSuperview() {
        defer { super.viewDidMoveToSuperview() }
        // TODO
        // updateConstraintsForSubtreeIfNeeded()
    }
    #endif

    #if os(iOS)
    private func layoutHostedView() {
        let enableUnifiedLayout =  enableUnifiedLayout()
        guard let hostedView else {
            return
        }
        let wantsConstraintBasedLayout = hostedView._wantsConstraintBasedLayout
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
    #elseif os(macOS)
    func updateHostedViewBounds() {
        let platformView = Content.platformView(for: representedViewProvider)
        platformView.frame = platformView.frame(forAlignmentRect: bounds)
    }

    override func layout() {
        updateHostedViewBounds()
    }
    #endif

    #if os(iOS)
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
    #elseif os(macOS)

    override func contentCompressionResistancePriority(for orientation: NSLayoutConstraint.Orientation) -> NSLayoutConstraint.Priority {
        if Content.isViewController {
            return super.contentCompressionResistancePriority(for: orientation)
        } else {
            let platformView = Content.platformView(for: representedViewProvider)
            return platformView.contentCompressionResistancePriority(for: orientation)
        }
    }

    override func contentHuggingPriority(for orientation: NSLayoutConstraint.Orientation) -> NSLayoutConstraint.Priority {
        if Content.isViewController {
            return super.contentHuggingPriority(for: orientation)
        } else {
            let platformView = Content.platformView(for: representedViewProvider)
            return platformView.contentHuggingPriority(for: orientation)
        }
    }
    #endif

    #if os(macOS)
    override var computedSafeAreaInsets: PlatformEdgeInsets {
        safeAreaHelper.resolvedSafeAreaInsets(delegate: self)
    }
    #endif
}

extension PlatformViewHost: SafeAreaHelperDelegate {
    #if os(macOS)
    var _safeAreaInsets: PlatformEdgeInsets {
        get {
            _openSwiftUIUnimplementedWarning()
            return .zero
        }
        set {
            _openSwiftUIUnimplementedWarning()
        }
    }
    #endif

    var defaultSafeAreaInsets: PlatformEdgeInsets {
        #if os(iOS)
        super.safeAreaInsets
        #elseif os(macOS)
        super.computedSafeAreaInsets
        #endif
    }
    
    var containerView: PlatformView {
        self
    }
    
    var shouldEagerlyUpdatesSafeArea: Bool {
        Content.shouldEagerlyUpdateSafeArea(representedViewProvider)
    }
}
#endif

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
