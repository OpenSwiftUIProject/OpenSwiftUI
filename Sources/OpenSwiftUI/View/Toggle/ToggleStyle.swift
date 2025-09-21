//
//  ToggleStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Blocked by ArchivedView
//  ID: FB08626C1326F7E32DC674FF8C676196 (SwiftUI)

@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - ToggleStyle

/// The appearance and behavior of a toggle.
///
/// To configure the style for a single ``Toggle`` or for all toggle instances
/// in a view hierarchy, use the ``View/toggleStyle(_:)`` modifier. You can
/// specify one of the built-in toggle styles, like ``ToggleStyle/switch`` or
/// ``ToggleStyle/button``:
///
///     Toggle(isOn: $isFlagged) {
///         Label("Flag", systemImage: "flag.fill")
///     }
///     .toggleStyle(.button)
///
/// Alternatively, you can create and apply a custom style.
///
/// ### Custom styles
///
/// To create a custom style, declare a type that conforms to the `ToggleStyle`
/// protocol and implement the required ``ToggleStyle/makeBody(configuration:)``
/// method. For example, you can define a checklist toggle style:
///
///     struct ChecklistToggleStyle: ToggleStyle {
///         func makeBody(configuration: Configuration) -> some View {
///             // Return a view that has checklist appearance and behavior.
///         }
///     }
///
/// Inside the method, use the `configuration` parameter, which is an instance
/// of the ``ToggleStyleConfiguration`` structure, to get the label and
/// a binding to the toggle state. To see examples of how to use these items
/// to construct a view that has the appearance and behavior of a toggle, see
/// ``ToggleStyle/makeBody(configuration:)``.
///
/// To provide easy access to the new style, declare a corresponding static
/// variable in an extension to `ToggleStyle`:
///
///     extension ToggleStyle where Self == ChecklistToggleStyle {
///         static var checklist: ChecklistToggleStyle { .init() }
///     }
///
/// You can then use your custom style:
///
///     Toggle(activity.name, isOn: $activity.isComplete)
///         .toggleStyle(.checklist)
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
@MainActor
@preconcurrency
public protocol ToggleStyle {

    /// A view that represents the appearance and interaction of a toggle.
    ///
    /// OpenSwiftUI infers this type automatically based on the ``View``
    /// instance that you return from your implementation of the
    /// ``makeBody(configuration:)`` method.
    associatedtype Body: View

    /// Creates a view that represents the body of a toggle.
    ///
    /// Implement this method when you define a custom toggle style that
    /// conforms to the ``ToggleStyle`` protocol. Use the `configuration`
    /// input --- a ``ToggleStyleConfiguration`` instance --- to access the
    /// toggle's label and state. Return a view that has the appearance and
    /// behavior of a toggle. For example you can create a toggle that displays
    /// a label and a circle that's either empty or filled with a checkmark:
    ///
    ///     struct ChecklistToggleStyle: ToggleStyle {
    ///         func makeBody(configuration: Configuration) -> some View {
    ///             Button {
    ///                 configuration.isOn.toggle()
    ///             } label: {
    ///                 HStack {
    ///                     Image(systemName: configuration.isOn
    ///                             ? "checkmark.circle.fill"
    ///                             : "circle")
    ///                     configuration.label
    ///                 }
    ///             }
    ///             .tint(.primary)
    ///             .buttonStyle(.borderless)
    ///         }
    ///     }
    ///
    /// The `ChecklistToggleStyle` toggle style provides a way to both observe
    /// and modify the toggle state: the circle fills for the on state, and
    /// users can tap or click the toggle to change the state. By using a
    /// customized ``Button`` to compose the toggle's body, OpenSwiftUI
    /// automatically provides the behaviors that users expect from a
    /// control that has button-like characteristics.
    ///
    /// You can present a collection of toggles that use this style in a stack:
    ///
    /// ![A screenshot of three items stacked vertically. All have a circle
    /// followed by a label. The first has the label Walk the dog, and the
    /// circle is filled. The second has the label Buy groceries, and the
    /// circle is filled. The third has the label Call Mom, and the cirlce is
    /// empty.](ToggleStyle-makeBody-1-iOS)
    ///
    /// When updating a view hierarchy, the system calls your implementation
    /// of the `makeBody(configuration:)` method for each ``Toggle`` instance
    /// that uses the associated style.
    ///
    /// ### Modify the current style
    ///
    /// Rather than create an entirely new style, you can alternatively
    /// modify a toggle's current style. Use the ``Toggle/init(_:)``
    /// initializer inside the `makeBody(configuration:)` method to create
    /// and modify a toggle based on a `configuration` value. For example,
    /// you can create a style that adds padding and a red border to the
    /// current style:
    ///
    ///     struct RedBorderToggleStyle: ToggleStyle {
    ///         func makeBody(configuration: Configuration) -> some View {
    ///             Toggle(configuration)
    ///                 .padding()
    ///                 .border(.red)
    ///         }
    ///     }
    ///
    /// If you create a `redBorder` static variable from this style,
    /// you can apply the style to toggles that already use another style, like
    /// the built-in ``ToggleStyle/switch`` and ``ToggleStyle/button`` styles:
    ///
    ///     Toggle("Switch", isOn: $isSwitchOn)
    ///         .toggleStyle(.redBorder)
    ///         .toggleStyle(.switch)
    ///
    ///     Toggle("Button", isOn: $isButtonOn)
    ///         .toggleStyle(.redBorder)
    ///         .toggleStyle(.button)
    ///
    /// Both toggles appear with the usual styling, each with a red border:
    ///
    /// ![A screenshot of a switch toggle with a red border, and a button
    /// toggle with a red border.](ToggleStyle-makeBody-2-iOS)
    ///
    /// Apply the custom style closer to the toggle than the
    /// modified style because OpenSwiftUI evaluates style view modifiers in order
    /// from outermost to innermost. If you apply the styles in the other
    /// order, the red border style doesn't have an effect, because the
    /// built-in styles override it completely.
    ///
    /// - Parameter configuration: The properties of the toggle, including a
    ///   label and a binding to the toggle's state.
    /// - Returns: A view that has behavior and appearance that enables it
    ///   to function as a ``Toggle``.
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Self.Body

    /// The properties of a toggle instance.
    ///
    /// You receive a `configuration` parameter of this type --- which is an
    /// alias for the ``ToggleStyleConfiguration`` type --- when you implement
    /// the required ``makeBody(configuration:)`` method in a custom toggle
    /// style implementation.
    typealias Configuration = ToggleStyleConfiguration
}

// MARK: - ToggleStyleConfiguration [WIP]

/// The properties of a toggle instance.
///
/// When you define a custom toggle style by creating a type that conforms to
/// the ``ToggleStyle`` protocol, you implement the
/// ``ToggleStyle/makeBody(configuration:)`` method. That method takes a
/// `ToggleStyleConfiguration` input that has the information you need
/// to define the behavior and appearance of a ``Toggle``.
///
/// The configuration structure's ``label-swift.property`` reflects the
/// toggle's content, which might be the value that you supply to the
/// `label` parameter of the ``Toggle/init(isOn:label:)`` initializer.
/// Alternatively, it could be another view that OpenSwiftUI builds from an
/// initializer that takes a string input, like ``Toggle/init(_:isOn:)``.
/// In either case, incorporate the label into the toggle's view to help
/// the user understand what the toggle does. For example, the built-in
/// ``ToggleStyle/switch`` style horizontally stacks the label with the
/// control element.
///
/// The structure's ``isOn`` property provides a ``Binding`` to the state
/// of the toggle. Adjust the appearance of the toggle based on this value.
/// For example, the built-in ``ToggleStyle/button`` style fills the button's
/// background when the property is `true`, but leaves the background empty
/// when the property is `false`. Change the value when the user performs
/// an action that's meant to change the toggle, like the button does when
/// tapped or clicked by the user.
public struct ToggleStyleConfiguration {
    /// A type-erased label of a toggle.
    ///
    /// OpenSwiftUI provides a value of this type --- which is a ``View`` type ---
    /// as the ``label-swift.property`` to your custom toggle style
    /// implementation. Use the label to help define the appearance of the
    /// toggle.
    public struct Label: ViewAlias {
        nonisolated init() {}
    }

    /// A view that describes the effect of switching the toggle between states.
    ///
    /// Use this value in your implementation of the
    /// ``ToggleStyle/makeBody(configuration:)`` method when defining a custom
    /// ``ToggleStyle``. Access it through the that method's `configuration`
    /// parameter.
    ///
    /// Because the label is a ``View``, you can incorporate it into the
    /// view hierarchy that you return from your style definition. For example,
    /// you can combine the label with a circle image in an ``HStack``:
    ///
    ///     HStack {
    ///         Image(systemName: configuration.isOn
    ///             ? "checkmark.circle.fill"
    ///             : "circle")
    ///         configuration.label
    ///     }
    ///
    public let label: ToggleStyleConfiguration.Label

    /// A binding to a state property that indicates whether the toggle is on.
    ///
    /// Because this value is a ``Binding``, you can both read and write it
    /// in your implementation of the ``ToggleStyle/makeBody(configuration:)``
    /// method when defining a custom ``ToggleStyle``. Access it through
    /// that method's `configuration` parameter.
    ///
    /// Read this value to set the appearance of the toggle. For example, you
    /// can choose between empty and filled circles based on the `isOn` value:
    ///
    ///     Image(systemName: configuration.isOn
    ///         ? "checkmark.circle.fill"
    ///         : "circle")
    ///
    /// Write this value when the user takes an action that's meant to change
    /// the state of the toggle. For example, you can toggle it inside the
    /// `action` closure of a ``Button`` instance:
    ///
    ///     Button {
    ///         configuration.isOn.toggle()
    ///     } label: {
    ///         // Draw the toggle.
    ///     }
    ///
    @Binding
    public var isOn: Bool

    @Binding
    private var toggleState: ToggleState

    /// Whether the ``Toggle`` is currently in a mixed state.
    ///
    /// Use this property to determine whether the toggle style should render
    /// a mixed state presentation. A mixed state corresponds to an underlying
    /// collection with a mix of true and false Bindings.
    /// To toggle the state, use the ``Bool.toggle()`` method on the ``isOn``
    /// binding.
    ///
    /// In the following example, a custom style uses the `isMixed` property
    /// to render the correct toggle state using symbols:
    ///
    ///     struct SymbolToggleStyle: ToggleStyle {
    ///         func makeBody(configuration: Configuration) -> some View {
    ///             Button {
    ///                 configuration.isOn.toggle()
    ///             } label: {
    ///                 Image(
    ///                     systemName: configuration.isMixed
    ///                     ? "minus.circle.fill" : configuration.isOn
    ///                     ? "checkmark.circle.fill" : "circle.fill")
    ///                 configuration.label
    ///             }
    ///         }
    ///     }
    @available(OpenSwiftUI_v4_0, *)
    public var isMixed: Bool

    enum Effect {
        // case appIntent(AppIntentAction)
        case binding
    }

    var effect: Effect

    init(
        label: ToggleStyleConfiguration.Label,
        isOn: Binding<Bool>,
        toggleState: Binding<ToggleState>,
        isMixed: Bool,
        effect: Effect
    ) {
        self.label = label
        self._isOn = isOn
        self._toggleState = toggleState
        self.isMixed = isMixed
        self.effect = effect
    }
}

@available(*, unavailable)
extension ToggleStyleConfiguration: Sendable {}

@available(*, unavailable)
extension ToggleStyleConfiguration.Label: Sendable {}

// MARK: - ToggleStateBool

struct ToggleStateBool: Projection {
    typealias Base = ToggleState

    typealias Projected = Bool

    func get(base: ToggleState) -> Bool {
        base == .on
    }

    func set(base: inout ToggleState, newValue: Bool) {
        base = newValue ? .on : .off
    }
}

// MARK: - ResolvedToggleStyle

struct ResolvedToggleStyle: StyleableView {
    var configuration: ToggleStyleConfiguration

    static var defaultStyleModifier = ToggleStyleModifier(style: .switch)
}

// MARK: - ToggleStyleModifier

struct ToggleStyleModifier<Style>: StyleModifier where Style: ToggleStyle {
    init(style: Style) {
        self.style = style
    }

    var style: Style

    func styleBody(configuration: Style.Configuration) -> Style.Body {
        style.makeBody(configuration: configuration)
    }
}

extension View {
    /// Sets the style for toggles in a view hierarchy.
    ///
    /// Use this modifier on a ``Toggle`` instance to set a style that defines
    /// the control's appearance and behavior. For example, you can choose
    /// the ``ToggleStyle/switch`` style:
    ///
    ///     Toggle("Vibrate on Ring", isOn: $vibrateOnRing)
    ///         .toggleStyle(.switch)
    ///
    /// Built-in styles typically have a similar appearance across platforms,
    /// tailored to the platform's overall style:
    ///
    /// | Platform    | Appearance |
    /// |-------------|------------|
    /// | iOS, iPadOS | ![A screenshot of the text Vibrate on Ring appearing to the left of a toggle switch that's on. The toggle's tint color is green. The toggle and its text appear in a rounded rectangle.](View-toggleStyle-1-iOS) |
    /// | macOS       | ![A screenshot of the text Vibrate on Ring appearing to the left of a toggle switch that's on. The toggle's tint color is blue. The toggle and its text appear on a neutral background.](View-toggleStyle-1-macOS) |
    ///
    /// ### Styling toggles in a hierarchy
    ///
    /// You can set a style for all toggle instances within a view hierarchy
    /// by applying the style modifier to a container view. For example, you
    /// can apply the ``ToggleStyle/button`` style to an ``HStack``:
    ///
    ///     HStack {
    ///         Toggle(isOn: $isFlagged) {
    ///             Label("Flag", systemImage: "flag.fill")
    ///         }
    ///         Toggle(isOn: $isMuted) {
    ///             Label("Mute", systemImage: "speaker.slash.fill")
    ///         }
    ///     }
    ///     .toggleStyle(.button)
    ///
    /// The example above has the following appearance when `isFlagged` is
    /// `true` and `isMuted` is `false`:
    ///
    /// | Platform    | Appearance |
    /// |-------------|------------|
    /// | iOS, iPadOS | ![A screenshot of two buttons arranged horizontally. The first has the image of a flag and is active with a blue tint. The second has an image of a speaker with a line through it and is inactive with a neutral tint.](View-toggleStyle-2-iOS) |
    /// | macOS       | ![A screenshot of two buttons arranged horizontally. The first has the image of a flag and is active with a blue tint. The second has an image of a speaker with a line through it and is inactive with a neutral tint.](View-toggleStyle-2-macOS) |
    ///
    /// ### Automatic styling
    ///
    /// If you don't set a style, OpenSwiftUI assumes a value of
    /// ``ToggleStyle/automatic``, which corresponds to a context-specific
    /// default. Specify the automatic style explicitly to override a
    /// container's style and revert to the default:
    ///
    ///     HStack {
    ///         Toggle(isOn: $isShuffling) {
    ///             Label("Shuffle", systemImage: "shuffle")
    ///         }
    ///         Toggle(isOn: $isRepeating) {
    ///             Label("Repeat", systemImage: "repeat")
    ///         }
    ///
    ///         Divider()
    ///
    ///         Toggle("Enhance Sound", isOn: $isEnhanced)
    ///             .toggleStyle(.automatic) // Revert to the default style.
    ///     }
    ///     .toggleStyle(.button) // Use button style for toggles in the stack.
    ///     .labelStyle(.iconOnly) // Omit the title from any labels.
    ///
    /// The style that OpenSwiftUI uses as the default depends on both the platform
    /// and the context. In macOS, the default in most contexts is a
    /// ``ToggleStyle/checkbox``, while in iOS, the default toggle style is a
    /// ``ToggleStyle/switch``:
    ///
    /// | Platform    | Appearance |
    /// |-------------|------------|
    /// | iOS, iPadOS | ![A screenshot of several horizontally arranged items: two buttons, a vertical divider line, the text Enhance sound, and a switch. The first button has two right facing arrows that cross over in the middle and is active with a blue tint. The second button has one right and one left facing arrow and is inactive with neutral tint. The switch is on and has a green tint.](View-toggleStyle-3-iOS) |
    /// | macOS       | ![A screenshot of several horizontally arranged items: two buttons, a vertical divider line, a checkbox, and the text Enhance sound. The first button has two right facing arrows that cross over in the middle and is active with a blue tint. The second button has one right and one left facing arrow and is inactive with a neutral tint. The check box is checked and has a blue tint.](View-toggleStyle-3-macOS) |
    ///
    /// > Note: Like toggle style does for toggles, the ``View/labelStyle(_:)``
    /// modifier sets the style for ``Label`` instances in the hierarchy. The
    /// example above demostrates the compact ``LabelStyle/iconOnly`` style,
    /// which is useful for button toggles in space-constrained contexts.
    /// Always include a descriptive title for better accessibility.
    ///
    /// For more information about how OpenSwiftUI chooses a default toggle style,
    /// see the ``ToggleStyle/automatic`` style.
    ///
    /// - Parameter style: The toggle style to set. Use one of the built-in
    ///   values, like ``ToggleStyle/switch`` or ``ToggleStyle/button``,
    ///   or a custom style that you define by creating a type that conforms
    ///   to the ``ToggleStyle`` protocol.
    ///
    /// - Returns: A view that uses the specified toggle style for itself
    ///   and its child views.
    nonisolated public func toggleStyle<S>(_ style: S) -> some View where S: ToggleStyle {
        modifier(ToggleStyleModifier(style: style))
    }
}

// TODO: Toggle + Archive stuff
