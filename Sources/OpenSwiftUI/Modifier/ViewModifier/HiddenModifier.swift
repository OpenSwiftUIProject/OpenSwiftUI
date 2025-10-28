//
//  HiddenModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 8D63435B81E83062F98F8C50416D392F (SwiftUI)

public import OpenSwiftUICore
package import OpenAttributeGraphShims

// MARK: - _HiddenModifier

/// A view that creates and manages a child content view, but does not
/// allow that content to be displayed or to respond to events. This is
/// typically used to allow preference values to be read from views
/// whose content is not needed.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _HiddenModifier: ViewModifier, MultiViewModifier, PrimitiveViewModifier {
    @inlinable
    public init() {}

    nonisolated public static func _makeView(
        modifier: _GraphValue<_HiddenModifier>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        makeHiddenView(
            allowedKeys: [.hostPreferences],
            inputs: inputs,
            body: body
        )
    }
}

// MARK: - AllowedPreferenceKeysWhileHidden

package struct AllowedPreferenceKeysWhileHidden: OptionSet {
    package let rawValue: Int

    package init(rawValue: Int) {
        self.rawValue = rawValue
    }

    package static let accessibility: AllowedPreferenceKeysWhileHidden = .init(rawValue: 1 << 0)

    package static let platformItemList: AllowedPreferenceKeysWhileHidden = .init(rawValue: 1 << 1)

    package static let viewResponders: AllowedPreferenceKeysWhileHidden = .init(rawValue: 1 << 2)

    package static let hostPreferences: AllowedPreferenceKeysWhileHidden = .init(rawValue: 1 << 3)

    package static let displayList: AllowedPreferenceKeysWhileHidden = .init(rawValue: 1 << 4)
}

extension PreferenceKeys {
    fileprivate mutating func removeHiddenKeys(allowing allowedKeys: AllowedPreferenceKeysWhileHidden) {
        if !allowedKeys.contains(.displayList) {
            remove(DisplayList.Key.self)
        }
        if !allowedKeys.contains(.viewResponders) {
            remove(ViewRespondersKey.self)
        }
        if !allowedKeys.contains(.accessibility) {
            remove(AccessibilityNodesKey.self)
        }
        if !allowedKeys.contains(.hostPreferences) {
            remove(HostPreferencesKey.self)
        }
    }
}

// MARK: - DynamicHiddenModifier

package struct DynamicHiddenModifier: ViewModifier, PrimitiveViewModifier, MultiViewModifier {
    var isHidden: Bool

    var allowedKeys: AllowedPreferenceKeysWhileHidden

    nonisolated package static func _makeView(
        modifier: _GraphValue<DynamicHiddenModifier>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = body(_Graph(), inputs)
        outputs.preferences.makePreferenceTransformer(
            inputs: inputs.preferences,
            key: DisplayList.Key.self,
            transform: Attribute(DynamicTransform<DisplayList.Key>(modifier: modifier.value))
        )
        outputs.preferences.makePreferenceTransformer(
            inputs: inputs.preferences,
            key: ViewRespondersKey.self,
            transform: Attribute(DynamicTransform<ViewRespondersKey>(modifier: modifier.value))
        )
        outputs.preferences.makePreferenceTransformer(
            inputs: inputs.preferences,
            key: AccessibilityNodesKey.self,
            transform: Attribute(DynamicTransform<AccessibilityNodesKey>(modifier: modifier.value))
        )
        outputs.preferences.makePreferenceTransformer(
            inputs: inputs.preferences,
            key: HostPreferencesKey.self,
            transform: Attribute(DynamicTransform<HostPreferencesKey>(modifier: modifier.value))
        )
        if let representation = inputs.requestedDynamicHiddenRepresentation,
           representation.shouldMakeRepresentation(inputs: inputs) {
            representation
                .makeRepresentation(
                    inputs: inputs,
                    modifier: modifier.value,
                    outputs: &outputs
                )
        }
        return outputs
    }

    struct DynamicTransform<Key>: Rule where Key: PreferenceKey {
        @Attribute var modifier: DynamicHiddenModifier

        var value: (inout Key.Value) -> () {
            { value in
                guard modifier.isHidden else {
                    return
                }
                guard !includeKey else {
                    return
                }
                value = Key.defaultValue
            }
        }

        var includeKey: Bool {
            let allowedKeys = modifier.allowedKeys
            if DisplayList.Key.self == Key.self {
                return allowedKeys.contains(.displayList)
            } else if ViewRespondersKey.self == Key.self {
                return allowedKeys.contains(.viewResponders)
            } else if AccessibilityNodesKey.self == Key.self {
                return allowedKeys.contains(.accessibility)
            } else if HostPreferencesKey.self == Key.self {
                return allowedKeys.contains(.hostPreferences)
            } else {
                return false
            }
        }
    }
}

// MARK: - HiddenModifierAllowingAccessibility

struct HiddenModifierAllowingAccessibility: ViewModifier, PrimitiveViewModifier, MultiViewModifier {
    nonisolated public static func _makeView(
        modifier: _GraphValue<_HiddenModifier>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        makeHiddenView(
            allowedKeys: [.accessibility, .hostPreferences],
            inputs: inputs,
            body: body
        )
    }
}

// MARK: - HiddenModifierAllowingPlatformItemList

struct HiddenModifierAllowingPlatformItemList: ViewModifier, MultiViewModifier, PrimitiveViewModifier {
    nonisolated public static func _makeView(
        modifier: _GraphValue<_HiddenModifier>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        makeHiddenView(
            allowedKeys: [.accessibility, .platformItemList],
            inputs: inputs,
            body: body
        )
    }
}

// MARK: - HiddenModifierAllowingViewResponders

struct HiddenModifierAllowingViewResponders: ViewModifier, MultiViewModifier, PrimitiveViewModifier {
    nonisolated public static func _makeView(
        modifier: _GraphValue<_HiddenModifier>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        makeHiddenView(
            allowedKeys: [.viewResponders],
            inputs: inputs,
            body: body
        )
    }
}

// MARK: - makeHiddenView

private func makeHiddenView(
    allowedKeys: AllowedPreferenceKeysWhileHidden,
    inputs: _ViewInputs,
    body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
) -> _ViewOutputs {
    struct HostKeys: Rule {
        @Attribute var hostKeys: PreferenceKeys
        let allowedKeys: AllowedPreferenceKeysWhileHidden

        var value: PreferenceKeys {
            var hostKeys = hostKeys
            hostKeys.removeHiddenKeys(allowing: allowedKeys)
            return hostKeys
        }
    }
    var inputs = inputs
    inputs.preferences.keys.removeHiddenKeys(allowing: allowedKeys)
    inputs.preferences.hostKeys = Attribute(
        HostKeys(
            hostKeys: inputs.preferences.hostKeys,
            allowedKeys: allowedKeys
        )
    )
    if let representation = inputs.requestedHiddenRepresentation {
        representation.makeRepresentation(inputs: &inputs, allowedKeys: allowedKeys)
    }
    return body(_Graph(), inputs)
}

// MARK: - View + hidden

@available(OpenSwiftUI_v1_0, *)
extension View {

    /// Hides this view unconditionally.
    ///
    /// Hidden views are invisible and can't receive or respond to interactions.
    /// However, they do remain in the view hierarchy and affect layout. Use
    /// this modifier if you want to include a view for layout purposes, but
    /// don't want it to display.
    ///
    ///     HStack {
    ///         Image(systemName: "a.circle.fill")
    ///         Image(systemName: "b.circle.fill")
    ///         Image(systemName: "c.circle.fill")
    ///             .hidden()
    ///         Image(systemName: "d.circle.fill")
    ///     }
    ///
    /// The third circle takes up space, because it's still present, but
    /// OpenSwiftUI doesn't draw it onscreen.
    ///
    /// ![A row of circles with the letters A, B, and D, with a gap where
    ///   the circle with the letter C should be.](OpenSwiftUI-View-hidden-1.png)
    ///
    /// If you want to conditionally include a view in the view hierarchy, use
    /// an `if` statement instead:
    ///
    ///     VStack {
    ///         HStack {
    ///             Image(systemName: "a.circle.fill")
    ///             Image(systemName: "b.circle.fill")
    ///             if !isHidden {
    ///                 Image(systemName: "c.circle.fill")
    ///             }
    ///             Image(systemName: "d.circle.fill")
    ///         }
    ///         Toggle("Hide", isOn: $isHidden)
    ///     }
    ///
    /// Depending on the current value of the `isHidden` state variable in the
    /// example above, controlled by the ``Toggle`` instance, OpenSwiftUI draws
    /// the circle or completely omits it from the layout.
    ///
    /// ![Two side by side groups of items, each composed of a toggle beneath
    ///   a row of circles with letters in them. The toggle on the left
    ///   is off and has four equally spaced circles above it: A, B, C, and D.
    ///   The toggle on the right is on and has three equally spaced circles
    ///   above it: A, B, and D.](OpenSwiftUI-View-hidden-2.png)
    ///
    /// - Returns: A hidden view.
    @inlinable
    nonisolated public func hidden() -> some View {
        modifier(_HiddenModifier())
    }

    package func hiddenAllowingPlatformItemList() -> some View {
        modifier(HiddenModifierAllowingPlatformItemList())
    }

    package func hiddenAllowingAccessibility() -> some View {
        modifier(HiddenModifierAllowingAccessibility())
    }

    package func hiddenAllowingViewResponders() -> some View {
        modifier(HiddenModifierAllowingViewResponders())
    }

    package func hidden(_ isHidden: Bool, allowingDisplayList: Bool = false) -> some View {
        modifier(
            DynamicHiddenModifier(
                isHidden: isHidden,
                allowedKeys: allowingDisplayList ? .displayList : []
            )
        )
    }

    package func hiddenAllowingHostPreferences(_ isHidden: Bool, allowingDisplayList: Bool = false) -> some View {
        modifier(
            DynamicHiddenModifier(
                isHidden: isHidden,
                allowedKeys: allowingDisplayList ? [.displayList, .hostPreferences] : [.hostPreferences]
            )
        )
    }
}

// MARK: - PlatformHiddenRepresentable

package protocol PlatformHiddenRepresentable {
    static func makeRepresentation(
        inputs: inout _ViewInputs,
        allowedKeys: AllowedPreferenceKeysWhileHidden
    )
}

extension _ViewInputs {
    package var requestedHiddenRepresentation: (any PlatformHiddenRepresentable.Type)? {
        get { base.requestedHiddenRepresentation }
        set { base.requestedHiddenRepresentation = newValue }
    }
}

extension _GraphInputs {
    private struct HiddenRepresentationKey: GraphInput {
        static let defaultValue: (any PlatformHiddenRepresentable.Type)? = nil
    }

    package var requestedHiddenRepresentation: (any PlatformHiddenRepresentable.Type)? {
        get { self[HiddenRepresentationKey.self] }
        set { self[HiddenRepresentationKey.self] = newValue }
    }
}

// MARK: - PlatformDynamicHiddenRepresentable

package protocol PlatformDynamicHiddenRepresentable {
    static func shouldMakeRepresentation(
        inputs: _ViewInputs
    ) -> Bool

    static func makeRepresentation(
        inputs: _ViewInputs,
        modifier: Attribute<DynamicHiddenModifier>,
        outputs: inout _ViewOutputs
    )
}

extension _ViewInputs {
    package var requestedDynamicHiddenRepresentation: (any PlatformDynamicHiddenRepresentable.Type)? {
        get { base.requestedDynamicHiddenRepresentation }
        set { base.requestedDynamicHiddenRepresentation = newValue }
    }
}

extension _GraphInputs {
    private struct DynamicHiddenRepresentationKey: GraphInput {
        static let defaultValue: (any PlatformDynamicHiddenRepresentable.Type)? = nil
    }

    package var requestedDynamicHiddenRepresentation: (any PlatformDynamicHiddenRepresentable.Type)? {
        get { self[DynamicHiddenRepresentationKey.self] }
        set { self[DynamicHiddenRepresentationKey.self] = newValue }
    }
}
