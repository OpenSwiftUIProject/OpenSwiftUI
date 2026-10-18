//
//  DefaultFocus.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 1F8B69996BE941D510140AD6558D8844 (SwiftUI)

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
#if os(iOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - View + DefaultFocus

@available(OpenSwiftUI_v2_0, *)
@available(OpenSwiftUI_macOS_v3_0, *)
@available(iOS, unavailable)
@available(visionOS, unavailable)
extension View {
    /// Indicates that the view should receive focus by default for a given
    /// namespace.
    ///
    /// This modifier sets the initial focus preference when no other view has
    /// focus. Use the environment value ``EnvironmentValues/resetFocus`` to
    /// force a reevaluation of default focus at any time.
    ///
    /// The following tvOS example shows three buttons, labeled "1", "2", and
    /// "3", in a ``VStack``. By default, the "1" button would receive
    /// focus, because it is the first child in the stack. However, the
    /// `prefersDefaultFocus(_:in:)` modifier allows button "3" to receive default
    /// focus instead. Once the buttons are visible, the user can move down to
    /// and focus the "Reset to default focus" button. When the user activates
    /// this button, it uses the ``ResetFocusAction`` to reevaluate default
    /// focus in the `mainNamespace`, which returns the focus to button "3".
    ///
    ///     struct ContentView: View {
    ///         @Namespace var mainNamespace
    ///         @Environment(\.resetFocus) var resetFocus
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Button ("1") {}
    ///                 Button ("2") {}
    ///                 Button ("3") {}
    ///                     .prefersDefaultFocus(in: mainNamespace)
    ///                 Button ("Reset to default focus") {
    ///                     resetFocus(in: mainNamespace)
    ///                 }
    ///             }
    ///             .focusScope(mainNamespace)
    ///         }
    ///     }
    ///
    /// The default focus preference is limited to the focusable ancestor that
    /// matches the provided namespace. If multiple views express this
    /// preference, then OpenSwiftUI applies the current platform rules to
    /// determine which view receives focus.
    ///
    /// - Parameters:
    ///   - prefersDefaultFocus: A Boolean value that indicates whether this
    ///     view prefers to receive focus by default. The default value, `true`,
    ///     causes the view to receive focus by default.
    ///   - namespace: The namespace associated with the focus scope within
    ///     which this view prefers default focus.
    /// - Returns: A modified view that sets whether it prefers to be focused
    ///   by default.
    nonisolated public func prefersDefaultFocus(
        _ prefersDefaultFocus: Bool = true,
        in namespace: Namespace.ID
    ) -> some View {
        modifier(_DefaultFocusModifier(
            prefersDefaultFocus: prefersDefaultFocus,
            defaultFocusNamespace: namespace
        ))
    }

    /// Creates a focus scope that OpenSwiftUI uses to limit default focus
    /// preferences.
    ///
    /// The returned view gets associated with the provided namespace.
    /// Pass this namespace to ``View/prefersDefaultFocus(_:in:)`` and
    /// the ``EnvironmentValues/resetFocus`` function.
    ///
    /// - Parameter namespace: A namespace identifier that OpenSwiftUI can use to
    ///   scope default focus preferences.
    /// - Returns: A view that sets the namespace of descendants for default
    ///   focus.
    nonisolated public func focusScope(_ namespace: Namespace.ID) -> some View {
        modifier(FocusNamespaceModifier(namespace: namespace))
    }
}

@available(iOS, unavailable)
@available(OpenSwiftUI_v2_0, *)
@available(macOS, deprecated: 11.0, message: "Prototype SPI, do not use.")
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension View {
    /// Sets whether `self` prefers to be focused by default
    ///
    /// If multiple views express this preference, then the current platform
    /// rules for determining default focus will be used to choose from among
    /// them.
    ///
    /// - Parameter prefersDefaultFocus: A Boolean value that indicates whether
    ///   this view prefers to be focused by default.
    /// - Returns: A view that sets whether it prefers to be focused by default.
    @MainActor
    @preconcurrency
    public func _prefersDefaultFocus(_ prefersDefaultFocus: Bool = true) -> some View {
        modifier(_DefaultFocusModifier(
            prefersDefaultFocus: prefersDefaultFocus,
            defaultFocusNamespace: nil
        ))
    }
}

@_spi(Private)
@available(OpenSwiftUI_v2_0, *)
@available(OpenSwiftUI_iOS_v4_0, *)
@available(OpenSwiftUI_macOS_v3_0, *)
extension View {
    @MainActor
    @preconcurrency
    public func _prefersDefaultFocus(
        _ prefersDefaultFocus: Bool = true,
        in namespace: Namespace.ID
    ) -> some View {
        modifier(_DefaultFocusModifier(
            prefersDefaultFocus: prefersDefaultFocus,
            defaultFocusNamespace: namespace
        ))
    }

    @MainActor
    @preconcurrency
    public func _focusScope(_ namespace: Namespace.ID) -> some View {
        modifier(FocusNamespaceModifier(namespace: namespace))
    }
}

// MARK: - _DefaultFocusModifier

@available(OpenSwiftUI_v2_0, *)
@available(OpenSwiftUI_iOS_v4_0, *)
public struct _DefaultFocusModifier: ViewModifier, MultiViewModifier, PrimitiveViewModifier {
    var prefersDefaultFocus: Bool
    var defaultFocusNamespace: Namespace.ID?

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = body(_Graph(), inputs)
        if inputs.preferences.requiresViewResponders {
            let responder = DefaultFocusViewResponder(inputs: inputs)
            outputs.preferences.viewResponders = Attribute(DefaultFocusViewResponderFilter(
                responder: responder,
                modifier: modifier.value,
                transform: inputs.transform,
                position: inputs.animatedPosition(),
                size: inputs.animatedSize(),
                children: outputs.viewResponders()
            ))
        }
        return outputs
    }
}

@available(*, unavailable)
extension _DefaultFocusModifier: Sendable {}

// MARK: - DefaultFocusViewResponder

private class DefaultFocusViewResponder: DefaultLayoutViewResponder, BaseFocusResponder {
    var prefersDefaultFocus = false
    var transform = ViewTransform()
    var size = CGSize.zero
    var _defaultFocusNamespace: Namespace.ID?

    var platformItem: PlatformFocusItem? {
        #if os(macOS)
        _openSwiftUIUnreachableCode()
        #else
        nil
        #endif
    }
    var isEnabled: Bool { true }
    var defaultFocusNamespace: Namespace.ID? { _defaultFocusNamespace }

    #if os(macOS)
    var viewItem: FocusItem.ViewItem? { nil }

    var frame: CGRect? {
        var frame = CGRect(origin: .zero, size: size)
        frame.convert(to: .id(hostingViewCoordinateSpace), transform: transform)
        return frame
    }

    var effectiveLayoutDirection: LayoutDirection? { nil }

    var firstKeyViewInSubtree: NSView? {
        get { nil }
        set { _openSwiftUIEmptyStub() }
    }

    var lastKeyViewInSubtree: NSView? {
        get { nil }
        set { _openSwiftUIEmptyStub() }
    }
    #elseif os(iOS) || os(visionOS)
    // These protocol witnesses are deleted in the target image.
    var viewItem: FocusItem.ViewItem? { _openSwiftUIUnreachableCode() }
    var frame: CGRect? { _openSwiftUIUnreachableCode() }
    var focusGroupID: FocusGroupIdentifier? { _openSwiftUIUnreachableCode() }
    #else
    var viewItem: FocusItem.ViewItem? { _openSwiftUIUnimplementedFailure() }
    var frame: CGRect? { _openSwiftUIUnimplementedFailure() }
    #endif
}

// MARK: - DefaultFocusViewResponderFilter

private struct DefaultFocusViewResponderFilter: StatefulRule, CustomStringConvertible {
    let responder: DefaultFocusViewResponder
    @Attribute var modifier: _DefaultFocusModifier
    @Attribute var transform: ViewTransform
    @Attribute var position: CGPoint
    @Attribute var size: ViewSize
    @Attribute var children: [ViewResponder]

    typealias Value = [ViewResponder]

    var description: String { "DefaultFocusViewResponderFilter" }

    mutating func updateValue() {
        let (modifier, modifierChanged) = $modifier.changedValue()
        let (inputTransform, transformChanged) = $transform.changedValue()
        let (position, positionChanged) = $position.changedValue()
        let (size, sizeChanged) = $size.changedValue()
        guard modifierChanged || transformChanged || positionChanged || sizeChanged || !hasValue else {
            return
        }
        var transform = inputTransform
        transform.appendPosition(position)
        responder.transform = transform
        responder.size = size.value
        responder.prefersDefaultFocus = modifier.prefersDefaultFocus
        responder._defaultFocusNamespace = modifier.defaultFocusNamespace
        responder.updateChildren($children.changedValue())
        value = [responder]
    }
}

// MARK: - FocusNamespaceModifier

struct FocusNamespaceModifier: MultiViewModifier, PrimitiveViewModifier, Equatable {
    var namespace: Namespace.ID

    static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        guard inputs.preferences.requiresViewResponders else {
            return body(_Graph(), inputs)
        }
        var childInputs = inputs
        childInputs.environment = Attribute(ChildEnvironment(
            modifier: modifier.value,
            environment: inputs.environment
        ))
        var outputs = body(_Graph(), childInputs)
        outputs.preferences.viewResponders = Attribute(FocusNamespaceFilter(
            modifier: modifier.value,
            children: outputs.viewResponders(),
            responder: FocusNamespaceViewResponder(inputs: inputs)
        ))
        return outputs
    }

    private struct ChildEnvironment: Rule {
        @Attribute var modifier: FocusNamespaceModifier
        @Attribute var environment: EnvironmentValues

        var value: EnvironmentValues {
            var environment = environment
            environment[FocusScopesKey.self].append(modifier.namespace)
            return environment
        }
    }
}

// MARK: - FocusNamespaceViewResponder

class FocusNamespaceViewResponder: DefaultLayoutViewResponder {
    var namespace: Namespace.ID?
}

// MARK: - FocusNamespaceFilter

private struct FocusNamespaceFilter: StatefulRule {
    @Attribute var modifier: FocusNamespaceModifier
    @Attribute var children: [ViewResponder]
    let responder: FocusNamespaceViewResponder

    typealias Value = [ViewResponder]

    mutating func updateValue() {
        responder.namespace = modifier.namespace
        responder.updateChildren($children.changedValue())
        if !hasValue {
            value = [responder]
        }
    }
}

// MARK: - FocusScopesKey

struct FocusScopesKey: EnvironmentKey {
    static var defaultValue: [Namespace.ID] { [] }
}

extension CachedEnvironment.ID {
    fileprivate static let focusScopes: CachedEnvironment.ID = .init()
}

extension _GraphInputs {
    var focusScopes: Attribute<[Namespace.ID]> {
        mapEnvironment(id: .focusScopes) { $0[FocusScopesKey.self] }
    }
}

// MARK: - _FocusSystem

/// Provides functionality for manipulation of the currently focused view.
@available(OpenSwiftUI_v2_0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(visionOS, unavailable)
public struct _FocusSystem {
    var onResetToDefault: (() -> Void)?

    /// Asks the focus system to re-evaluate default focus and move focus
    /// to that item, if necessary.
    @available(macOS, deprecated, message: "Prototype SPI, do not use.")
    public func resetToDefault() {
        onResetToDefault?()
    }
}

@available(*, unavailable)
extension _FocusSystem: Sendable {}

// MARK: - ResetFocusAction

/// An environment value that provides the ability to reevaluate default
/// focus.
///
/// Get the ``EnvironmentValues/resetFocus`` environment value and call it as a
/// function to force a default focus reevaluation at runtime.
///
///     @Namespace var mainNamespace
///     @Environment(\.resetFocus) var resetFocus
///
///     var body: some View {
///         // ...
///         resetFocus(in: mainNamespace)
///         // ...
///     }
///
@available(OpenSwiftUI_v2_0, *)
@available(OpenSwiftUI_macOS_v3_0, *)
@available(iOS, unavailable)
@available(visionOS, unavailable)
public struct ResetFocusAction {
    weak var bridge: FocusBridge?

    /// Asks the focus system to reevaluate the default focus item.
    ///
    /// The focus system reevaluates default focus when the currently-focused
    /// item is within the provided namespace.
    ///
    /// - Parameter namespace: The namespace inside which OpenSwiftUI should
    ///   reevaluate default focus. The namespace should match the
    ///   ``View/focusScope(_:)`` block where focus requires reevaluation.
    public func callAsFunction(in namespace: Namespace.ID) {
        #if os(macOS)
        bridge?.resetFocus(in: namespace)
        #else
        _openSwiftUIUnreachableCode()
        #endif
    }
}

@available(*, unavailable)
extension ResetFocusAction: Sendable {}

@available(OpenSwiftUI_v2_0, *)
@available(OpenSwiftUI_macOS_v3_0, *)
@available(iOS, unavailable)
@available(visionOS, unavailable)
extension EnvironmentValues {
    /// An action that requests the focus system to reevaluate default focus.
    ///
    /// Get this environment value and call it as a function to force
    /// a default focus reevaluation at runtime.
    ///
    ///     @Namespace var mainNamespace
    ///     @Environment(\.resetFocus) var resetFocus
    ///
    ///     var body: some View {
    ///         // ...
    ///         resetFocus(in: mainNamespace)
    ///         // ...
    ///     }
    ///
    public var resetFocus: ResetFocusAction {
        ResetFocusAction(bridge: self[ResetFocusKey.self].bridge)
    }
}

// MARK: - _ResetFocusAction

@_spi(Private)
@available(OpenSwiftUI_v2_0, *)
@available(OpenSwiftUI_iOS_v4_0, *)
@available(OpenSwiftUI_macOS_v3_0, *)
public struct _ResetFocusAction {
    weak var bridge: FocusBridge?

    public func callAsFunction(in namespace: Namespace.ID) {
        #if os(macOS)
        bridge?.resetFocus(in: namespace)
        #elseif os(iOS) || os(visionOS)
        guard let bridge,
              let host = bridge.host,
              let responder = bridge.focusedItem?.responder else {
            return
        }
        for node in responder.sequence {
            guard let node = node as? FocusNamespaceViewResponder,
                  let nodeNamespace = node.namespace,
                  nodeNamespace == namespace else {
                continue
            }
            bridge.defaultFocusNamespace = namespace
            host.setNeedsFocusUpdate()
            return
        }
        #else
        _openSwiftUIUnimplementedFailure()
        #endif
    }
}

@_spi(Private)
@available(*, unavailable)
extension _ResetFocusAction: Sendable {}

@_spi(Private)
@available(OpenSwiftUI_v2_0, *)
@available(OpenSwiftUI_iOS_v4_0, *)
@available(OpenSwiftUI_macOS_v3_0, *)
extension EnvironmentValues {
    public var _resetFocus: _ResetFocusAction {
        self[ResetFocusKey.self]
    }
}

@available(OpenSwiftUI_macOS_v2_0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension EnvironmentValues {
    public var _focusSystem: _FocusSystem {
        get { self[FocusSystemKey.self] }
        set { self[FocusSystemKey.self] = newValue }
    }
}

// MARK: - ResetFocusKey

struct ResetFocusKey: EnvironmentKey {
    static let defaultValue = _ResetFocusAction(bridge: nil)
}

// MARK: - FocusSystemKey

@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(visionOS, unavailable)
private struct FocusSystemKey: EnvironmentKey {
    static var defaultValue: _FocusSystem { .init(onResetToDefault: nil) }
}
