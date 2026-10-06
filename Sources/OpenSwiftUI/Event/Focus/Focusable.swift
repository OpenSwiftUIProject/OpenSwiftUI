//
//  Focusable.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: B6A2D4E72E5722B5103497ADB7778B5F (SwiftUI)

import COpenSwiftUI
import Foundation
import OpenAttributeGraphShims
@_spi(Private)
@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

#if os(iOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - View + Focus

extension View {
    /// Specifies if the view is focusable.
    ///
    /// - Parameter isFocusable: A Boolean value that indicates whether this
    ///   view is focusable.
    ///
    /// - Returns: A view that sets whether a view is focusable.
    @available(OpenSwiftUI_v3_0, *)
    nonisolated public func focusable(_ isFocusable: Bool = true) -> some View {
        modifier(_FocusableModifier(
            isFocusable: isFocusable,
            configuration: FocusInteractions.automatic,
            onFocusChange: { _ in }
        ))
    }

    /// Specifies if the view is focusable, and if so, what focus-driven
    /// interactions it supports.
    ///
    /// By default, OpenSwiftUI enables all possible focus interactions. However, on
    /// macOS and iOS it is conventional for button-like views to only accept
    /// focus when the user has enabled keyboard navigation system-wide in the
    /// Settings app. Clients can reproduce this behavior with custom views by
    /// only supporting `.activate` interactions.
    ///
    ///     MyTapGestureView(...)
    ///         .focusable(interactions: .activate)
    ///
    /// - Note: The focus interactions allowed for custom views changed in
    ///   macOS 14—previously, custom views could only become focused with
    ///   keyboard navigation enabled system-wide. Clients built using older
    ///   SDKs will continue to see the older focus behavior, while custom views
    ///   in clients built using macOS 14 or later will always be focusable
    ///   unless the client requests otherwise by specifying a restricted set of
    ///   focus interactions.
    ///
    /// - Parameters:
    ///   - isFocusable: `true` if the view should participate in focus;
    ///     `false` otherwise. The default value is `true`.
    ///   - interactions: The types of focus interactions supported by the view.
    ///     The default value is `.automatic`.
    /// - Returns: A view that sets whether its child is focusable.
    @available(OpenSwiftUI_v5_0, *)
    nonisolated public func focusable(_ isFocusable: Bool = true, interactions: FocusInteractions) -> some View {
        modifier(_FocusableModifier(
            isFocusable: isFocusable,
            configuration: interactions,
            onFocusChange: { _ in }
        ))
    }

    @_spi(_)
    @available(OpenSwiftUI_v5_0, *)
    @available(*, deprecated, message: "Use focusEffectDisabled(_:) instead")
    nonisolated public func focusEffect(_ effect: FocusEffect) -> some View {
        environment(\.focusEffect, effect)
    }

    /// Adds a condition that controls whether this view can display focus
    /// effects, such as a default focus ring or hover effect.
    ///
    /// The higher views in a view hierarchy can override the value you set on
    /// this view. In the following example, the button does not display a focus
    /// effect because the outer `focusEffectDisabled(_:)` modifier overrides
    /// the inner one:
    ///
    ///     HStack {
    ///         Button("Press") {}
    ///             .focusEffectDisabled(false)
    ///     }
    ///     .focusEffectDisabled(true)
    ///
    /// - Parameter disabled: A Boolean value that determines whether this view
    ///   can display focus effects.
    /// - Returns: A view that controls whether focus effects can be displayed
    ///   in this view.
    @available(OpenSwiftUI_v5_0, *)
    nonisolated public func focusEffectDisabled(_ disabled: Bool = true) -> some View {
        transformEnvironment(\.isFocusEffectEnabled) {
            $0 = $0 && !disabled
        }
    }
}

// MARK: - FocusInteractions

/// Values describe different focus interactions that a view can support.
@available(OpenSwiftUI_v5_0, *)
public struct FocusInteractions: OptionSet, Sendable {
    /// The view has a primary action that can be activated via focus gestures.
    ///
    /// On macOS and iOS, focus-driven activation interactions are only possible
    /// when all-controls keyboard navigation is enabled. On tvOS and watchOS,
    /// focus-driven activation interactions are always possible.
    public static let activate: FocusInteractions = .init(rawValue: 1 << 0)

    /// The view captures input from non-spatial sources like a keyboard or
    /// Digital Crown.
    ///
    /// Views that support focus-driven editing interactions become focused when
    /// the user taps or clicks on them, or when the user issues a focus
    /// movement command.
    public static let edit: FocusInteractions = .init(rawValue: 1 << 1)

    @_spi(Private)
    public static let navigate: FocusInteractions = .init(rawValue: 1 << 2)

    /// The view supports whatever focus-driven interactions are commonly
    /// expected for interactive content on the current platform.
    public static var automatic: FocusInteractions { [.activate, .edit] }

    public var rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

// MARK: - FocusEffect

@_spi(_)
@available(OpenSwiftUI_v5_0, *)
@available(*, deprecated, message: "Use focusEffectDisabled(_:) instead")
public struct FocusEffect: Equatable, Sendable {
    enum Kind {
        case automatic
        case disabled
    }

    var kind: Kind

    public static let automatic: FocusEffect = .init(kind: .automatic)

    public static let disabled: FocusEffect = .init(kind: .disabled)
}

// MARK: - EnvironmentValues + Focus Effect

@available(OpenSwiftUI_v5_0, *)
extension EnvironmentValues {
    @_spi(_)
    @available(*, deprecated, message: "Use isFocusEffectEnabled instead")
    public fileprivate(set) var focusEffect: FocusEffect {
        get { isFocusEffectEnabled ? .automatic : .disabled }
        set { isFocusEffectEnabled = newValue.kind == .automatic }
    }

    private struct IsFocusEffectEnabledKey: EnvironmentKey {
        static var defaultValue: Bool { true }
    }

    /// A Boolean value that indicates whether the view associated with this
    /// environment allows focus effects to be displayed.
    ///
    /// The default value is `true`.
    public var isFocusEffectEnabled: Bool {
        get { self[IsFocusEffectEnabledKey.self] }
        set { self[IsFocusEffectEnabledKey.self] = newValue }
    }
}

// MARK: - _FocusableModifier

@available(OpenSwiftUI_v1_0, *) // iOS 13.4
public struct _FocusableModifier: ViewModifier, MultiViewModifier, PrimitiveViewModifier {
    var isFocusable: Bool

    var configuration: any _FocusableModifier_Configuration

    var onFocusChange: (Bool) -> Void

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        #if os(macOS)
        _openSwiftUIUnimplementedFailure()
        #else
        _openSwiftUIUnimplementedFailure()
        #endif
    }
}

@available(*, unavailable)
extension _FocusableModifier: Sendable {}

// MARK: - _FocusableModifier_Configuration

protocol _FocusableModifier_Configuration {
    func resolve(in environment: EnvironmentValues) -> FocusableOptions
}

// MARK: - FocusableOptions

@_spi(Private)
@available(OpenSwiftUI_v3_0, *)
public struct FocusableOptions: OptionSet {
    public static let fromMouse: FocusableOptions = .init(rawValue: 1 << 0)

    public static let fromKeyboard: FocusableOptions = .init(rawValue: 1 << 1)

    public static let platformItemDrawsFocusRingMask: FocusableOptions = .init(rawValue: 1 << 2)

    public static let platformContainerHandlesFocus: FocusableOptions = .init(rawValue: 1 << 3)

    public static let preventNavigationToSubviews: FocusableOptions = .init(rawValue: 1 << 4)

    public static let fromClientUpdate: FocusableOptions = .init(rawValue: 1 << 5)

    public static let all: FocusableOptions = [.fromMouse, .fromKeyboard, .platformItemDrawsFocusRingMask]

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

@_spi(Private)
@available(*, unavailable)
extension FocusableOptions: Sendable {}

extension FocusInteractions: _FocusableModifier_Configuration {
    func resolve(in environment: EnvironmentValues) -> FocusableOptions {
        var options: FocusableOptions = []
        if isEmpty {
            options = .fromClientUpdate
        } else {
            #if OPENSWIFTUI_RELEASE_2026
            if contains(.activate) {
                options = [.fromClientUpdate]
            }
            if contains(.edit) {
                options = [.fromClientUpdate, .fromKeyboard, .fromMouse]
            }
            if contains(.navigate) {
                options.formUnion([.fromClientUpdate, .fromKeyboard])
            }
            #else
            if contains(.activate), environment.allControlsNavigable {
                options = [.fromClientUpdate, .fromKeyboard]
            }
            if contains(.navigate) {
                options.formUnion([.fromClientUpdate, .fromKeyboard])
            }
            if contains(.edit) {
                options.formUnion([.fromClientUpdate, .fromKeyboard, .fromMouse])
            }
            #endif
        }
        if !environment.isFocusEffectEnabled {
            options.insert(.platformItemDrawsFocusRingMask)
        }
        return options
    }
}

extension FocusableOptions: _FocusableModifier_Configuration {
    func resolve(in environment: EnvironmentValues) -> FocusableOptions {
        var options = self
        if environment.allControlsNavigable {
            options.formUnion(.fromKeyboard)
        }
        if !environment.isFocusEffectEnabled {
            options.formUnion(.platformItemDrawsFocusRingMask)
        }
        if !options.isDisjoint(with: [.fromMouse, .fromKeyboard]) {
            options.formUnion(.fromClientUpdate)
        }
        return options
    }
}

// MARK: - FocusableViewResponder [TBA]

private class FocusableViewResponder: DefaultLayoutViewResponder, FocusResponder {
    weak var focusAccessibilityNode: AccessibilityNode?
    var keyPressHandlers: [KeyPress.Handler] = []
    var baseItem: FocusItem.ViewItem? {
        didSet {
            #if os(iOS) || os(visionOS)
            if oldValue?.id != baseItem?.id {
                _uikitFocusItem = nil
            }
            #endif
        }
    }
    var frame: CGRect?
    var isEnabled: Bool = true
    var geometry: ContentResponderHelper<TrivialContentResponder> = .init() {
        didSet {
            guard !geometry.size.isNaN, geometry.size != .zero else {
                frame = nil
                return
            }
            var frame = CGRect(origin: .zero, size: geometry.size)
            frame.convert(to: .id(hostingViewCoordinateSpace), transform: geometry.transform)
            self.frame = frame
        }
    }
    #if os(iOS) || os(visionOS)
    var isFocused: WeakAttribute<Bool>?
    var isPlatformFocusSystemEnabled: Bool = false
    var groupID: FocusGroupIdentifier?
    private var _uikitFocusItem: UIKitFocusableViewResponderItem?

    var platformItem: PlatformFocusItem? { hostedItem }

    // Deleted in the target image.
    var focusGroupID: FocusGroupIdentifier? { _openSwiftUIUnreachableCode() }
    #elseif os(macOS)
    var evaluateDefaultFocus: EvaluateDefaultFocusAction?
    var effectiveLayoutDirection: LayoutDirection?
    private weak var _focusRingView: (NSView & FocusRingDelegate)?
    weak var firstKeyViewInSubtree: NSView?
    weak var lastKeyViewInSubtree: NSView?

    var isInVisibleRect: Bool {
        guard let frame else { return false }
        guard var visibleRect = geometry.transform.containingScrollGeometry?.visibleRect else {
            return true
        }
        visibleRect.convert(to: .id(hostingViewCoordinateSpace), transform: geometry.transform)
        return frame.intersection(visibleRect) != .null
    }

    var delegatesFocusEffect: Bool {
        guard let focusItem, case let .view(item) = focusItem.base else { return false }
        return item.delegatesFocusEffect
    }

    var focusRingView: (NSView & FocusRingDelegate)? {
        guard let focusItem else { return nil }
        if focusItem.platformItemDrawsFocusRingMask {
            var result: (NSView & FocusRingDelegate)?
            visitFocusResponders { responder in
                guard let item = responder.focusItem,
                      case let .platformResponder(view) = item.base,
                      view.base != nil,
                      let view = responder.focusRingView,
                      view.canShowFocusRing else { return .next }
                result = view
                return .cancel
            }
            return result
        } else if delegatesFocusEffect {
            return firstAncestor(ofType: FocusEffectDelegateResponder.self)?.focusRingView
        } else {
            return _focusRingView
        }
    }

    func setFocusRingView(_ view: (NSView & FocusRingDelegate)?) {
        _focusRingView = view
    }
    #endif

    var focusItem: FocusItem? {
        guard let baseItem else { return nil }
        #if os(iOS) || os(visionOS)
        if isPlatformFocusSystemEnabled, let hostedItem {
            return FocusItem(
                base: .platformItem(WeakBox(hostedItem)),
                prefersFocusSystem: false,
                responder: self
            )
        }
        #endif
        return FocusItem(base: .view(baseItem), prefersFocusSystem: false, responder: self)
    }

    override func bindEvent(_ event: any EventType) -> ResponderNode? {
        if let responder = super.bindEvent(event) {
            return responder
        }
        return event.isFocusEvent ? focusProxyResponder : nil
    }

    var focusProxyResponder: ViewResponder? {
        var result: ViewResponder?
        visit { responder in
            guard let responder = responder as? FocusEventProxyResponder else { return .next }
            result = responder
            return .cancel
        }
        return result
    }

    #if os(macOS)
    override func extendPrintTree(string: inout String) {
        string += "[\(frame!.size.width), \(frame!.size.height)] @\((frame!.origin.x, frame!.origin.y)) \(_featuresString)"
    }

    private var _featuresString: String {
        "[ \(platformItem != nil ? "P" : " ")\(focusItem != nil ? "i" : " ")\(focusAccessibilityNode != nil ? "x" : " ")\(focusRingView != nil ? "r" : " ")]"
    }
    #endif
}

#if os(iOS) || os(visionOS)
extension FocusableViewResponder: AnyUIKitHostedFocusItemResponder {
    var hostedItem: (any AnyUIKitHostedFocusItem)? {
        guard let baseItem, !baseItem.options.contains(.platformContainerHandlesFocus) else {
            return nil
        }
        if _uikitFocusItem == nil {
            _uikitFocusItem = UIKitFocusableViewResponderItem(self)
        }
        return _uikitFocusItem
    }
}

// MARK: - UIKitFocusableViewResponderItem [TBA]

private class UIKitFocusableViewResponderItem: UIKitFocusableViewResponderItemBase, UIKitHostedFocusItem, TrivialContentPathObserver {
    weak var base: FocusableViewResponder?
    weak var host: UIView?
    var frame: CGRect = .zero
    private var contentPath: Path?
    private lazy var defaultFocusGroupIdentifier: FocusGroupIdentifier = .explicit(.init(base: Int(makeUniqueID())))

    init(_ base: FocusableViewResponder) {
        self.base = base
        super.init()
    }

    // Deleted in the target image.
    var id: ViewIdentity { _openSwiftUIUnreachableCode() }

    var responder: (ViewResponder & BaseFocusResponder)? { base }

    var canBecomeFocused: Bool { base?.baseItem!.isFocusable ?? false }

    override var next: UIResponder? {
        guard GestureContainerFeature.isEnabled else { return host }
        guard let responder = base.map({ $0.focusProxyResponder ?? $0 }) else { return nil }
        var parent = responder.parent
        while let current = parent {
            if let container = current.gestureContainer {
                return (container as! UIResponder)
            } else if let view = (current as? UIViewResponder)?.hostView {
                return view
            }
            parent = current.parent
        }
        return responder.host?.as(UIView.self)
    }

    override var openswiftui_focusGroupIdentifier: String? {
        switch base?.groupID ?? defaultFocusGroupIdentifier {
        case let .explicit(id): "org.openswiftuiproject.openswiftui.FocusGroup-\(id.base)"
        case .inferred: nil
        }
    }

    var parentFocusEnvironment: (any UIFocusEnvironment)? { host }

    var preferredFocusEnvironments: [any UIFocusEnvironment] { [] }

    var focusItemContainer: (any UIFocusItemContainer)? { nil }

    func setNeedsFocusUpdate() {
        UIFocusSystem.focusSystem(for: self)?.requestFocusUpdate(to: self)
    }

    func updateFocusIfNeeded() {
        UIFocusSystem.focusSystem(for: self)?.updateFocusIfNeeded()
    }

    func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        guard context.nextFocusedItem === self,
              context.previouslyFocusedItem != nil,
              let item = base?.baseItem else { return true }
        return item.isFocusable && item.options.contains(.fromKeyboard)
    }

    func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        Log.focus?.log("focus changed for: \(UIKitFocusItemDescription(self))")
        base?.baseItem!.onFocusChange(context.nextFocusedItem === self)
        updateFocusedState()
    }

    func updateFocusedState() {
        guard let isFocused = base?.isFocused, let attribute = isFocused.attribute else { return }
        attribute.graph.viewGraph().asyncTransaction(
            mutation: FocusedStateCommitMutation(value: self.isFocused, attribute: isFocused)
        )
    }

    private struct FocusedStateCommitMutation: GraphMutation {
        var value: Bool
        var attribute: WeakAttribute<Bool>

        func apply() {
            attribute.attribute?.value = value
        }

        mutating func combine(with other: some GraphMutation) -> Bool {
            guard let other = other as? Self, attribute == other.attribute else { return false }
            self = other
            return true
        }
    }

    var focusEffect: UIFocusEffect? {
        let path: Path
        if let contentPath {
            path = contentPath
        } else {
            guard let base else { return nil }
            var contentPath = Path()
            // TODO: Use the scroll-view safe area for HostingScrollView.PlatformGroupContainer.
            base.addContentPath(
                to: &contentPath,
                kind: ._focusEffect,
                in: .id(hostingViewCoordinateSpace),
                observer: self
            )
            if contentPath.isEmpty {
                contentPath = Update.ensure {
                    let position = Graph.withoutUpdate { base.inputs.position.value }
                    let size = Graph.withoutUpdate { base.inputs.size.value.value }
                    return Path(CGRect(origin: position, size: size))
                }
            }
            self.contentPath = contentPath
            path = contentPath
        }
        if base?.baseItem!.options.contains(.platformItemDrawsFocusRingMask) == true {
            return nil
        }
        let effect = path.isEmpty ? UIFocusHaloEffect() : UIFocusHaloEffect(path: UIBezierPath(cgPath: path.cgPath))
        effect.containerView = host
        return effect
    }

    func contentPathDidChange(for parent: ViewResponder) {
        contentPath = nil
    }
}
#endif

#if os(macOS)
// MARK: - FocusRingDelegate

protocol FocusRingDelegate: AnyObject {
    var focused: Bool { get set }

    var canShowFocusRing: Bool { get }
}
#endif

// MARK: - FocusableOptionsKey

struct FocusableOptionsKey: PreferenceKey {
    static var defaultValue: FocusableOptions { [] }

    static func reduce(value: inout FocusableOptions, nextValue: () -> FocusableOptions) {
        value.formUnion(nextValue())
    }
}

// MARK: - IsFocusedEnvironmentChild

struct IsFocusedEnvironmentChild: Rule {
    @Attribute var item: FocusItem.ViewItem
    @Attribute var environment: EnvironmentValues
    #if os(iOS) || os(visionOS)
    @Attribute var isPlatformItemFocused: Bool
    #elseif os(macOS)
    @OptionalAttribute var focusedItem: FocusItem??
    #endif

    var value: EnvironmentValues {
        var env = environment
        #if os(iOS) || os(visionOS)
        if !item.options.contains(.platformContainerHandlesFocus) {
            env.isFocused = isPlatformItemFocused
        }
        #elseif os(macOS)
        if let focusedItem = focusedItem ?? nil,
           case let .view(focusedView) = focusedItem.base {
            env.isFocused = focusedView.id == item.id
        } else {
            env.isFocused = false
        }
        #endif
        return env
    }
}

// MARK: - FocusCoordinateSpaceTransform

#if os(macOS)
let focusCoordinateSpace: CoordinateSpace.ID = .init()

struct FocusCoordinateSpaceTransform: Rule {
    @Attribute var transform: ViewTransform
    @Attribute var position: CGPoint

    var value: ViewTransform {
        var transform = transform
        transform.appendPosition(position)
        transform.appendCoordinateSpace(id: focusCoordinateSpace)
        return transform
    }
}
#endif

// MARK: - IOSFocusEnabledFlag

#if os(iOS) || os(visionOS)
struct IOSFocusEnabledFlag: ViewInputBoolFlag {
    static func evaluate(inputs: _GraphInputs) -> Bool {
        inputs[Self.self] == value
            && (inputs.interfaceIdiom.accepts(.pad)
                || inputs.interfaceIdiom.accepts(.carPlay))
    }
}
#endif

// MARK: - UpdateViewFocusItem

private struct UpdateViewFocusItem: StatefulRule, ObservedAttribute {
    @Attribute var modifier: _FocusableModifier
    @Attribute var options: FocusableOptions
    @Attribute var phase: ViewPhase
    @Attribute var isEnabled: Bool
    @Attribute var focusDisabled: Bool
    #if os(macOS)
    @OptionalAttribute var focusedItem: FocusItem??
    @Attribute var delegatesFocusEffect: Bool
    #endif
    weak var viewGraph: ViewGraph? = .current
    var identityTracker: ViewIdentity.Tracker = .init()
    var isFocused = false

    init(
        modifier: Attribute<_FocusableModifier>,
        options: Attribute<FocusableOptions>,
        inputs: _ViewInputs
    ) {
        _modifier = modifier
        _options = options
        _phase = inputs.viewPhase
        _isEnabled = inputs.base.isEnabled
        #if os(macOS)
        _focusedItem = .init(inputs.focusedItem)
        #endif
        _focusDisabled = inputs.base.focusDisabled
        #if os(macOS)
        _delegatesFocusEffect = inputs.base.delegatesFocusEffect
        #endif
    }

    typealias Value = FocusItem.ViewItem

    mutating func updateValue() {
        let (modifier, modifierChanged) = $modifier.changedValue()
        let (options, optionsChanged) = $options.changedValue()
        let (isEnabled, enabledChanged) = $isEnabled.changedValue()
        #if os(macOS)
        let (focusDisabled, disabledChanged) = $focusDisabled.changedValue()
        let oldID = identityTracker.id
        #else
        _ = $focusDisabled.changedValue()
        #endif
        let (id, identityChanged) = identityTracker.update(for: phase)
        #if os(macOS)
        let (focusedItem, focusChanged) = _focusedItem.changedValue() ?? (nil, false)
        if identityChanged || focusChanged || modifierChanged || optionsChanged || enabledChanged || disabledChanged || !hasValue {
            if let focusedItem, case let .view(focusedView) = focusedItem.base {
                if focusedView.id == id {
                    isFocused = true
                    if !modifier.isFocusable || focusDisabled {
                        viewGraph?[FocusViewGraph.self]?.pointee.needsFocusUpdate = true
                    }
                } else {
                    isFocused = false
                    if focusedView.id == oldID {
                        viewGraph?[FocusViewGraph.self]?.pointee.needsFocusUpdate = true
                    }
                }
            }
        }
        #endif
        if identityChanged || modifierChanged || optionsChanged || enabledChanged || !hasValue {
            #if os(macOS)
            value = .init(
                id: id,
                isFocusable: modifier.isFocusable && isEnabled,
                options: options,
                onFocusChange: modifier.onFocusChange,
                delegatesFocusEffect: false
            )
            #else
            value = .init(
                id: id,
                isFocusable: modifier.isFocusable && isEnabled,
                options: options,
                onFocusChange: modifier.onFocusChange
            )
            #endif
        }
        #if os(macOS)
        value.delegatesFocusEffect = delegatesFocusEffect
        #endif
    }

    func destroy() {
        _openSwiftUIEmptyStub()
    }
}

// MARK: - ResolvedOptions

private struct ResolvedOptions: Rule {
    @Attribute var modifier: _FocusableModifier
    @Attribute var environment: EnvironmentValues

    var value: FocusableOptions {
        modifier.configuration.resolve(in: environment)
    }
}

// MARK: - EnvironmentValues + Focus

extension EnvironmentValues {
    private struct IsPlatformFocusSystemEnabled: EnvironmentKey {
        static var defaultValue: Bool {
            #if os(macOS) && !targetEnvironment(macCatalyst)
            true
            #else
            false
            #endif
        }
    }

    var isPlatformFocusSystemEnabled: Bool {
        get { self[IsPlatformFocusSystemEnabled.self] }
        set { self[IsPlatformFocusSystemEnabled.self] = newValue }
    }

    private struct IsFocusedKey: EnvironmentKey {
        static var defaultValue: Bool { false }
    }

    /// Returns whether the nearest focusable ancestor has focus.
    ///
    /// If there is no focusable ancestor, the value is `false`.
    @available(OpenSwiftUI_v2_0, *)
    public fileprivate(set) var isFocused: Bool {
        get { self[IsFocusedKey.self] }
        set { self[IsFocusedKey.self] = newValue }
    }

    private struct FocusDisabledKey: EnvironmentKey {
        static var defaultValue: Bool { false }
    }

    var focusDisabled: Bool {
        get { self[FocusDisabledKey.self] }
        set { self[FocusDisabledKey.self] = newValue }
    }
}

extension CachedEnvironment.ID {
    static let focusDisabled: CachedEnvironment.ID = .init()
    static let isPlatformFocusSystemEnabled: CachedEnvironment.ID = .init()
    static let focusGroupID: CachedEnvironment.ID = .init()
    static let evaluateDefaultFocus: CachedEnvironment.ID = .init()
}

extension _GraphInputs {
    var focusDisabled: Attribute<Bool> {
        mapEnvironment(id: .focusDisabled) { $0.focusDisabled }
    }

    var isPlatformFocusSystemEnabled: Attribute<Bool> {
        mapEnvironment(id: .isPlatformFocusSystemEnabled) { $0.isPlatformFocusSystemEnabled }
    }
}

// MARK: - EnvironmentValues + Focus Navigation

extension EnvironmentValues {
    private struct AllControlsNavigableKey: EnvironmentKey {
        static var defaultValue: Bool { false }
    }

    var allControlsNavigable: Bool {
        get { self[AllControlsNavigableKey.self] }
        set { self[AllControlsNavigableKey.self] = newValue }
    }
}

// MARK: - View + Focus (Deprecated)

extension View {
    /// Specifies if the view is focusable and, if so, adds an action to perform
    /// when the view comes into focus.
    ///
    /// - Parameters:
    ///   - isFocusable: A Boolean value that indicates whether this view is
    ///     focusable.
    ///   - onFocusChange: A closure that's called whenever this view either
    ///     gains or loses focus. The Boolean parameter to `onFocusChange` is
    ///     `true` when the view is in focus; otherwise, it's `false`.
    ///
    /// - Returns: A view that sets whether a view is focusable, and triggers
    ///   `onFocusChange` when the view gains or loses focus.
    @available(iOS, unavailable)
    @available(OpenSwiftUI_v1_0, *)
    @available(*, deprecated, message: "Use FocusState<T> and View.focused(_:equals) for functionality previously provided by the onChange parameter.")
    @available(visionOS, unavailable)
    nonisolated public func focusable(
        _ isFocusable: Bool = true,
        onFocusChange: @escaping (_ isFocused: Bool) -> Void = { _ in }
    ) -> some View {
        let configuration: any _FocusableModifier_Configuration
        if _SemanticFeature_v5.isEnabled {
            configuration = FocusInteractions.automatic
        } else {
            configuration = FocusableOptions()
        }
        return modifier(_FocusableModifier(
            isFocusable: isFocusable,
            configuration: configuration,
            onFocusChange: onFocusChange
        ))
    }

    @_spi(Private)
    @available(OpenSwiftUI_v3_0, *)
    @available(*, deprecated, message: "Use View.focusable(_:interactions:) instead.")
    nonisolated public func focusable(_ isFocusable: Bool = true, options: FocusableOptions) -> some View {
        modifier(_FocusableModifier(
            isFocusable: isFocusable,
            configuration: options,
            onFocusChange: { _ in }
        ))
    }
}
