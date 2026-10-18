//
//  PlatformViewHost.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: BAC0C59DB8B5BCCA55C0A700794CB41E (SwiftUI)

#if canImport(Darwin)
import Foundation
import COpenSwiftUI
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

#if os(iOS) || os(visionOS)
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

    var focusedValues: FocusedValues {
        didSet {
            updateNestedHosts(.focusedValues, colorSchemeChanged: false)
        }
    }

    weak var responder: PlatformViewResponder?

    let safeAreaHelper: PlatformView.SafeAreaHelper = .init()

    #if os(iOS) || os(visionOS)
    var _safeAreaInsets: PlatformEdgeInsets = .init(
        top: .greatestFiniteMagnitude,
        left: .greatestFiniteMagnitude,
        bottom: .greatestFiniteMagnitude,
        right: .greatestFiniteMagnitude
    )
    #endif

    #if os(macOS)
    @NSManaged var _safeAreaInsets: PlatformEdgeInsets

    var recursiveIgnoreHitTest: Bool = false

    var customAcceptsFirstMouse: Bool?
    #endif

    var inLayoutSizeThatFits: Bool = false

    var cachedImplementsFittingSize: Bool?

    var layoutInvalidator: PlatformViewLayoutInvalidator?

    var invalidationPending: Bool = false

    var cachedLayoutTraits: _LayoutTraits?

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
        #if os(iOS) || os(visionOS)
        if Content.isViewController {
            viewHierarchyMode = isLinkedOnOrAfter(.v6) ? .willMoveToSuperview : .didMoveToWindow
        }
        if isLinkedOnOrAfter(.v6) {
            layer.allowsGroupOpacity = false
            layer.allowsGroupBlending = false
        }
        #elseif os(macOS)
        if isLinkedOnOrAfter(.v6) {
            layer?.allowsGroupOpacity = false
            layer?.allowsGroupBlending = false
        }
        clipsToBounds = false
        _setWants(toHostAutolayoutEngine: true)
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
        #if os(iOS) || os(visionOS)
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
        func validateDimension(
            min: CGFloat,
            ideal: CGFloat,
            max: CGFloat
        ) -> _LayoutTraits.Dimension {
            let infinity = CGFloat.infinity
            var min = min == .greatestFiniteMagnitude ? infinity : min
            var ideal = ideal == .greatestFiniteMagnitude ? infinity : ideal
            var max = max == .greatestFiniteMagnitude ? infinity : max
            if !(0 <= min && min < infinity) {
                Log.externalWarning(
                    String(
                        format: "%@ has a minimum length (%lf) that doesn't satisfy 0 <= min < .infinity.",
                        self,
                        min
                    )
                )
                min = .zero
            }
            if !(min <= max) {
                Log.externalWarning(
                    String(
                        format: "%@ has an maximum length (%lf) that doesn't satisfy min (%lf) <= max (%lf).",
                        self,
                        max,
                        min,
                        max
                    )
                )
                max = min
            }
            if !(ideal.isFinite && min <= ideal && ideal <= max) {
                Log.externalWarning(
                    String(
                        format: "%@ has an ideal length (%lf) that doesn't satisfy min (%lf) <= ideal <= max (%lf) < .infinity.",
                        self,
                        ideal,
                        min,
                        max
                    )
                )
                ideal = min
            }
            return .init(min: min, ideal: ideal, max: max)
        }

        var min = CGSize.zero
        var max = CGSize.zero
        var ideal = CGSize.zero
        let options = Content.layoutOptions(representedViewProvider)
        let prioritySelector = #selector(
            NSView.measureMin(_:max:ideal:stretchingPriority:)
        )
        if options.contains(._1), responds(to: prioritySelector) {
            measureMin(
                &min,
                max: &max,
                ideal: &ideal,
                stretchingPriority: 500
            )
        } else {
            measureMin(&min, max: &max, ideal: &ideal)
        }
        let width = validateDimension(
            min: min.width,
            ideal: ideal.width,
            max: max.width
        )
        let height = validateDimension(
            min: min.height,
            ideal: ideal.height,
            max: max.height
        )
        return .init(width: width, height: height)
        #endif
    }

    func layoutTraits() -> _LayoutTraits {
        guard let cachedLayoutTraits else {
            #if os(macOS)
            let invalidator = layoutInvalidator
            layoutInvalidator = nil
            updateConstraintsForSubtreeIfNeeded()
            layoutInvalidator = invalidator
            #endif
            let traits = intrinsicLayoutTraits()
            cachedLayoutTraits = traits
            return traits
        }
        return cachedLayoutTraits
    }

    func updateEnvironment(_ environment: EnvironmentValues, viewPhase: _GraphInputs.Phase) {
        let colorSchemeChanged = self.environment.colorScheme != environment.colorScheme
        self.environment = environment
        self.viewPhase = viewPhase
        updateNestedHosts(.environment, colorSchemeChanged: colorSchemeChanged)
        adoptEnvironment(environment, hostedSubview: Content.platformView(for: representedViewProvider))
    }

    func updateSafeAreaInsets(_ insets: PlatformEdgeInsets?) {
        safeAreaHelper.updateSafeAreaInsets(insets, delegate: self)
    }

    private func updateNestedHosts(_ properties: ViewRendererHostProperties, colorSchemeChanged: Bool) {
        #if os(iOS) || os(visionOS)
        guard let viewController = representedViewProvider as? UIViewController else {
            _noteTraitsDidChangeRecursively()
            return
        }
        guard let parentController = host?.as(UIViewControllerProvider.self)?.uiViewController else {
            return
        }
        let traits = traitCollection.byOverriding(
            with: environment,
            viewPhase: viewPhase,
            focusedValues: focusedValues
        )
        Update.enqueueAction(reason: nil) { [weak parentController] in
            parentController?._noWarn_setOverrideTraitCollection(traits, forChild: viewController)
            viewController.updateTraitsIfNeeded()
            if colorSchemeChanged {
                parentController?.setNeedsStatusBarAppearanceUpdate()
            }
        }
        #elseif os(macOS)
        var views = subviews
        while !views.isEmpty {
            let view = views.removeFirst()
            if let host = view as? ViewRendererHost {
                host.invalidateProperties(properties)
            } else {
                views.append(contentsOf: view.subviews)
            }
        }
        #endif
    }

    override var hostedView: PlatformView? {
        get { super.hostedView }
        set {
            super.hostedView = newValue
            #if os(macOS)
            cachedImplementsFittingSize = nil
            #endif
        }
    }

    #if os(iOS) || os(visionOS)
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
        guard newSuperview != nil else {
            return
        }
        guard let viewController = representedViewProvider as? PlatformViewController else {
            return
        }
        let view = viewController.view
        guard view.superview != self else {
            return
        }
        hostedView = view
        needsUpdateConstraints = true
    }

    override func viewDidMoveToSuperview() {
        defer { super.viewDidMoveToSuperview() }
        guard superview != nil else { return }
        _setDefaultKeyViewLoop()
        _primitiveSetPreviousKeyView(host as? NSView)
        _primitiveSetNextKeyView(host as? NSView)
        updateConstraintsForSubtreeIfNeeded()
    }

    override func removeFromSuperview() {
        if let viewController = representedViewProvider as? NSViewController {
            viewController.view.removeFromSuperview()
        }
        super.removeFromSuperview()
    }
    #endif

    #if os(iOS) || os(visionOS)
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard UnifiedHitTestingFeature.isEnabled else {
            return super.hitTest(point, with: event)
        }
        let result = super.hitTest(point, with: event)
        return result === self ? nil : result
    }
    #elseif os(macOS)
    override func hitTest(_ point: CGPoint) -> NSView? {
        hitTest(point, cacheKey: nil)
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        if ResponderBasedHitTesting.isEnabled {
            return defaultAcceptsFirstMouse(for: event) {
                super.acceptsFirstMouse(for: event)
            }
        }
        return effectiveAcceptsFirstMouse ?? super.acceptsFirstMouse(for: event)
    }

    override func shouldDelayWindowOrdering(for event: NSEvent) -> Bool {
        defaultShouldDelayWindowOrdering(for: event) {
            super.shouldDelayWindowOrdering(for: event)
        }
    }
    #endif

    #if os(iOS) || os(visionOS)
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

    private func layoutHostedView() {
        guard let hostedView,
              !hostedView._wantsConstraintBasedLayout,
              bounds.width != .zero, bounds.height != .zero else {
            return
        }
        hostedView.frame = hostedView.frame(forAlignmentRect: bounds)
    }

    override func resizeSubviews(withOldSize oldSize: CGSize) {
        super.resizeSubviews(withOldSize: oldSize)
        layoutHostedView()
    }

    override var fittingSize: CGSize {
        if Content.isViewController {
            return super.fittingSize
        } else {
            return Content.platformView(for: representedViewProvider).fittingSize
        }
    }

    private var implementsFittingSize: Bool {
        if let cachedImplementsFittingSize {
            return cachedImplementsFittingSize
        }
        guard let hostedView else { return false }
        let implementation = hostedView.method(for: fittingSizeSelector)
        let result = implementation != defaultFittingSizeIMP
        cachedImplementsFittingSize = result
        return result
    }

    override func _layoutSizeThatFits(_ size: CGSize, fixedAxes: UInt64) -> CGSize {
        let wasInLayoutSizeThatFits = inLayoutSizeThatFits
        inLayoutSizeThatFits = true
        defer { inLayoutSizeThatFits = wasInLayoutSizeThatFits }
        guard let hostedView else { return size }
        let wantsConstraints = hostedView._wantsConstraintBasedLayout
        let boundsSize = hostedView.bounds.size
        var result: CGSize
        if let control = hostedView as? NSControl {
            result = control._layoutSizeThatFits(size, fixedAxes: fixedAxes)
        } else {
            result = super._layoutSizeThatFits(size, fixedAxes: fixedAxes)
        }
        if (result.width == boundsSize.width || result.height == boundsSize.height),
           !wantsConstraints, !implementsFittingSize {
            let intrinsicSize = hostedView.intrinsicContentSize
            if result.width == boundsSize.width {
                result.width = intrinsicSize.width == NSView.noIntrinsicMetric ? size.width : intrinsicSize.width
            }
            if result.height == boundsSize.height {
                result.height = intrinsicSize.height == NSView.noIntrinsicMetric ? size.height : intrinsicSize.height
            }
        }
        if !wantsConstraints, !implementsFittingSize {
            if result.width < size.width,
               hostedView.contentHuggingPriority(for: .horizontal) < .defaultHigh {
                result.width = size.width
            } else if result.width > size.width,
                      hostedView.contentCompressionResistancePriority(for: .horizontal) < .defaultHigh {
                result.width = size.width
            }
            if result.height < size.height,
               hostedView.contentHuggingPriority(for: .vertical) < .defaultHigh {
                result.height = size.height
            } else if result.height > size.height,
                      hostedView.contentCompressionResistancePriority(for: .vertical) < .defaultHigh {
                result.height = size.height
            }
        }
        return result
    }

    func invalidateLayout() {
        cachedLayoutTraits = nil
        if let layoutInvalidator, let graphHost = layoutInvalidator.graphHost {
            graphHost.asyncTransaction(invalidating: layoutInvalidator.layoutComputer)
        }
        invalidationPending = false
    }

    func enqueueLayoutInvalidation() {
        guard layoutInvalidator != nil else {
            cachedLayoutTraits = nil
            return
        }
        guard !invalidationPending, superview != nil else { return }
        invalidationPending = true
        Update.enqueueAction(reason: nil) { [weak self] in
            self?.invalidateLayout()
        }
    }

    override func _layoutMetricsInvalidatedForHostedView() {
        super._layoutMetricsInvalidatedForHostedView()
        if Content.layoutOptions(representedViewProvider).contains(._0),
           !inLayoutSizeThatFits, hostedView != nil {
            enqueueLayoutInvalidation()
        }
    }

    override var alignmentRectInsets: NSEdgeInsets { .zero }

    override func updateConstraints() {
        _ = enableUnifiedLayout()
        if let hostedView, hostedView._wantsConstraintBasedLayout {
            hostedView.translatesAutoresizingMaskIntoConstraints = false
        }
        super.updateConstraints()
    }

    override func _priorityForEngineHostConstraints() -> NSLayoutConstraint.Priority {
        .init(500)
    }
    #endif

    #if os(iOS) || os(visionOS)
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

    @objc static func automaticallyTracksDependenciesOn_safeAreaInsets() -> Bool {
        true
    }

    @objc static func default_safeAreaInsets() -> NSEdgeInsets {
        .init(
            top: .greatestFiniteMagnitude,
            left: .greatestFiniteMagnitude,
            bottom: .greatestFiniteMagnitude,
            right: .greatestFiniteMagnitude
        )
    }
    #endif

    override var intrinsicContentSize: CGSize {
        if Content.isViewController {
            return super.intrinsicContentSize
        } else {
            let platformView = Content.platformView(for: representedViewProvider)
            return platformView.intrinsicContentSize
        }
    }
}

extension PlatformViewHost: PlatformFocusViewProvider {
    var focusView: PlatformView {
        if let provider = Content.platformView(for: representedViewProvider) as? any PlatformFocusViewProvider {
            return provider.focusView
        }
        return Content.platformView(for: representedViewProvider)
    }
}

extension PlatformViewHost: SafeAreaHelperDelegate {
    var defaultSafeAreaInsets: PlatformEdgeInsets {
        #if os(iOS) || os(visionOS)
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

// MARK: - PlatformViewHost + HitTest

extension PlatformViewHost: HitTestingLeafPlatformView {
    var usesResponderForHitTesting: Bool {
        #if os(macOS)
        ResponderBasedHitTesting.isEnabled
        #else
        _openSwiftUIUnreachableCode()
        #endif
    }

    var foreignSubviewsForHitTesting: [PlatformView] {
        #if os(macOS)
        []
        #else
        _openSwiftUIUnreachableCode()
        #endif
    }

    var isTransparentForHitTesting: Bool {
        #if os(macOS)
        true
        #else
        _openSwiftUIUnreachableCode()
        #endif
    }

    #if os(macOS)
    func hitTest(_ point: PlatformPoint, cacheKey: UInt32?) -> PlatformView? {
        if ResponderBasedHitTesting.isEnabled {
            return defaultHitTest(point, radius: 1, cacheKey: cacheKey) {
                super.hitTest(point)
            }
        } else if UnifiedHitTestingFeature.isEnabled {
            guard !recursiveIgnoreHitTest,
                  alphaValue >= ViewResponder.minOpacityForHitTest else {
                return nil
            }
            let result = super.hitTest(point)
            return result === self ? nil : result
        } else {
            return super.hitTest(point)
        }
    }
    #endif
}

extension PlatformViewHost: AcceptsFirstMouseCustomizing {}

extension PlatformViewHost: RecursiveIgnoreHitTestCustomizing {}

#if os(macOS)
extension PlatformViewHost: PlatformLayoutContainer {}

private let fittingSizeSelector = #selector(getter: NSView.fittingSize)

private let defaultFittingSizeIMP = NSView.instanceMethod(for: fittingSizeSelector)
#endif

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
