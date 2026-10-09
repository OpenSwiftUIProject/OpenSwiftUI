//
//  ButtonStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Partial-Stubbed
//  ID: AEEDD090E917AC57C12008D974DC6805 (SwiftUI)

import OpenAttributeGraphShims
@_spi(Private) public import OpenSwiftUICore

// MARK: - ButtonStyle

/// A type that applies standard interaction behavior and a custom appearance to
/// all buttons within a view hierarchy.
///
/// To configure the current button style for a view hierarchy, use the
/// ``View/buttonStyle(_:)`` modifier. Specify a style that conforms to
/// `ButtonStyle` when creating a button that uses the standard button
/// interaction behavior defined for each platform. To create a button with
/// custom interaction behavior, use ``PrimitiveButtonStyle`` instead.
@available(OpenSwiftUI_v1_0, *)
@preconcurrency
@MainActor
public protocol ButtonStyle {
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
    typealias Configuration = ButtonStyleConfiguration
}

/// The properties of a button.
@available(OpenSwiftUI_v1_0, *)
public struct ButtonStyleConfiguration {
    /// A type-erased label of a button.
    public struct Label: ViewAlias {
        public typealias Body = Never

        nonisolated package init() {
            _openSwiftUIEmptyStub()
        }
    }

    /// An optional semantic role that describes the button's purpose.
    ///
    /// A value of `nil` means that the Button doesn't have an assigned role. If
    /// the button does have a role, use it to make adjustments to the button's
    /// appearance. The following example shows a custom style that uses
    /// bold text when the role is ``ButtonRole/cancel``,
    /// ``ShapeStyle/red`` text when the role is ``ButtonRole/destructive``,
    /// and adds no special styling otherwise:
    ///
    ///     struct MyButtonStyle: ButtonStyle {
    ///         func makeBody(configuration: Configuration) -> some View {
    ///             configuration.label
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
    /// letters.](ButtonStyleConfiguration-role-1)
    @available(OpenSwiftUI_v3_0, *)
    public let role: ButtonRole?

    /// A view that describes the effect of pressing the button.
    public let label: Label

    /// A Boolean that indicates whether the user is currently pressing the
    /// button.
    public let isPressed: Bool

    init(isPressed: Bool, role: ButtonRole?) {
        self.label = Label()
        self.isPressed = isPressed
        self.role = role
    }
}

@available(*, unavailable)
extension ButtonStyleConfiguration: Sendable {}

@available(*, unavailable)
extension ButtonStyleConfiguration.Label: Sendable {}

// MARK: - View + ButtonStyle

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Sets the style for buttons within this view to a button style with a
    /// custom appearance and standard interaction behavior.
    ///
    /// Use this modifier to set a specific style for all button instances
    /// within a view:
    ///
    ///     HStack {
    ///         Button("Sign In", action: signIn)
    ///         Button("Register", action: register)
    ///     }
    ///     .buttonStyle(.bordered)
    ///
    /// You can also use this modifier to set the style for controls that
    /// acquire a button style through composition, like the
    /// ``Menu`` and
    /// ``Toggle`` views in the following example:
    ///
    ///     VStack {
    ///         Menu("Terms and Conditions") {
    ///             Button("Open in Preview", action: openInPreview)
    ///             Button("Save as PDF", action: saveAsPDF)
    ///         }
    ///         Toggle("Remember Password", isOn: $isToggleOn)
    ///         Toggle("Flag", isOn: $flagged)
    ///         Button("Sign In", action: signIn)
    ///     }
    ///     .menuStyle(.button)
    ///     .toggleStyle(.button)
    ///     .buttonStyle(.bordered)
    ///
    /// The
    /// ``View/menuStyle(_:)``
    /// modifier causes the Terms and Conditions menu to render as a button.
    /// Similarly, the
    /// ``View/toggleStyle(_:)`` modifier causes the two toggles to
    /// render as buttons. The button style modifier then causes not only
    /// the explicit Sign In ``Button``, but also the menu and toggles with
    /// button styling, to render with the bordered button style.
    nonisolated public func buttonStyle<S>(_ style: S) -> some View where S: ButtonStyle {
        modifier(ButtonStyleContainerModifier(style: style))
    }
}

@_spi(UIFrameworks)
@available(OpenSwiftUI_v4_0, *)
public protocol ButtonStyleConvertible {
    associatedtype ButtonStyleRepresentation: ButtonStyle

    var buttonStyleRepresentation: ButtonStyleRepresentation { get }
}

// MARK: - ButtonStyleModifier + ButtonStyle

extension ButtonStyleModifier {
    init<S>(style: S) where Style == WrappedButtonStyle<S>, S: ButtonStyle {
        self.init(style: WrappedButtonStyle(style: style))
    }
}

// TODO: ArchivableLinkModifier

// MARK: - WrappedButtonStyle

struct WrappedButtonStyle<Style>: PrimitiveButtonStyle where Style: ButtonStyle {
    let style: Style

    init(style: Style) {
        self.style = style
    }

    func makeBody(configuration: Configuration) -> some View {
        WrappedButtonStyleBody(style: style, configuration: configuration)
    }
}

extension WrappedButtonStyle: AnyDefaultStyle where Style: AnyDefaultStyle {
    init() {
        self.init(style: Style())
    }
}

// TODO: ArchivableButtonAppIntentModifier

// TODO: LinkButtonModifierBody

// MARK: - ResolvedButtonStyleBody

struct ResolvedButtonStyleBody<Style>: PrimitiveView where Style: ButtonStyle {
    var style: Style
    var configuration: ButtonStyleConfiguration

    nonisolated static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        var inputs = inputs
        let fields = DynamicPropertyCache.fields(of: Style.self)
        let (body, buffer) = makeStyleBody(
            view: view,
            inputs: &inputs.base,
            fields: fields
        )
        let outputs = Style.Body.makeDebuggableView(view: body, inputs: inputs)
        if let buffer {
            buffer.traceMountedProperties(to: view, fields: fields)
        }
        return outputs
    }

    nonisolated static func _makeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        var inputs = inputs
        let fields = DynamicPropertyCache.fields(of: Style.self)
        let (body, buffer) = makeStyleBody(
            view: view,
            inputs: &inputs.base,
            fields: fields
        )
        let outputs = Style.Body.makeDebuggableViewList(view: body, inputs: inputs)
        if let buffer {
            buffer.traceMountedProperties(to: view, fields: fields)
        }
        return outputs
    }

    nonisolated private static func makeStyleBody(
        view: _GraphValue<Self>,
        inputs: inout _GraphInputs,
        fields: DynamicPropertyCache.Fields
    ) -> (_GraphValue<Style.Body>, _DynamicPropertyBuffer?) {
        if Semantics.ViewStylesMustBeValueTypes.isEnabled {
            precondition(
                Metadata(Style.self).isValueType,
                "styles must be value types (either a struct or an enum); \(Style.self) is a class."
            )
        }
        let accessor = StyleBodyAccessor(view: view.value)
        return accessor.makeBody(
            container: view[offset: { .of(&$0.style) }],
            inputs: &inputs,
            fields: fields
        )
    }

    private struct StyleBodyAccessor: BodyAccessor {
        @Attribute var view: ResolvedButtonStyleBody<Style>

        typealias Container = Style
        typealias Body = Style.Body

        func updateBody(of container: Style, changed: Bool) {
            let (view, viewChanged) = $view.changedValue()
            guard changed || viewChanged else {
                return
            }
            setBody {
                container.makeBody(configuration: view.configuration)
            }
        }
    }
}

// MARK: - ButtonBehavior [TODO]

struct ButtonBehavior<Content>: View where Content: View {
    var touchDelay: Double?
    var action: () -> Void
    var onPress: (Bool) -> Void
    var content: (Bool) -> Content
    var pressStateAnimationProvider: ((ButtonInteractionPhase) -> Animation?)?

    @State private var state = StateType(
        interactionPhase: .inactive,
        didPerformInitialPress: false
    )

    private struct StateType {
        var interactionPhase: ButtonInteractionPhase
        var didPerformInitialPress: Bool
    }

    init(
        touchDelay: Double? = nil,
        action: @escaping () -> Void,
        onPress: @escaping (Bool) -> Void = { _ in },
        content: @escaping (Bool) -> Content,
        pressStateAnimationProvider: ((ButtonInteractionPhase) -> Animation?)? = nil
    ) {
        self.touchDelay = touchDelay
        self.action = action
        self.onPress = onPress
        self.content = content
        self.pressStateAnimationProvider = pressStateAnimationProvider
    }

    private var animation: Animation? {
        if let pressStateAnimationProvider {
            return pressStateAnimationProvider(state.interactionPhase)
        }
        if case .active(isPressed: true, hasTriggeredInitialAction: _) = state.interactionPhase,
           !state.didPerformInitialPress {
            return .coreAnimationDefault(duration: 0)
        }
        return .coreAnimationDefault(duration: 0.47)
    }

    var body: some View {
        let isPressed: Bool
        switch state.interactionPhase {
        case let .active(pressed, _):
            isPressed = pressed
        case .inactive:
            isPressed = false
        }
        var gesture = _ButtonGesture(action: ended, pressing: pressing)
        gesture.touchDelay = touchDelay
        return StaticIf(_SemanticFeature_v3.self) {
            VStack {
                content(isPressed)
            }
        } else: {
            content(isPressed)
        }
        .modifier(ButtonActionModifier(
            gesture: gesture.onFailed {
                state.interactionPhase = .inactive
            }
            .debugLabel("Button<\(_typeName(Content.self, qualified: false))>"),
            action: action
        ))
        .animation(animation, value: state.interactionPhase)
        // TODO: ButtonFocusInteractionModifier for FocusableCustomButtonStyleFeature.
        // TODO: ButtonRepeatModifier for custom button repeat behavior.
        // TODO: ButtonSpringLoadedInteraction for custom spring loading behavior.
    }

    private func ended() {
        if case .inactive = state.interactionPhase {
            pressing(true)
            Transaction._core_barrier()
        }
        switch state.interactionPhase {
        case .active(isPressed: _, hasTriggeredInitialAction: true):
            break
        default:
            action()
        }
        state.interactionPhase = .inactive
    }

    private func pressing(_ isPressed: Bool) {
        onPress(isPressed)
        let hasTriggeredInitialAction: Bool
        switch state.interactionPhase {
        case let .active(_, triggered):
            state.didPerformInitialPress = true
            hasTriggeredInitialAction = triggered
        case .inactive:
            state.didPerformInitialPress = false
            hasTriggeredInitialAction = false
        }
        state.interactionPhase = .active(
            isPressed: isPressed,
            hasTriggeredInitialAction: hasTriggeredInitialAction
        )
    }
}

// MARK: - WrappedButtonStyleBody [TODO]

private struct WrappedButtonStyleBody<Style>: ConditionallyArchivableView where Style: ButtonStyle {
    let style: Style
    let configuration: PrimitiveButtonStyleConfiguration

    init(style: Style, configuration: PrimitiveButtonStyleConfiguration) {
        self.style = style
        self.configuration = configuration
    }

    var body: some View {
        let button = ButtonBehavior(action: configuration.trigger) { isPressed in
            ResolvedButtonStyleBody(
                style: style,
                configuration: .init(isPressed: isPressed, role: configuration.role)
            )
        }
        return StaticIf(idiom: .clarityUI) {
            var button = button
            button.pressStateAnimationProvider = { phase in
                if case .active(isPressed: true, hasTriggeredInitialAction: _) = phase {
                    .coreAnimationDefault(duration: 0.2)
                } else {
                    .coreAnimationDefault(duration: 0.47)
                }
            }
            return button
        } else: {
            button
        }
    }

    var archivedBody: some View {
        // TODO: ArchiveBody
        // TODO: ArchivesInteractiveControlsEffect
        // TODO: HandGestureShortcutInteractiveControl
        _openSwiftUIUnimplementedFailure()
    }
}

// TODO: ButtonSpringLoadedInteraction

// TODO: ButtonRepeatModifier

// TODO: ButtonFocusInteractionModifier

// MARK: - ButtonInteractionPhase

enum ButtonInteractionPhase: Equatable {
    case active(isPressed: Bool, hasTriggeredInitialAction: Bool)
    case inactive
}
