//
//  KeyboardShortcut.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 254C3FE5924A018B482F2F0C0D49154F (SwiftUI)

import Foundation
import OpenAttributeGraphShims
@_spi(Private)
public import OpenSwiftUICore

// MARK: - View + keyboardShortcut

@available(OpenSwiftUI_v2_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension View {
    /// Defines a keyboard shortcut and assigns it to the modified control.
    ///
    /// Pressing the control's shortcut while the control is anywhere in the
    /// frontmost window or scene, or anywhere in the macOS main menu, is
    /// equivalent to direct interaction with the control to perform its primary
    /// action.
    ///
    /// The target of a keyboard shortcut is resolved in a leading-to-trailing,
    /// depth-first traversal of one or more view hierarchies. On macOS, the
    /// system looks in the key window first, then the main window, and then the
    /// command groups; on other platforms, the system looks in the active
    /// scene, and then the command groups.
    ///
    /// If multiple controls are associated with the same shortcut, the first
    /// one found is used.
    ///
    /// The default localization configuration is set to
    /// ``KeyboardShortcut/Localization-swift.struct/automatic``.
    nonisolated public func keyboardShortcut(
        _ key: KeyEquivalent,
        modifiers: EventModifiers = .command
    ) -> some View {
        keyboardShortcut(KeyboardShortcut(key, modifiers: modifiers))
    }

    /// Assigns a keyboard shortcut to the modified control.
    ///
    /// Pressing the control's shortcut while the control is anywhere in the
    /// frontmost window or scene, or anywhere in the macOS main menu, is
    /// equivalent to direct interaction with the control to perform its primary
    /// action.
    ///
    /// The target of a keyboard shortcut is resolved in a leading-to-trailing
    /// traversal of one or more view hierarchies. On macOS, the system looks in
    /// the key window first, then the main window, and then the command groups;
    /// on other platforms, the system looks in the active scene, and then the
    /// command groups.
    ///
    /// If multiple controls are associated with the same shortcut, the first
    /// one found is used.
    nonisolated public func keyboardShortcut(_ shortcut: KeyboardShortcut) -> some View {
        keyboardShortcut(Optional(shortcut))
    }

    /// Assigns an optional keyboard shortcut to the modified control.
    ///
    /// Pressing the control's shortcut while the control is anywhere in the
    /// frontmost window or scene, or anywhere in the macOS main menu, is
    /// equivalent to direct interaction with the control to perform its primary
    /// action.
    ///
    /// The target of a keyboard shortcut is resolved in a leading-to-trailing
    /// traversal of one or more view hierarchies. On macOS, the system looks in
    /// the key window first, then the main window, and then the command groups;
    /// on other platforms, the system looks in the active scene, and then the
    /// command groups.
    ///
    /// If multiple controls are associated with the same shortcut, the first
    /// one found is used. If the provided shortcut is `nil`, the modifier will
    /// have no effect.
    @available(OpenSwiftUI_v3_4, *)
    nonisolated public func keyboardShortcut(_ shortcut: KeyboardShortcut?) -> some View {
        environment(\.keyboardShortcut, shortcut)
            .input(HasKeyboardShortcut.self)
            ._trait(KeyboardShortcutPickerOptionTraitKey.self, shortcut)
    }
}

@available(OpenSwiftUI_v3_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension View {
    /// Defines a keyboard shortcut and assigns it to the modified control.
    ///
    /// Pressing the control's shortcut while the control is anywhere in the
    /// frontmost window or scene, or anywhere in the macOS main menu, is
    /// equivalent to direct interaction with the control to perform its primary
    /// action.
    ///
    /// The target of a keyboard shortcut is resolved in a leading-to-trailing,
    /// depth-first traversal of one or more view hierarchies. On macOS, the
    /// system looks in the key window first, then the main window, and then the
    /// command groups; on other platforms, the system looks in the active
    /// scene, and then the command groups.
    ///
    /// If multiple controls are associated with the same shortcut, the first
    /// one found is used.
    ///
    /// ### Localization
    ///
    /// Provide a `localization` value to specify how this shortcut
    /// should be localized.
    /// Given that `key` is always defined in relation to the US-English
    /// keyboard layout, it might be hard to reach on different international
    /// layouts. For example the shortcut `⌘[` works well for the
    /// US layout but is hard to reach for German users, where
    /// `[` is available by pressing `⌥5`, making users type `⌥⌘5`.
    /// The automatic keyboard shortcut remapping re-assigns the shortcut to
    /// an appropriate replacement, `⌘Ö` in this case.
    ///
    /// Certain shortcuts carry information about directionality. For instance,
    /// `⌘[` can reveal a previous view. Following the layout direction of
    /// the UI, this shortcut will be automatically mirrored to `⌘]`.
    /// However, this does not apply to items such as "Align Left `⌘{`",
    /// which will be "left" independently of the layout direction.
    /// When the shortcut shouldn't follow the directionality of the UI, but rather
    /// be the same in both right-to-left and left-to-right directions, using
    /// ``KeyboardShortcut/Localization-swift.struct/withoutMirroring``
    /// will prevent the system from flipping it.
    ///
    ///     var body: some Commands {
    ///         CommandMenu("Card") {
    ///             Button("Align Left") { ... }
    ///                 .keyboardShortcut("{",
    ///                      modifiers: .option,
    ///                      localization: .withoutMirroring)
    ///             Button("Align Right") { ... }
    ///                 .keyboardShortcut("}",
    ///                      modifiers: .option,
    ///                      localization: .withoutMirroring)
    ///         }
    ///     }
    ///
    /// Lastly, providing the option
    /// ``KeyboardShortcut/Localization-swift.struct/custom``
    /// disables
    /// the automatic localization for this shortcut to tell the system that
    /// internationalization is taken care of in a different way.
    nonisolated public func keyboardShortcut(
        _ key: KeyEquivalent,
        modifiers: EventModifiers = .command,
        localization: KeyboardShortcut.Localization
    ) -> some View {
        keyboardShortcut(KeyboardShortcut(key, modifiers: modifiers, localization: localization))
    }
}

// MARK: - Scene + keyboardShortcut

@available(OpenSwiftUI_v4_0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension Scene {
    /// Defines a keyboard shortcut for opening new scene windows.
    ///
    /// A scene's keyboard shortcut is bound to the command it adds for creating
    /// new windows (in the case of `WindowGroup` and `DocumentGroup`) or
    /// bringing a singleton window forward (in the case of `Window` and, on
    /// macOS, `Settings`). Pressing the keyboard shortcut is equivalent to
    /// selecting the menu command.
    ///
    /// In cases where a command already has a keyboard shortcut, the scene's
    /// keyboard shortcut is used instead. For example, `WindowGroup` normally
    /// creates a File > New Window menu command whose keyboard shortcut is
    /// `⌘N`. The following code changes it to `⌥⌘N`:
    ///
    ///     WindowGroup {
    ///         ContentView()
    ///     }
    ///     .keyboardShortcut("n", modifiers: [.option, .command])
    ///
    /// ### Localization
    ///
    /// Provide a `localization` value to specify how this shortcut
    /// should be localized.
    ///
    /// Given that `key` is always defined in relation to the US-English
    /// keyboard layout, it might be hard to reach on different international
    /// layouts. For example the shortcut `⌘[` works well for the
    /// US layout but is hard to reach for German users, where
    /// `[` is available by pressing `⌥5`, making users type `⌥⌘5`.
    /// The automatic keyboard shortcut remapping re-assigns the shortcut to
    /// an appropriate replacement, `⌘Ö` in this case.
    ///
    /// Providing the option
    /// ``KeyboardShortcut/Localization-swift.struct/custom``
    /// disables the automatic localization for this shortcut to tell the system
    /// that internationalization is taken care of in a different way.
    ///
    /// - Parameters:
    ///   - key: The key equivalent the user presses to present the scene.
    ///   - modifiers: The modifier keys required to perform the shortcut.
    ///   - localization: The localization style to apply to the shortcut.
    /// - Returns: A scene that can be presented with a keyboard shortcut.
    nonisolated public func keyboardShortcut(
        _ key: KeyEquivalent,
        modifiers: EventModifiers = .command,
        localization: KeyboardShortcut.Localization = .automatic
    ) -> some Scene {
        keyboardShortcut(KeyboardShortcut(key, modifiers: modifiers, localization: localization))
    }

    /// Defines a keyboard shortcut for opening new scene windows.
    ///
    /// A scene's keyboard shortcut is bound to the command it adds for creating
    /// new windows (in the case of `WindowGroup` and `DocumentGroup`) or
    /// bringing a singleton window forward (in the case of `Window` and, on
    /// macOS, `Settings` and `UtilityWindow`). Pressing the keyboard shortcut
    /// is equivalent to selecting the menu command.
    ///
    /// In cases where a command already has a keyboard shortcut, the scene's
    /// keyboard shortcut is used instead. For example, `WindowGroup` normally
    /// creates a File > New Window menu command whose keyboard shortcut is
    /// `⌘N`. The following code changes it to something based on dynamic state:
    ///
    ///     @main
    ///     struct Notes: App {
    ///         @State private var newWindowShortcut: KeyboardShortcut? = ...
    ///
    ///         var body: some Scene {
    ///             WindowGroup {
    ///                 ContentView($newWindowShortcut)
    ///             }
    ///             .keyboardShortcut(newWindowShortcut)
    ///         }
    ///     }
    ///
    /// If `shortcut` is `nil`, the scene's presentation command will not be
    /// associated with a keyboard shortcut, even if OpenSwiftUI normally assigns
    /// one automatically.
    ///
    /// - Parameters:
    ///   - shortcut: The keyboard shortcut for presenting the scene, or `nil`.
    /// - Returns: A scene that can be presented with a keyboard shortcut.
    nonisolated public func keyboardShortcut(_ shortcut: KeyboardShortcut?) -> some Scene {
        #if os(macOS)
        transformPreference(SceneList.Key.self) { list in
            var items: [SceneList.Item] = []
            for item in list.items {
                var item = item
                item.keyboardShortcut = item.keyboardShortcut ?? shortcut
                items.append(item)
            }
            list.items = items
        }
        #else
        _openSwiftUIUnreachableCode()
        #endif
    }
}

// MARK: - KeyboardShortcut

/// Keyboard shortcuts describe combinations of keys on a keyboard that the user
/// can press in order to activate a button or toggle.
@available(OpenSwiftUI_v2_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct KeyboardShortcut: Sendable {
    /// Options for how a keyboard shortcut participates in automatic localization.
    ///
    /// A shortcut's `key` that is defined on an US-English keyboard
    /// layout might not be reachable on international layouts.
    /// For example the shortcut `⌘[` works well for the US layout but is
    /// hard to reach for German users.
    /// On the German keyboard layout, pressing `⌥5` will produce
    /// `[`, which causes the shortcut to become `⌥⌘5`.
    /// If configured, which is the default behavior, automatic shortcut
    /// remapping will convert it to `⌘Ö`.
    ///
    /// In addition to that, some keyboard shortcuts carry information
    /// about directionality.
    /// Right-aligning a block of text or seeking forward in context of music
    /// playback are such examples. These kinds of shortcuts benefit from the option
    /// ``KeyboardShortcut/Localization-swift.struct/withoutMirroring``
    /// to tell the system that they won't be flipped when running in a
    /// right-to-left context.
    @available(OpenSwiftUI_v3_0, *)
    public struct Localization: Sendable {
        /// Remap shortcuts to their international counterparts, mirrored for
        /// right-to-left usage if appropriate.
        ///
        /// This is the default configuration.
        public static let automatic = Localization(style: .automatic)

        /// Don't mirror shortcuts.
        ///
        /// Use this for shortcuts that always have a specific directionality, like
        /// aligning something on the right.
        ///
        /// Don't use this option for navigational shortcuts like "Go Back" because navigation
        /// is flipped in right-to-left contexts.
        public static let withoutMirroring = Localization(style: .withoutMirroring)

        /// Don't use automatic shortcut remapping.
        ///
        /// When you use this mode, you have to take care of international use-cases separately.
        public static let custom = Localization(style: .custom)

        enum Style: Hashable {
            case automatic
            case withoutMirroring
            case custom
        }

        let style: Style
    }

    /// The standard keyboard shortcut for the default button, consisting of
    /// the Return (↩) key and no modifiers.
    ///
    /// On macOS, the default button is designated with special coloration. If
    /// more than one control is assigned this shortcut, only the first one is
    /// emphasized.
    public static let defaultAction = KeyboardShortcut(.return, modifiers: [])

    /// The standard keyboard shortcut for cancelling the in-progress action
    /// or dismissing a prompt, consisting of the Escape (⎋) key and no
    /// modifiers.
    public static let cancelAction = KeyboardShortcut(.escape, modifiers: [])

    /// The key equivalent that the user presses in conjunction with any
    /// specified modifier keys to activate the shortcut.
    public var key: KeyEquivalent

    /// The modifier keys that the user presses in conjunction with a key
    /// equivalent to activate the shortcut.
    public var modifiers: EventModifiers

    /// The localization strategy to apply to this shortcut.
    @available(OpenSwiftUI_v3_0, *)
    public var localization: Localization

    /// Creates a new keyboard shortcut with the given key equivalent and set of
    /// modifier keys.
    ///
    /// The localization configuration defaults to
    /// ``KeyboardShortcut/Localization-swift.struct/automatic``.
    public init(
        _ key: KeyEquivalent,
        modifiers: EventModifiers = .command
    ) {
        self.key = key
        self.modifiers = modifiers
        self.localization = .automatic
    }

    /// Creates a new keyboard shortcut with the given key equivalent and set of
    /// modifier keys.
    ///
    /// Use the `localization` parameter to specify a localization strategy
    /// for this shortcut.
    @available(OpenSwiftUI_v3_0, *)
    public init(
        _ key: KeyEquivalent,
        modifiers: EventModifiers = .command,
        localization: Localization
    ) {
        self.key = key
        self.modifiers = modifiers
        self.localization = localization
    }
}

// MARK: - KeyEquivalent

/// Key equivalents consist of a letter, punctuation, or function key that can
/// be combined with an optional set of modifier keys to specify a keyboard
/// shortcut.
///
/// Key equivalents are used to establish keyboard shortcuts to app
/// functionality. Any key can be used as a key equivalent as long as pressing
/// it produces a single character value. Key equivalents are typically
/// initialized using a single-character string literal, with constants for
/// unprintable or hard-to-type values.
///
/// The modifier keys necessary to type a key equivalent are factored in to the
/// resulting keyboard shortcut. That is, a key equivalent whose raw value is
/// the capitalized string "A" corresponds with the keyboard shortcut
/// Command-Shift-A. The exact mapping may depend on the keyboard layout—for
/// example, a key equivalent with the character value "}" produces a shortcut
/// equivalent to Command-Shift-] on ANSI keyboards, but would produce a
/// different shortcut for keyboard layouts where punctuation characters are in
/// different locations.
@available(OpenSwiftUI_v2_0, *)
// @available(tvOS 17.0, *)
@available(watchOS, unavailable)
public struct KeyEquivalent: Sendable {
    /// Up Arrow (U+F700)
    public static let upArrow: KeyEquivalent = "\u{F700}"

    /// Down Arrow (U+F701)
    public static let downArrow: KeyEquivalent = "\u{F701}"

    /// Left Arrow (U+F702)
    public static let leftArrow: KeyEquivalent = "\u{F702}"

    /// Right Arrow (U+F703)
    public static let rightArrow: KeyEquivalent = "\u{F703}"

    /// Escape (U+001B)
    public static let escape: KeyEquivalent = "\u{001B}"

    /// Delete (U+0008)
    public static let delete: KeyEquivalent = "\u{0008}"

    /// Delete Forward (U+F728)
    public static let deleteForward: KeyEquivalent = "\u{F728}"

    /// Home (U+F729)
    public static let home: KeyEquivalent = "\u{F729}"

    /// End (U+F72B)
    public static let end: KeyEquivalent = "\u{F72B}"

    /// Page Up (U+F72C)
    public static let pageUp: KeyEquivalent = "\u{F72C}"

    /// Page Down (U+F72D)
    public static let pageDown: KeyEquivalent = "\u{F72D}"

    /// Clear (U+F739)
    public static let clear: KeyEquivalent = "\u{F739}"

    /// Tab (U+0009)
    public static let tab: KeyEquivalent = "\u{0009}"

    /// Space (U+0020)
    public static let space: KeyEquivalent = "\u{0020}"

    /// Return (U+000D)
    public static let `return`: KeyEquivalent = "\u{000D}"

    /// The character value that the key equivalent represents.
    public var character: Character

    /// Creates a new key equivalent from the given character value.
    public init(_ character: Character) {
        self.character = character
    }
}

@available(OpenSwiftUI_v5_0, *)
@available(watchOS, unavailable)
extension KeyEquivalent: Hashable {}

@available(OpenSwiftUI_v2_0, *)
// @available(tvOS 17.0, *)
@available(watchOS, unavailable)
extension KeyEquivalent: ExpressibleByExtendedGraphemeClusterLiteral {
    public init(extendedGraphemeClusterLiteral: Character) {
        character = extendedGraphemeClusterLiteral
    }

    public typealias ExtendedGraphemeClusterLiteralType = Character
    public typealias UnicodeScalarLiteralType = Character
}

// MARK: - EnvironmentValues + keyboardShortcut

@available(OpenSwiftUI_v3_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension EnvironmentValues {
    /// The keyboard shortcut that buttons in this environment will be triggered
    /// with.
    ///
    /// This is particularly useful in button styles when a button's appearance
    /// depends on the shortcut associated with it. On macOS, for example, when
    /// a button is bound to the Return key, it is typically drawn with a
    /// special emphasis. This happens automatically when using the built-in
    /// button styles, and can be implemented manually in custom styles using
    /// this environment key:
    ///
    ///     private struct MyButtonStyle: ButtonStyle {
    ///         @Environment(\.keyboardShortcut)
    ///         private var shortcut: KeyboardShortcut?
    ///
    ///         func makeBody(configuration: Configuration) -> some View {
    ///             let labelFont = Font.body
    ///                 .weight(shortcut == .defaultAction ? .bold : .regular)
    ///             configuration.label
    ///                 .font(labelFont)
    ///         }
    ///     }
    ///
    /// If no keyboard shortcut has been applied to the view or its ancestor,
    /// then the environment value will be `nil`.
    public internal(set) var keyboardShortcut: KeyboardShortcut? {
        get { self[ButtonKeyboardShortcutKey.self] }
        set { self[ButtonKeyboardShortcutKey.self] = newValue }
    }
}

// MARK: - ButtonKeyboardShortcutKey

private struct ButtonKeyboardShortcutKey: EnvironmentKey {
    static var defaultValue: KeyboardShortcut? { nil }
}

extension CachedEnvironment.ID {
    static let keyboardShortcut: CachedEnvironment.ID = .init()
}

extension _GraphInputs {
    var keyboardShortcut: Attribute<KeyboardShortcut?> {
        mapEnvironment(id: .keyboardShortcut) { $0.keyboardShortcut }
    }
}

// MARK: - EnvironmentValues + sceneKeyboardShortcuts

extension EnvironmentValues {
    private struct SceneKeyboardShortcutsKey: EnvironmentKey {
        static var defaultValue: [SceneID: KeyboardShortcut] { [:] }
    }

    @inline(__always)
    var sceneKeyboardShortcuts: [SceneID: KeyboardShortcut] {
        get { self[SceneKeyboardShortcutsKey.self] }
        set { self[SceneKeyboardShortcutsKey.self] = newValue }
    }
}

// MARK: - View + KeyboardShortcutBindingBehavior

extension View {
    nonisolated func keyboardShortcutBindingBehavior<V>(
        action: @escaping () -> Void,
        label: () -> V
    ) -> some View where V: View {
        modifier(KeyboardShortcutBindingBehavior(action: action, label: label()))
    }
}

// MARK: - KeyboardShortcutBinding

struct KeyboardShortcutBinding {
    var shortcut: KeyboardShortcut
    var action: () -> ()
    var title: String?
}

// MARK: - KeyboardShortcutBindingBehavior

struct KeyboardShortcutBindingBehavior<V>: MultiViewModifier, PrimitiveViewModifier where V: View {
    var action: () -> ()
    var label: V

    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = body(_Graph(), inputs)
        if inputs[HasKeyboardShortcut.self] {
            let listGenerator = PlatformItemListGenerator(
                flags: TextPlatformItemListFlags.self,
                content: modifier.value[offset: { .of(&$0.label) }],
                inputs: inputs,
                inputsIncludeGeometry: true
            )
            outputs.preferences.makePreferenceWriter(
                inputs: inputs.preferences,
                key: KeyboardShortcutBindingsKey.self,
                value: Attribute(BindKeyboardShortcutItems(
                    modifier: modifier.value,
                    listGenerator: listGenerator,
                    shortcut: inputs.base.keyboardShortcut,
                    isEnabled: inputs.isEnabled,
                    hostKeys: inputs.preferences.hostKeys,
                    itemList: OptionalAttribute()
                ))
            )
        }
        return outputs
    }
}

// MARK: - KeyboardShortcutBindingsKey

struct KeyboardShortcutBindingsKey: HostPreferenceKey {
    static var defaultValue: [KeyboardShortcutBinding] { [] }

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}

// MARK: - BindKeyboardShortcutItems

private struct BindKeyboardShortcutItems<V>: StatefulRule where V: View {
    @Attribute var modifier: KeyboardShortcutBindingBehavior<V>
    var listGenerator: PlatformItemListGenerator<TextPlatformItemListFlags, V>
    @Attribute var shortcut: KeyboardShortcut?
    @Attribute var isEnabled: Bool
    @Attribute var hostKeys: PreferenceKeys
    var itemList: OptionalAttribute<PlatformItemList>

    typealias Value = [KeyboardShortcutBinding]

    mutating func updateValue() {
        guard hostKeys.contains(KeyboardShortcutBindingsKey.self),
              isEnabled,
              let shortcut else {
            value = []
            return
        }
        let list: Attribute<PlatformItemList>
        if let attribute = itemList.attribute {
            list = attribute
        } else {
            let oldSubgraph = Subgraph.current
            Subgraph.current = attribute.subgraph
            list = Attribute(listGenerator)
            Subgraph.current = oldSubgraph
            itemList = OptionalAttribute(list)
        }
        value = [KeyboardShortcutBinding(
            shortcut: shortcut,
            action: modifier.action,
            title: list.value.mergedContentItem.text?.string
        )]
    }
}

// MARK: - HasKeyboardShortcut

struct HasKeyboardShortcut: ViewInputBoolFlag {}

// MARK: - KeyboardShortcut + Hashable

@available(OpenSwiftUI_v3_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension KeyboardShortcut: Hashable {
    public static func == (lhs: KeyboardShortcut, rhs: KeyboardShortcut) -> Bool {
        lhs.key.character == rhs.key.character &&
            lhs.modifiers == rhs.modifiers &&
            lhs.localization.style == rhs.localization.style
    }

    public func hash(into hasher: inout Hasher) {
        key.character.hash(into: &hasher)
        hasher.combine(modifiers.rawValue)
        hasher.combine(localization.style)
    }
}
