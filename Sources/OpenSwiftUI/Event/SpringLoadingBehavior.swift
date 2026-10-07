//
//  SpringLoadingBehavior.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 0A62C33CA897E979E415FFCD1544224A (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
public import OpenSwiftUICore

// MARK: - SpringLoadingBehavior

/// The options for controlling the spring loading behavior of views.
///
/// Use values of this type with the ``View/springLoadingBehavior(_:)``
/// modifier.
@available(OpenSwiftUI_v5_0, *)
public struct SpringLoadingBehavior: Hashable, Sendable {
    enum Guts: Hashable, Sendable {
        case automatic
        case enabled
        case disabled
    }

    var guts: Guts

    /// The automatic spring loading behavior.
    ///
    /// This defers to default component behavior for spring loading.
    /// Some components, such as `TabView`, will default to allowing spring
    /// loading; while others do not.
    public static let automatic = SpringLoadingBehavior(guts: .automatic)

    /// Spring loaded interactions will be enabled for applicable views.
    public static let enabled = SpringLoadingBehavior(guts: .enabled)

    /// Spring loaded interactions will be disabled for applicable views.
    public static let disabled = SpringLoadingBehavior(guts: .disabled)

    struct Key: EnvironmentKey {
        static var defaultValue: SpringLoadingBehavior { .automatic }
    }

    struct HasCustomSpringLoadedBehavior: ViewInputBoolFlag {}
}

// MARK: - View + SpringLoadingBehavior

@available(OpenSwiftUI_v5_0, *)
extension View {
    /// Sets the spring loading behavior this view.
    ///
    /// Spring loading refers to a view being activated during a drag and drop
    /// interaction. On iOS this can occur when pausing briefly on top of a
    /// view with dragged content. On macOS this can occur with similar brief
    /// pauses or on pressure-sensitive systems by "force clicking" during the
    /// drag. This has no effect on tvOS or watchOS.
    ///
    /// This is commonly used with views that have a navigation or presentation
    /// effect, allowing the destination to be revealed without pausing the
    /// drag interaction. For example, a button that reveals a list of folders
    /// that a dragged item can be dropped onto.
    ///
    ///     Button {
    ///         showFolders = true
    ///     } label: {
    ///         Label("Show Folders", systemImage: "folder")
    ///     }
    ///     .springLoadingBehavior(.enabled)
    ///
    /// Unlike `disabled(_:)`, this modifier overrides the value set by an
    /// ancestor view rather than being unioned with it. For example, the below
    /// button would allow spring loading:
    ///
    ///     HStack {
    ///         Button {
    ///             showFolders = true
    ///         } label: {
    ///             Label("Show Folders", systemImage: "folder")
    ///         }
    ///         .springLoadingBehavior(.enabled)
    ///
    ///         ...
    ///     }
    ///     .springLoadingBehavior(.disabled)
    ///
    /// - Parameter behavior: Whether spring loading is enabled or not. If
    ///   unspecified, the default behavior is `.automatic.`
    nonisolated public func springLoadingBehavior(_ behavior: SpringLoadingBehavior) -> some View {
        environment(\.springLoadingBehavior, behavior)
            .input(SpringLoadingBehavior.HasCustomSpringLoadedBehavior.self)
    }
}

// MARK: - EnvironmentValues + SpringLoadingBehavior

@available(OpenSwiftUI_v5_0, *)
extension EnvironmentValues {
    /// The behavior of spring loaded interactions for the views associated
    /// with this environment.
    ///
    /// Spring loading refers to a view being activated during a drag and drop
    /// interaction. On iOS this can occur when pausing briefly on top of a
    /// view with dragged content. On macOS this can occur with similar brief
    /// pauses or on pressure-sensitive systems by "force clicking" during the
    /// drag. This has no effect on tvOS or watchOS.
    ///
    /// This is commonly used with views that have a navigation or presentation
    /// effect, allowing the destination to be revealed without pausing the
    /// drag interaction. For example, a button that reveals a list of folders
    /// that a dragged item can be dropped onto.
    ///
    /// A value of `enabled` means that a view should support spring loaded
    /// interactions if it is able, and `disabled` means it should not.
    /// A value of `automatic` means that a view should follow its default
    /// behavior, such as a `TabView` automatically allowing spring loading,
    /// but a `Picker` with `segmented` style would not.
    public var springLoadingBehavior: SpringLoadingBehavior {
        get { self[SpringLoadingBehavior.Key.self] }
        @_spi(DoNotImport) set { self[SpringLoadingBehavior.Key.self] = newValue }
    }
}

// MARK: - View + springLoaded

@available(OpenSwiftUI_v5_0, *)
extension View {
    @_spi(UIFrameworks)
    nonisolated public func springLoaded(
        automaticallyEnabled: Bool = true,
        onActivate: @escaping () -> Void,
        onHighlightChange: @escaping (SpringLoadingBehavior.HighlightState) -> Void = { _ in },
        onEnded: @escaping () -> Void = {}
    ) -> some View {
        modifier(SpringLoadingInteractionModifier(
            automaticallyEnabled: automaticallyEnabled,
            onActivate: onActivate,
            onHighlightChange: onHighlightChange,
            onEnded: onEnded
        ))
    }
}

// MARK: - SpringLoadingBehavior.HighlightState

@available(OpenSwiftUI_v5_0, *)
extension SpringLoadingBehavior {
    @_spi(UIFrameworks)
    public enum HighlightState: Hashable, Sendable {
        case none
        case standard
        case prominent
    }
}

// MARK: - SpringLoadedViewResponder

class SpringLoadedViewResponder: DefaultLayoutViewResponder {
    var isEnabled: Bool = false
    var onActivate: () -> Void = {}
    var onHighlightChange: (SpringLoadingBehavior.HighlightState) -> Void = { _ in }
    var onEnded: () -> Void = {}

    override func extendPrintTree(string: inout String) {
        string.append("springLoaded")
    }
}

// MARK: - SpringLoadingInteractionModifier

struct SpringLoadingInteractionModifier: MultiViewModifier, PrimitiveViewModifier {
    var automaticallyEnabled: Bool
    var onActivate: () -> Void
    var onHighlightChange: (SpringLoadingBehavior.HighlightState) -> Void
    var onEnded: () -> Void

    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = body(_Graph(), inputs)
        if inputs.preferences.requiresViewResponders {
            outputs.preferences.viewResponders = Attribute(SpringLoadedResponderFilter(
                modifier: modifier.value,
                behavior: inputs.base.springLoadingBehavior,
                isEnabled: inputs.isEnabled,
                children: outputs.viewResponders(),
                responder: SpringLoadedViewResponder(inputs: inputs)
            ))
            outputs.preferences.makePreferenceWriter(
                inputs: inputs.preferences,
                key: CanSpringLoadKey.self,
                value: inputs.intern(true, id: .trueValue)
            )
        }
        return outputs
    }
}

// MARK: - SpringLoadedResponderFilter

private struct SpringLoadedResponderFilter: StatefulRule {
    @Attribute var modifier: SpringLoadingInteractionModifier
    @Attribute var behavior: SpringLoadingBehavior
    @Attribute var isEnabled: Bool
    @Attribute var children: [ViewResponder]
    let responder: SpringLoadedViewResponder

    typealias Value = [ViewResponder]

    func updateValue() {
        if isEnabled {
            responder.isEnabled = switch behavior.guts {
            case .automatic: modifier.automaticallyEnabled
            case .enabled: true
            case .disabled: false
            }
        } else {
            responder.isEnabled = false
        }
        responder.onActivate = modifier.onActivate
        responder.onHighlightChange = modifier.onHighlightChange
        responder.onEnded = modifier.onEnded
        responder.updateChildren($children.changedValue())
        if !hasValue {
            value = [responder]
        }
    }
}

// MARK: - CanSpringLoadKey

struct CanSpringLoadKey: HostPreferenceKey {
    static var defaultValue: Bool { false }

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

// MARK: - CachedEnvironment.ID + springLoadingBehavior

extension CachedEnvironment.ID {
    fileprivate static let springLoadingBehavior: CachedEnvironment.ID = .init()
}

// MARK: - _GraphInputs + springLoadingBehavior

extension _GraphInputs {
    var springLoadingBehavior: Attribute<SpringLoadingBehavior> {
        mapEnvironment(id: .springLoadingBehavior) { $0.springLoadingBehavior }
    }
}
