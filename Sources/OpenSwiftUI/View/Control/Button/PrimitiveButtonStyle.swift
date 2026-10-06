//
//  PrimitiveButtonStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete (Blocked by Navigation and Menu)
//  ID: 722D0A4BA446408AC7D14833D23ECE10 (SwiftUI)

public import OpenSwiftUICore

// MARK: - PrimitiveButtonStyle

/// A type that applies custom interaction behavior and a custom appearance to
/// all buttons within a view hierarchy.
///
/// To configure the current button style for a view hierarchy, use the
/// ``View/buttonStyle(_:)`` modifier. Specify a style that conforms to
/// `PrimitiveButtonStyle` to create a button with custom interaction
/// behavior. To create a button with the standard button interaction behavior
/// defined for each platform, use ``ButtonStyle`` instead.
///
/// A type conforming to this protocol inherits `@preconcurrency @MainActor`
/// isolation from the protocol if the conformance is included in the type's
/// base declaration:
///
///     struct MyCustomType: Transition {
///         // `@preconcurrency @MainActor` isolation by default
///     }
///
/// Isolation to the main actor is the default, but it's not required. Declare
/// the conformance in an extension to opt out of main actor isolation:
///
///     extension MyCustomType: Transition {
///         // `nonisolated` by default
///     }
///
@available(OpenSwiftUI_v1_0, *)
@preconcurrency
@MainActor
public protocol PrimitiveButtonStyle {
    /// A view that represents the body of a button.
    associatedtype Body: View

    /// Creates a view that represents the body of a button.
    ///
    /// The system calls this method for each ``Button`` instance in a view
    /// hierarchy where this style is the current button style.
    ///
    /// - Parameter configuration: The properties of the button.
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Self.Body

    /// The properties of a button.
    typealias Configuration = PrimitiveButtonStyleConfiguration
}

/// The properties of a button.
@available(OpenSwiftUI_v1_0, *)
public struct PrimitiveButtonStyleConfiguration {
    /// A type-erased label of a button.
    public struct Label: ViewAlias {
        public typealias Body = Never

        nonisolated package init() {
            _openSwiftUIEmptyStub()
        }
    }

    /// An optional semantic role describing the button's purpose.
    ///
    /// A value of `nil` means that the Button has no assigned role. If the
    /// button does have a role, use it to make adjustments to the button's
    /// appearance. The following example shows a custom style that uses
    /// bold text when the role is ``ButtonRole/cancel``,
    /// ``ShapeStyle/red`` text when the role is ``ButtonRole/destructive``,
    /// and adds no special styling otherwise:
    ///
    ///     struct MyButtonStyle: PrimitiveButtonStyle {
    ///         func makeBody(configuration: Configuration) -> some View {
    ///             configuration.label
    ///                 .onTapGesture {
    ///                     configuration.trigger()
    ///                 }
    ///                 .font(
    ///                     configuration.role == .cancel ? .title2.bold() : .title2)
    ///                 .foregroundColor(
    ///                     configuration.role == .destructive ? Color.red : nil)
    ///         }
    ///     }
    ///
    /// You can create one of each button using this style to see the effect:
    ///
    ///     VStack(spacing: 20) {
    ///         Button("Cancel", role: .cancel) {}
    ///         Button("Delete", role: .destructive) {}
    ///         Button("Continue") {}
    ///     }
    ///     .buttonStyle(MyButtonStyle())
    ///
    /// ![A screenshot of three buttons stacked vertically. The first says
    /// Cancel in black, bold letters. The second says Delete in red, regular
    /// weight letters. The third says Continue in black, regular weight
    /// letters.](PrimitiveButtonStyleConfiguration-role-1)
    @available(OpenSwiftUI_v3_0, *)
    public let role: ButtonRole?

    /// A view that describes the effect of calling the button's action.
    public let label: Label

    /// Performs the button's action.
    public func trigger() {
        action()
    }

    let action: ButtonAction

    init(role: ButtonRole?, action: ButtonAction) {
        self.label = Label()
        self.action = action
        self.role = role
    }
}

@available(*, unavailable)
extension PrimitiveButtonStyleConfiguration: Sendable {}

@available(*, unavailable)
extension PrimitiveButtonStyleConfiguration.Label: Sendable {}

// MARK: - View + PrimitiveButtonStyle

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Sets the style for buttons within this view to a button style with a
    /// custom appearance and custom interaction behavior.
    ///
    /// Use this modifier to set a specific style for button instances
    /// within a view:
    ///
    ///     HStack {
    ///         Button("Sign In", action: signIn)
    ///         Button("Register", action: register)
    ///     }
    ///     .buttonStyle(.bordered)
    ///
    nonisolated public func buttonStyle<S>(_ style: S) -> some View where S: PrimitiveButtonStyle {
        modifier(PrimitiveButtonStyleContainerModifier(style: style))
    }
}

// MARK: - ResolvedButtonStyle [Blocked by Navigation]

struct ResolvedButtonStyle: StyleableView {
    var configuration: PrimitiveButtonStyleConfiguration

    static var defaultStyleModifier: ButtonStyleModifier<DefaultButtonStyle> {
        ButtonStyleModifier(style: DefaultButtonStyle())
    }

    var body: some View {
        Button(configuration)
            // TODO: Apply ShowsNavigationIndicatorDisclosureIndicatorModifier.
            .transformPlatformItemList(LayoutPlatformItemListFlags.self) { [role = configuration.role] list in
                for index in list.items.indices {
                    list.items[index].buttonRole = role
                }
            }
            // TODO: Apply AccessibilityButtonModifier, including the app-intent action.
            .accessibilityShowsLargeContentViewer(.placeholder) {
                configuration.label
            }
            .modifier(
                KeyboardShortcutBindingBehavior(
                    action: configuration.trigger,
                    label: configuration.label
                )
                .requiring(NavigationButtonInput.Inverted.self)
            )
            // TODO: Apply DefinesSearchCompletionModifier in .textInputSuggestions.
            .input(TextSelectionForbidden.self)
            // TODO: Apply ButtonStyleDebugOverlayModifier when VisualizeViewsEnabled.
    }
}

// MARK: - ButtonStylePredicate

struct ButtonStylePredicate<Style>: ViewInputPredicate where Style: PrimitiveButtonStyle {
    static func evaluate(inputs: _GraphInputs) -> Bool {
        inputs[ButtonStyleInput.self].base == Style.self
    }
}

// MARK: - ButtonStyleModifier

struct ButtonStyleModifier<Style>: StyleModifier where Style: PrimitiveButtonStyle {
    var style: Style

    init(style: Style) {
        self.style = style
    }

    func styleBody(configuration: PrimitiveButtonStyleConfiguration) -> some View {
        style.makeBody(configuration: configuration)
    }
}

// MARK: - ButtonStyleContainerModifier [TODO]

struct ButtonStyleContainerModifier<Style>: ViewModifier where Style: ButtonStyle {
    var style: Style

    init(style: Style) {
        self.style = style
    }

    func body(content: Content) -> some View {
        content
            .modifier(ButtonStyleModifier(style: style))
            .modifier(ButtonStyleWriter<WrappedButtonStyle<Style>>())
            // TODO: Requires CustomButtonMenuStyleWriter and ButtonStyleAdaptorMenuStyle.
            // .modifier(CustomButtonMenuStyleWriter(style: style))
    }
}

// MARK: - PrimitiveButtonStyleContainerModifier [TODO]

struct PrimitiveButtonStyleContainerModifier<Style>: ViewModifier where Style: PrimitiveButtonStyle {
    var style: Style

    func body(content: Content) -> some View {
        content
            .modifier(ButtonStyleModifier(style: style))
            .modifier(ButtonStyleWriter<Style>())
            // TODO: Requires CustomButtonMenuStyleWriter and ButtonMenuStyle.Automatic.
            // .modifier(CustomButtonMenuStyleWriter(style: ButtonMenuStyle.Automatic()))
    }
}

// MARK: - ButtonStyleInput

struct ButtonStyleInput: ViewInput {
    static let defaultValue = AnyButtonStyleType(base: DefaultButtonStyle.self)
}

// MARK: - ButtonStyleWriter

private struct ButtonStyleWriter<Style>: _GraphInputsModifier, PrimitiveViewModifier where Style: PrimitiveButtonStyle {
    nonisolated static func _makeInputs(modifier: _GraphValue<Self>, inputs: inout _GraphInputs) {
        let style = AnyButtonStyleType(base: Style.self)
        inputs[ButtonStyleInput.self] = style
        if style.isTopLevelStyle {
            inputs[EffectiveButtonStyleInput.self] = style
        }
    }
}

// MARK: - AnyButtonStyleType

struct AnyButtonStyleType: Equatable, CustomStringConvertible {
    let base: any PrimitiveButtonStyle.Type

    static func == (lhs: AnyButtonStyleType, rhs: AnyButtonStyleType) -> Bool {
        lhs.base == rhs.base
    }

    var description: String {
        String(describing: base)
    }

    var isTopLevelStyle: Bool {
        base == DefaultButtonStyle.self
            || base == BorderedButtonStyle.self
            || base == BorderedProminentButtonStyle.self
            || base == PlainButtonStyle.self
            || base == BorderlessButtonStyle.self
    }
}

// MARK: - EffectiveButtonStyleInput

struct EffectiveButtonStyleInput: ViewInput {
    static let defaultValue = AnyButtonStyleType(base: DefaultButtonStyle.self)
}
