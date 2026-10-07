//
//  Button.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import Foundation
public import OpenSwiftUICore

// MARK: - Button

/// A control that initiates an action.
///
/// You create a button by providing an action and a label. The action is either
/// a method or closure property that does something when a user clicks or taps
/// the button. The label is a view that describes the button's action --- for
/// example, by showing text, an icon, or both.
///
/// The label of a button can be any kind of view, such as a ``Text`` view for
/// text-only labels:
///
///     Button(action: signIn) {
///         Text("Sign In")
///     }
///
/// Or a ``Label`` view, for buttons with both a title and an icon:
///
///     Button(action: signIn) {
///         Label("Sign In", systemImage: "arrow.up")
///     }
///
/// For those common cases, you can also use the convenience initializers that
/// take a title string or ``LocalizedStringKey`` as their first parameter, and
/// optionally a system image name or `ImageResource` as their second parameter,
/// instead of a trailing closure:
///
///     Button("Sign In", systemImage: "arrow.up", action: signIn)
///
/// Prefer to use these convenience initializers, or a ``Label`` view, when
/// providing both a title and an icon. This allows the button to dynamically
/// adapt its appearance to render its title and icon correctly in containers
/// such as toolbars and menus. For example, on iOS, buttons only display their
/// icons by default when placed in toolbars, but show both a leading title and
/// trailing icon in menus. Defining labels this way also helps with
/// accessibility --- for example, applying the ``View/labelStyle(_:)`` modifier
/// with an ``LabelStyle/iconOnly`` style to the button will cause it to only
/// visually display its icon, but still use its title to describe the button in
/// accessibility modes like VoiceOver:
///
///     Button("Sign In", systemImage: "arrow.up", action: signIn)
///         .labelStyle(.iconOnly)
///
/// Avoid labels that only use images or exclusively visual components without
/// an accessibility label.
///
/// How the user activates the button varies by platform:
/// - In iOS and watchOS, the user taps the button.
/// - In macOS, the user clicks the button.
/// - In tvOS, the user presses "select" on an
///   external remote, like the Siri Remote, while focusing on the button.
///
/// The appearance of the button depends on factors like where you
/// place it, whether you assign it a role, and how you style it.
///
/// ### Adding buttons to containers
///
/// Use buttons for any user interface element that initiates an action.
/// Buttons automatically adapt their visual style to match the expected style
/// within these different containers and contexts. For example, to create a
/// ``List`` cell that
/// initiates an action when selected by the user, add a button to the list's
/// content:
///
///     List {
///         // Cells that show all the current folders.
///         ForEach(folders) { folder in
///             Text(folder.title)
///         }
///
///         // A cell that, when selected, adds a new folder.
///         Button(action: addItem) {
///             Label("Add Folder", systemImage: "folder.badge.plus")
///         }
///     }
///
/// ![A screenshot of a list of four items. The first three items use a
/// grayscale foreground color and have the text Documents, Downloads,
/// and Recents. The last item has a blue foreground color and shows
/// a folder icon with the text Add Folder.](Button-1)
///
/// Similarly, to create a context menu item that initiates an action, add a
/// button to the
/// ``View/contextMenu(_:)``
/// modifier's content closure:
///
///     .contextMenu {
///         Button("Cut", action: cut)
///         Button("Copy", action: copy)
///         Button("Paste", action: paste)
///     }
///
/// ![A screenshot of a context menu that contains the three items Cut, Copy,
/// and Paste.](Button-2)
///
/// This pattern extends to most other container views in OpenSwiftUI that have
/// customizable, interactive content, like
/// ``Form`` instances.
///
/// ### Assigning a role
///
/// You can optionally initialize a button with a ``ButtonRole`` that
/// characterizes the button's purpose. For example, you can create a
/// ``ButtonRole/destructive`` button for a deletion action:
///
///      Button("Delete", role: .destructive, action: delete)
///
/// The system uses the button's role to style the button appropriately
/// in every context. For example, a destructive button in a contextual menu
/// appears with a red foreground color:
///
/// ![A screenshot of a context menu that contains the four items Cut, Copy,
/// Paste, and Delete. The last item uses a foreground color of red.](Button-3)
///
/// If you don't specify a role for a button, the system applies an
/// appropriate default appearance.
///
/// ### Styling buttons
///
/// You can customize a button's appearance using one of the standard button
/// styles, like
/// ``PrimitiveButtonStyle/bordered``,
/// and apply the style with the ``View/buttonStyle(_:)`` modifier:
///
///     HStack {
///         Button("Sign In", action: signIn)
///         Button("Register", action: register)
///     }
///     .buttonStyle(.bordered)
///
/// If you apply the style to a container view, as in the example above,
/// all the buttons in the container use the style:
///
/// ![A screenshot of two buttons, side by side, each with a capsule shaped
/// background. The label for the first button is Sign In; the right button is
/// Register.](Button-4)
///
/// You can also create custom styles. To add a custom appearance with
/// standard interaction behavior, create a style that conforms to the
/// ``ButtonStyle`` protocol. To customize both appearance and interaction
/// behavior, create a style that conforms to the ``PrimitiveButtonStyle``
/// protocol. Custom styles can also read the button's role and use it to
/// adjust the button's appearance.
@available(OpenSwiftUI_v1_0, *)
public struct Button<Label>: View where Label: View {
    var role: ButtonRole?

    var action: ButtonAction

    var label: Label

    /// Creates a button that displays a custom label.
    ///
    /// - Parameters:
    ///   - action: The action to perform when the user triggers the button.
    ///   - label: A view that describes the purpose of the button's `action`.
    @preconcurrency
    nonisolated public init(action: @escaping @MainActor () -> Void, @ViewBuilder label: () -> Label) {
        self.role = nil
        self.action = .closure(action)
        self.label = label()
    }

    @_spi(Private)
    nonisolated public init(
        _ label: Label,
        action: @escaping () -> Void
    ) where Label == OpenSwiftUI.Label<Text, Image> {
        self.role = nil
        self.action = .closure(action)
        self.label = label
    }

    init(destination: LinkDestination, @ViewBuilder label: () -> Label) {
        self.role = nil
        self.action = .url(destination)
        self.label = label()
    }

    public var body: some View {
        ResolvedButtonStyle(configuration: .init(role: role, action: action))
            .viewAlias(PrimitiveButtonStyleConfiguration.Label.self) {
                label
            }
            .viewAlias(ButtonStyleConfiguration.Label.self) {
                label
            }
            #if os(macOS)
            .dynamicToolbarStyleContext()
            #endif
    }
}

@available(*, unavailable)
extension Button: Sendable {}

// MARK: - Button + Text

@available(OpenSwiftUI_v1_0, *)
extension Button where Label == Text {
    /// Creates a button that generates its label from a localized string key.
    ///
    /// This initializer creates a ``Text`` view on your behalf, and treats the
    /// localized key similar to ``Text/init(_:tableName:bundle:comment:)``. See
    /// ``Text`` for more information about localizing strings.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the button's localized title, that describes
    ///     the purpose of the button's `action`.
    ///   - action: The action to perform when the user triggers the button.
    @preconcurrency
    nonisolated public init(_ titleKey: LocalizedStringKey, action: @escaping @MainActor () -> Void) {
        self.init(action: action) {
            Text(titleKey)
        }
    }

    /// Creates a button that generates its label from a string.
    ///
    /// This initializer creates a ``Text`` view on your behalf, and treats the
    /// title similar to ``Text/init(_:)``. See ``Text`` for more
    /// information about localizing strings.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the button's `action`.
    ///   - action: The action to perform when the user triggers the button.
    @preconcurrency
    @_disfavoredOverload
    nonisolated public init<S>(_ title: S, action: @escaping @MainActor () -> Void) where S: StringProtocol {
        self.init(action: action) {
            Text(title)
        }
    }
}

// MARK: - Button + Label

@available(OpenSwiftUI_v2_0, *)
extension Button where Label == OpenSwiftUI.Label<Text, Image> {
    /// Creates a button that generates its label from a localized string key
    /// and system image name.
    ///
    /// This initializer creates a ``Label`` view on your behalf, and treats the
    /// localized key similar to ``Text/init(_:tableName:bundle:comment:)``. See
    /// ``Text`` for more information about localizing strings.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the button's localized title, that describes
    ///     the purpose of the button's `action`.
    ///   - systemImage: The name of the image resource to lookup.
    ///   - action: The action to perform when the user triggers the button.
    @_alwaysEmitIntoClient
    nonisolated public init(
        _ titleKey: LocalizedStringKey,
        systemImage: String,
        action: @escaping @MainActor () -> Void
    ) {
        self.init(action: action) {
            OpenSwiftUI.Label(titleKey, systemImage: systemImage)
        }
    }

    /// Creates a button that generates its label from a string and
    /// system image name.
    ///
    /// This initializer creates a ``Label`` view on your behalf, and treats the
    /// title similar to ``Text/init(_:)``. See ``Text`` for more
    /// information about localizing strings.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the button's `action`.
    ///   - systemImage: The name of the image resource to lookup.
    ///   - action: The action to perform when the user triggers the button.
    @_disfavoredOverload
    @_alwaysEmitIntoClient
    nonisolated public init<S>(
        _ title: S,
        systemImage: String,
        action: @escaping @MainActor () -> Void
    ) where S: StringProtocol {
        self.init(action: action) {
            OpenSwiftUI.Label(title, systemImage: systemImage)
        }
    }
}

#if canImport(Darwin) && canImport(DeveloperToolsSupport)
@available(OpenSwiftUI_v5_0, *)
extension Button where Label == OpenSwiftUI.Label<Text, Image> {
    /// Creates a button that generates its label from a localized string key
    /// and image resource.
    ///
    /// This initializer creates a ``Label`` view on your behalf, and treats the
    /// localized key similar to ``Text/init(_:tableName:bundle:comment:)``. See
    /// ``Text`` for more information about localizing strings.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the button's localized title, that describes
    ///     the purpose of the button's `action`.
    ///   - image: The image resource to lookup.
    ///   - action: The action to perform when the user triggers the button.
    @preconcurrency
    nonisolated public init(
        _ titleKey: LocalizedStringKey,
        image: ImageResource,
        action: @escaping @MainActor () -> Void
    ) {
        self.init(action: action) {
            OpenSwiftUI.Label(titleKey, image: image)
        }
    }

    /// Creates a button that generates its label from a string and
    /// image resource.
    ///
    /// This initializer creates a ``Label`` view on your behalf, and treats the
    /// title similar to ``Text/init(_:)``. See ``Text`` for more
    /// information about localizing strings.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the button's `action`.
    ///   - image: The image resource to lookup.
    ///   - action: The action to perform when the user triggers the button.
    @preconcurrency
    @_disfavoredOverload
    nonisolated public init<S>(
        _ title: S,
        image: ImageResource,
        action: @escaping @MainActor () -> Void
    ) where S: StringProtocol {
        self.init(action: action) {
            OpenSwiftUI.Label(title, image: image)
        }
    }
}
#endif

// MARK: - Button + PrimitiveButtonStyleConfiguration

@available(OpenSwiftUI_v1_0, *)
extension Button where Label == PrimitiveButtonStyleConfiguration.Label {
    /// Creates a button based on a configuration for a style with a custom
    /// appearance and custom interaction behavior.
    ///
    /// Use this initializer within the
    /// ``PrimitiveButtonStyle/makeBody(configuration:)`` method of a
    /// ``PrimitiveButtonStyle`` to create an instance of the button that you
    /// want to style. This is useful for custom button styles that modify the
    /// current button style, rather than implementing a brand new style.
    ///
    /// For example, the following style adds a red border around the button,
    /// but otherwise preserves the button's current style:
    ///
    ///     struct RedBorderedButtonStyle: PrimitiveButtonStyle {
    ///         func makeBody(configuration: Configuration) -> some View {
    ///             Button(configuration)
    ///                 .border(Color.red)
    ///         }
    ///     }
    ///
    /// - Parameter configuration: A configuration for a style with a custom
    ///   appearance and custom interaction behavior.
    nonisolated public init(_ configuration: PrimitiveButtonStyleConfiguration) {
        role = configuration.role
        action = configuration.action
        label = configuration.label
    }
}

// MARK: - Button + ButtonRole

@available(OpenSwiftUI_v3_0, *)
extension Button {
    /// Creates a button with a specified role that displays a custom label.
    ///
    /// - Parameters:
    ///   - role: An optional semantic role that describes the button. A value of
    ///     `nil` means that the button doesn't have an assigned role.
    ///   - action: The action to perform when the user interacts with the button.
    ///   - label: A view that describes the purpose of the button's `action`.
    @preconcurrency
    nonisolated public init(
        role: ButtonRole?,
        action: @escaping @MainActor () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.role = role
        self.action = .closure(action)
        self.label = label()
    }
}

@available(OpenSwiftUI_v3_0, *)
extension Button where Label == Text {
    /// Creates a button with a specified role that generates its label from a
    /// localized string key.
    ///
    /// This initializer creates a ``Text`` view on your behalf, and treats the
    /// localized key similar to ``Text/init(_:tableName:bundle:comment:)``. See
    /// ``Text`` for more information about localizing strings.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the button's localized title, that describes
    ///     the purpose of the button's `action`.
    ///   - role: An optional semantic role describing the button. A value of
    ///     `nil` means that the button doesn't have an assigned role.
    ///   - action: The action to perform when the user triggers the button.
    @preconcurrency
    nonisolated public init(
        _ titleKey: LocalizedStringKey,
        role: ButtonRole?,
        action: @escaping @MainActor () -> Void
    ) {
        self.init(role: role, action: action) {
            Text(titleKey)
        }
    }

    /// Creates a button with a specified role that generates its label from a
    /// string.
    ///
    /// This initializer creates a ``Text`` view on your behalf, and treats the
    /// title similar to ``Text/init(_:)``. See ``Text`` for more
    /// information about localizing strings.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the button's `action`.
    ///   - role: An optional semantic role describing the button. A value of
    ///     `nil` means that the button doesn't have an assigned role.
    ///   - action: The action to perform when the user interacts with the button.
    @preconcurrency
    @_disfavoredOverload
    nonisolated public init<S>(
        _ title: S,
        role: ButtonRole?,
        action: @escaping @MainActor () -> Void
    ) where S: StringProtocol {
        self.init(role: role, action: action) {
            Text(title)
        }
    }
}

@available(OpenSwiftUI_v3_0, *)
extension Button where Label == OpenSwiftUI.Label<Text, Image> {
    /// Creates a button with a specified role that generates its label from a
    /// localized string key and a system image.
    ///
    /// This initializer creates a ``Label`` view on your behalf, and treats the
    /// localized key similar to ``Text/init(_:tableName:bundle:comment:)``. See
    /// ``Text`` for more information about localizing strings.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the button's localized title, that describes
    ///     the purpose of the button's `action`.
    ///   - systemImage: The name of the image resource to lookup.
    ///   - role: An optional semantic role describing the button. A value of
    ///     `nil` means that the button doesn't have an assigned role.
    ///   - action: The action to perform when the user triggers the button.
    @_alwaysEmitIntoClient
    nonisolated public init(
        _ titleKey: LocalizedStringKey,
        systemImage: String,
        role: ButtonRole?,
        action: @escaping @MainActor () -> Void
    ) {
        self.init(role: role, action: action) {
            OpenSwiftUI.Label(titleKey, systemImage: systemImage)
        }
    }

    /// Creates a button with a specified role that generates its label from a
    /// string and a system image and an image resource.
    ///
    /// This initializer creates a ``Label`` view on your behalf, and treats the
    /// title similar to ``Text/init(_:)``. See ``Text`` for more
    /// information about localizing strings.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the button's `action`.
    ///   - systemImage: The name of the image resource to lookup.
    ///   - role: An optional semantic role describing the button. A value of
    ///     `nil` means that the button doesn't have an assigned role.
    ///   - action: The action to perform when the user interacts with the button.
    @_alwaysEmitIntoClient
    @_disfavoredOverload
    nonisolated public init<S>(
        _ title: S,
        systemImage: String,
        role: ButtonRole?,
        action: @escaping @MainActor () -> Void
    ) where S: StringProtocol {
        self.init(role: role, action: action) {
            OpenSwiftUI.Label(title, systemImage: systemImage)
        }
    }
}

#if canImport(Darwin) && canImport(DeveloperToolsSupport)
@available(OpenSwiftUI_v5_0, *)
extension Button where Label == OpenSwiftUI.Label<Text, Image> {
    /// Creates a button with a specified role that generates its label from a
    /// localized string key and an image resource.
    ///
    /// This initializer creates a ``Label`` view on your behalf, and treats the
    /// localized key similar to ``Text/init(_:tableName:bundle:comment:)``. See
    /// ``Text`` for more information about localizing strings.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the button's localized title, that describes
    ///     the purpose of the button's `action`.
    ///   - image: The image resource to lookup.
    ///   - role: An optional semantic role describing the button. A value of
    ///     `nil` means that the button doesn't have an assigned role.
    ///   - action: The action to perform when the user triggers the button.
    @preconcurrency
    nonisolated public init(
        _ titleKey: LocalizedStringKey,
        image: ImageResource,
        role: ButtonRole?,
        action: @escaping @MainActor () -> Void
    ) {
        self.init(role: role, action: action) {
            OpenSwiftUI.Label(titleKey, image: image)
        }
    }

    /// Creates a button with a specified role that generates its label from a
    /// string and an image resource.
    ///
    /// This initializer creates a ``Label`` view on your behalf, and treats the
    /// title similar to ``Text/init(_:)``. See ``Text`` for more
    /// information about localizing strings.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the button's `action`.
    ///   - image: The image resource to lookup.
    ///   - role: An optional semantic role describing the button. A value of
    ///     `nil` means that the button doesn't have an assigned role.
    ///   - action: The action to perform when the user interacts with the button.
    @preconcurrency
    @_disfavoredOverload
    nonisolated public init<S>(
        _ title: S,
        image: ImageResource,
        role: ButtonRole?,
        action: @escaping @MainActor () -> Void
    ) where S: StringProtocol {
        self.init(role: role, action: action) {
            OpenSwiftUI.Label(title, image: image)
        }
    }
}
#endif

// MARK: - Button + AppIntent

@_spi(AppIntent)
@available(OpenSwiftUI_v5_0, *)
extension Button {
    nonisolated public init(lnAction: NSObject, @ViewBuilder label: () -> Label) {
        self.init(role: nil, lnAction: lnAction, perform: { _openSwiftUIEmptyStub() }, label: label)
    }

    nonisolated public init(
        role: ButtonRole?,
        lnAction: NSObject,
        perform: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.role = role
        self.action = .appIntent(AppIntentAction(lnAction: lnAction, defaultExecutor: perform))
        self.label = label()
    }

    nonisolated public init(
        lnAction: NSObject,
        perform: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.init(role: nil, lnAction: lnAction, perform: perform, label: label)
    }
}

// MARK: - ButtonAction

enum ButtonAction {
    case closure(@MainActor () -> Void)
    case url(LinkDestination)
    case appIntent(AppIntentAction)

    func callAsFunction() {
        switch self {
        case let .closure(action):
            MainActor.assumeIsolated {
                action()
            }
        case let .url(destination):
            destination.open()
        case let .appIntent(action):
            action.perform()
        }
    }
}
