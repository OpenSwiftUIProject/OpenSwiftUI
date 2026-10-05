//
//  AccessibilityActionKind.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore
import OpenSwiftUI_SPI

// MARK: - AccessibilityActionKind

/// The structure that defines the kinds of available accessibility actions.
///
@available(OpenSwiftUI_v1_0, *)
public struct AccessibilityActionKind: Equatable, Sendable {
    enum ActionKind: Equatable, Sendable {
        case custom(Text)
        case `default`
        case escape
        case magicTap
        case delete
        case showMenu
    }

    let kind: ActionKind

    /// The value that represents the default accessibility action.
    public static let `default` = AccessibilityActionKind(kind: .default)

    /// The value that represents an accessibility action that dismisses a
    /// modal view or cancels an operation.
    public static let escape = AccessibilityActionKind(kind: .escape)

    @available(macOS, unavailable)
    public static let magicTap = AccessibilityActionKind(kind: .magicTap)

    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @available(visionOS, unavailable)
    public static let delete = AccessibilityActionKind(kind: .delete)

    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @available(visionOS, unavailable)
    public static let showMenu = AccessibilityActionKind(kind: .showMenu)

    init(kind: ActionKind) {
        self.kind = kind
    }

    /// Creates a custom accessibility action kind with the specified name.
    ///
    /// - Parameter name: The text that describes the action.
    public init(named name: Text) {
        self.init(kind: .custom(name))
    }
}

// MARK: - View + AccessibilityActionKind

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Adds an accessibility action to the view. Actions allow assistive technologies,
    /// such as the VoiceOver, to interact with the view by invoking the action.
    ///
    /// For example, this is how a `.default` action to compose
    /// a new email could be added to a view.
    ///
    ///     var body: some View {
    ///         ContentView()
    ///             .accessibilityAction {
    ///                 // Handle action
    ///             }
    ///     }
    ///
    nonisolated public func accessibilityAction(
        _ actionKind: AccessibilityActionKind = .default,
        _ handler: @escaping () -> Void
    ) -> ModifiedContent<Self, AccessibilityAttachmentModifier> {
        accessibilityAction(AccessibilityVoidAction(kind: actionKind)) { _ in
            handler()
        }
    }

    /// Adds an accessibility action to the view. Actions allow assistive technologies,
    /// such as the VoiceOver, to interact with the view by invoking the action.
    ///
    /// For example, this is how a custom action to compose
    /// a new email could be added to a view.
    ///
    ///     var body: some View {
    ///         ContentView()
    ///             .accessibilityAction(named: Text("New Message")) {
    ///                 // Handle action
    ///             }
    ///     }
    ///
    nonisolated public func accessibilityAction(
        named name: Text,
        _ handler: @escaping () -> Void
    ) -> ModifiedContent<Self, AccessibilityAttachmentModifier> {
        accessibilityAction(AccessibilityVoidAction(kind: .init(named: name))) { _ in
            handler()
        }
    }
}

@available(OpenSwiftUI_v1_0, *)
extension ModifiedContent where Modifier == AccessibilityAttachmentModifier {
    /// Adds an accessibility action to the view. Actions allow assistive technologies,
    /// such as the VoiceOver, to interact with the view by invoking the action.
    ///
    /// For example, this is how a `.default` action to compose
    /// a new email could be added to a view.
    ///
    ///     var body: some View {
    ///         ContentView()
    ///             .accessibilityAction {
    ///                 // Handle action
    ///             }
    ///     }
    ///
    nonisolated public func accessibilityAction(
        _ actionKind: AccessibilityActionKind = .default,
        _ handler: @escaping () -> Void
    ) -> ModifiedContent<Content, Modifier> {
        accessibilityAction(AccessibilityVoidAction(kind: actionKind)) { _ in
            handler()
        }
    }

    /// Adds an accessibility action to the view. Actions allow assistive technologies,
    /// such as the VoiceOver, to interact with the view by invoking the action.
    ///
    /// For example, this is how a custom action to compose
    /// a new email could be added to a view.
    ///
    ///     var body: some View {
    ///         ContentView()
    ///             .accessibilityAction(named: Text("New Message")) {
    ///                 // Handle action
    ///             }
    ///     }
    ///
    nonisolated public func accessibilityAction(
        named name: Text,
        _ handler: @escaping () -> Void
    ) -> ModifiedContent<Content, Modifier> {
        accessibilityAction(AccessibilityVoidAction(kind: .init(named: name))) { _ in
            handler()
        }
    }
}

@available(OpenSwiftUI_v3_0, *)
extension View {
    /// Adds an accessibility action to the view. Actions allow assistive technologies,
    /// such as the VoiceOver, to interact with the view by invoking the action.
    ///
    /// For example, this is how a custom action to compose
    /// a new email could be added to a view.
    ///
    ///     var body: some View {
    ///         ContentView()
    ///             .accessibilityAction {
    ///                 // Handle action
    ///             } label: {
    ///                 Label("New Message", systemImage: "plus")
    ///             }
    ///     }
    ///
    nonisolated public func accessibilityAction<Label>(
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) -> some View where Label: View {
        accessibilityAction(nil, action: action, label: label)
    }
}

@available(OpenSwiftUI_v4_0, *)
extension View {
    /// Adds multiple accessibility actions to the view.
    ///
    /// Actions allow assistive technologies,
    /// such as the VoiceOver, to interact with the view by invoking the action.
    /// For example, this is how a dynamic number of custom action could
    /// be added to a view.
    ///
    ///     var isDraft: Bool
    ///
    ///     var body: some View {
    ///         ContentView()
    ///             .accessibilityActions {
    ///                 ForEach(actions) { action in
    ///                     Button {
    ///                         action()
    ///                     } label: {
    ///                         Text(action.title)
    ///                     }
    ///                 }
    ///
    ///                 if isDraft {
    ///                     Button {
    ///                         // Handle Delete
    ///                     } label: {
    ///                         Text("Delete")
    ///                     }
    ///                 }
    ///             }
    ///
    nonisolated public func accessibilityActions<Content>(
        @ViewBuilder _ content: () -> Content
    ) -> some View where Content: View {
        accessibilityAttachment(content: content()) { tree in
            var attachment = AccessibilityAttachment()
            if let properties = tree.attachment?.mergedProperties {
                attachment.properties.actions = properties.actions.map {
                    $0.asCustomAction(category: nil) ?? $0
                }
            }
            tree = .leaf(attachment)
        }
    }
}

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
extension View {
    nonisolated public func accessibilityActions<Content>(
        _ category: Text,
        @ViewBuilder content: () -> Content
    ) -> some View where Content: View {
        accessibilityAttachment(content: content()) { tree in
            var attachment = AccessibilityAttachment()
            if let properties = tree.attachment?.mergedProperties {
                attachment.properties.actions = properties.actions.map {
                    $0.asCustomAction(category: AccessibilityActionCategory(category)) ?? $0
                }
            }
            tree = .leaf(attachment)
        }
    }

    nonisolated public func accessibilityActions<Content>(
        _ category: LocalizedStringKey,
        @ViewBuilder content: () -> Content
    ) -> some View where Content: View {
        accessibilityActions(Text(category), content: content)
    }

    nonisolated public func accessibilityActions<Content, S>(
        _ category: S,
        @ViewBuilder content: () -> Content
    ) -> some View where Content: View, S: StringProtocol {
        accessibilityActions(Text(category), content: content)
    }
}

@available(OpenSwiftUI_v2_0, *)
extension View {
    /// Adds an accessibility action to the view. Actions allow assistive technologies,
    /// such as the VoiceOver, to interact with the view by invoking the action.
    ///
    /// For example, this is how a custom action to compose
    /// a new email could be added to a view.
    ///
    ///     var body: some View {
    ///         ContentView()
    ///             .accessibilityAction(named: "New Message") {
    ///                 // Handle action
    ///             }
    ///     }
    ///
    nonisolated public func accessibilityAction(
        named nameKey: LocalizedStringKey,
        _ handler: @escaping () -> Void
    ) -> ModifiedContent<Self, AccessibilityAttachmentModifier> {
        accessibilityAction(named: Text(nameKey), handler)
    }

    /// Adds an accessibility action to the view. Actions allow assistive technologies,
    /// such as the VoiceOver, to interact with the view by invoking the action.
    ///
    /// For example, this is how a custom action to compose
    /// a new email could be added to a view.
    ///
    ///     var body: some View {
    ///         ContentView()
    ///             .accessibilityAction(named: "New Message") {
    ///                 // Handle action
    ///             }
    ///     }
    ///
    @_disfavoredOverload
    nonisolated public func accessibilityAction<S>(
        named name: S,
        _ handler: @escaping () -> Void
    ) -> ModifiedContent<Self, AccessibilityAttachmentModifier> where S: StringProtocol {
        accessibilityAction(named: Text(name), handler)
    }
}

@available(OpenSwiftUI_v2_0, *)
extension ModifiedContent where Modifier == AccessibilityAttachmentModifier {
    /// Adds an accessibility action to the view. Actions allow assistive technologies,
    /// such as the VoiceOver, to interact with the view by invoking the action.
    ///
    /// For example, this is how a custom action to compose
    /// a new email could be added to a view.
    ///
    ///     var body: some View {
    ///         ContentView()
    ///             .accessibilityAction(named: "New Message") {
    ///                 // Handle action
    ///             }
    ///     }
    ///
    nonisolated public func accessibilityAction(
        named nameKey: LocalizedStringKey,
        _ handler: @escaping () -> Void
    ) -> ModifiedContent<Content, Modifier> {
        accessibilityAction(named: Text(nameKey), handler)
    }

    /// Adds an accessibility action to the view. Actions allow assistive technologies,
    /// such as the VoiceOver, to interact with the view by invoking the action.
    ///
    /// For example, this is how a custom action to compose
    /// a new email could be added to a view.
    ///
    ///     var body: some View {
    ///         ContentView()
    ///             .accessibilityAction(named: "New Message") {
    ///                 // Handle action
    ///             }
    ///     }
    ///
    @_disfavoredOverload
    nonisolated public func accessibilityAction<S>(
        named name: S,
        _ handler: @escaping () -> Void
    ) -> ModifiedContent<Content, Modifier> where S: StringProtocol {
        accessibilityAction(named: Text(name), handler)
    }
}

@available(OpenSwiftUI_v5_0, *)
extension View {
    @_spi(Private)
    @_disfavoredOverload
    nonisolated public func accessibilityAction(
        kind: AccessibilityActionKind = .default,
        _ handler: @escaping () -> AccessibilityActionResult
    ) -> ModifiedContent<Self, AccessibilityAttachmentModifier> {
        accessibilityAction(AccessibilityVoidAction(kind: kind)) { _ in
            handler()
        }
    }
}

@available(OpenSwiftUI_v5_0, *)
extension ModifiedContent where Modifier == AccessibilityAttachmentModifier {
    @_spi(Private)
    @_disfavoredOverload
    nonisolated public func accessibilityAction(
        kind: AccessibilityActionKind = .default,
        _ handler: @escaping () -> AccessibilityActionResult
    ) -> ModifiedContent<Content, Modifier> {
        accessibilityAction(AccessibilityVoidAction(kind: kind)) { _ in
            handler()
        }
    }
}

// MARK: - AccessibilityVoidAction

struct AccessibilityVoidAction: AccessibilityAction, AccessibilityKindActionProvider {
    typealias Value = Void

    let kind: AccessibilityActionKind

    func impliedRole(for traits: AccessibilityTraitStorage) -> AccessibilityRole? {
        guard kind == .default,
              !traits.isSet(.isButton), !traits[.isButton, default: false],
              !traits.isSet(.isRadioButton), !traits[.isRadioButton, default: false],
              !traits.isSet(.isLink), !traits[.isLink, default: false],
              !traits.isSet(.isHeader), !traits[.isHeader, default: false] else {
            return nil
        }
        #if os(macOS)
        return AccessibilityRole(resolved: .init(
            role: .button,
            subrole: nil,
            traits: .button
        ))
        #else
        return AccessibilityRole(resolved: .init(
            traits: .button,
            automationType: .button
        ))
        #endif
    }
}

// MARK: - Accessibility action attachment

extension View {
    nonisolated func accessibilityAction<Action>(
        _ action: Action,
        label: Text? = nil,
        image: Image? = nil,
        _ handler: @escaping (Action.Value) -> Void
    ) -> ModifiedContent<Self, AccessibilityAttachmentModifier> where Action: AccessibilityAction {
        accessibilityAction(action, label: label, image: image) { value in
            handler(value)
            return .success
        }
    }

    nonisolated func accessibilityAction<Action>(
        _ action: Action,
        label: Text? = nil,
        image: Image? = nil,
        _ handler: @escaping (Action.Value) -> AccessibilityActionResult
    ) -> ModifiedContent<Self, AccessibilityAttachmentModifier> where Action: AccessibilityAction {
        accessibility(AccessibilityProperties.ActionsKey.self, [
            AnyAccessibilityAction(action: action, label: label, image: image, handler: handler, bridged: false)
        ])
    }

    nonisolated func accessibilityAction<Label>(
        _ kind: AccessibilityActionKind?,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) -> some View where Label: View {
        accessibilityAttachment(content: label()) { tree in
            let properties = tree.attachment?.mergedProperties
            let accessibilityAction: AnyAccessibilityAction?
            if let kind {
                accessibilityAction = AnyAccessibilityAction(
                    action: AccessibilityVoidAction(kind: kind),
                    label: properties?.labelStorage?.texts.first,
                    image: properties?.images.first,
                    handler: { _ in
                        action()
                        return .success
                    },
                    bridged: false
                )
            } else if let name = properties?.labelStorage?.texts.first {
                accessibilityAction = AnyAccessibilityAction(
                    action: AccessibilityVoidAction(kind: .init(named: name)),
                    label: nil,
                    image: properties?.images.first,
                    handler: { _ in
                        action()
                        return .success
                    },
                    bridged: false
                )
            } else {
                accessibilityAction = nil
            }
            var attachment = AccessibilityAttachment()
            if let accessibilityAction {
                attachment.properties.actions = [accessibilityAction]
            }
            tree = .leaf(attachment)
        }
    }
}

extension ModifiedContent where Modifier == AccessibilityAttachmentModifier {
    func accessibilityAction<Action>(
        _ action: Action,
        label: Text? = nil,
        image: Image? = nil,
        _ handler: @escaping (Action.Value) -> Void
    ) -> ModifiedContent<Content, Modifier> where Action: AccessibilityAction {
        accessibilityAction(action, label: label, image: image) { value in
            handler(value)
            return .success
        }
    }

    func accessibilityAction<Action>(
        _ action: Action,
        label: Text? = nil,
        image: Image? = nil,
        _ handler: @escaping (Action.Value) -> AccessibilityActionResult
    ) -> ModifiedContent<Content, Modifier> where Action: AccessibilityAction {
        accessibilityActions([
            AnyAccessibilityAction(action: action, label: label, image: image, handler: handler, bridged: false)
        ])
    }

    func accessibilityActions(_ actions: [AnyAccessibilityAction]) -> ModifiedContent<Content, Modifier> {
        update(AccessibilityProperties.ActionsKey.self, combining: actions)
    }
}
