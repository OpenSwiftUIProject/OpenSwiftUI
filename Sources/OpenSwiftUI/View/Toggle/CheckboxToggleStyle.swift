//
//  CheckboxToggleStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 2F20E9A447C60EB3F3088D458F10BC97 (SwiftUI)

@_spi(Private)
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

#if os(macOS)
import AppKit
import COpenSwiftUI
#endif

// MARK: - ToggleStyle + CheckboxToggleStyle

@available(OpenSwiftUI_v1_0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension ToggleStyle where Self == CheckboxToggleStyle {
    /// A toggle style that displays a checkbox followed by its label.
    ///
    /// Apply this style to a ``Toggle`` or to a view hierarchy that contains
    /// toggles using the ``View/toggleStyle(_:)`` modifier:
    ///
    ///     Toggle("Close windows when quitting an app", isOn: $doesClose)
    ///         .toggleStyle(.checkbox)
    ///
    /// The style produces a label that describes the purpose of the toggle
    /// and a checkbox that shows the toggle's state. To change the toggle's
    /// state, the user clicks the checkbox or its label:
    ///
    /// ![A screenshot of a box with a checkmark in it, appearing to the left
    /// of a label which says: Close windows when quitting an
    /// app.](ToggleStyle-checkbox-1-macOS)
    ///
    /// The style aligns the trailing edge of the checkbox with the leading edge
    /// of the label, and takes as much horizontal space as it needs to fit the
    /// label, up to the amount offered by the toggle's parent view.
    ///
    /// This is the default style in macOS in most contexts when
    /// you don't set a style, or when you apply the ``ToggleStyle/automatic``
    /// style. A ``Form`` is a convenient way to present a collection of
    /// checkboxes with proper spacing and alignment. For guidance on using
    /// checkboxes in your user interface, see
    /// [Checkboxes](https://developer.apple.com/design/human-interface-guidelines/toggles#Checkboxes)
    /// in the Human Interface Guidelines.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var checkbox: CheckboxToggleStyle {
        .init()
    }
}

// MARK: - CheckboxToggleStyle

/// A toggle style that displays a checkbox followed by its label.
///
/// Use the ``ToggleStyle/checkbox`` static variable to create this style:
///
///     Toggle("Close windows when quitting an app", isOn: $doesClose)
///         .toggleStyle(.checkbox)
///
@available(OpenSwiftUI_v1_0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
public struct CheckboxToggleStyle: ToggleStyle {
    /// Creates a checkbox toggle style.
    ///
    /// Don't call this initializer directly. Instead, use the
    /// ``ToggleStyle/checkbox`` static variable to create this style:
    ///
    ///     Toggle("Close windows when quitting an app", isOn: $doesClose)
    ///         .toggleStyle(.checkbox)
    ///
    public init() {
        _openSwiftUIEmptyStub()
    }

    /// Creates a view that represents the body of a toggle checkbox.
    ///
    /// OpenSwiftUI implements this required method of the ``ToggleStyle``
    /// protocol to define the behavior and appearance of the
    /// ``ToggleStyle/checkbox`` toggle style. Don't call this method
    /// directly. Rather, the system calls this method for each
    /// ``Toggle`` instance in a view hierarchy that's styled as
    /// a checkbox.
    ///
    /// - Parameter configuration: The properties of the toggle, including a
    ///   label and a binding to the toggle's state.
    /// - Returns: A view that represents a checkbox.
    public func makeBody(configuration: Configuration) -> some View {
        Toggle(configuration)
            .toggleStyle(_CheckboxToggleStyle())
            .layoutValue(key: HorizintolControlGroupingItemKey.self, value: true)
    }
}

@available(*, unavailable)
extension CheckboxToggleStyle: Sendable {}

// MARK: - _CheckboxToggleStyle

struct _CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        #if os(macOS)
        let toggleState = {
            configuration.$isOn.wrappedValue.toggle()
        }
        return Button(action: toggleState) {
            configuration.label
                .buttonStyle(.automatic)
        }
        .buttonStyle(CheckboxButtonStyle(
            toggleState: configuration.toggleState,
            toggleAction: toggleState
        ))
        .focusEffectDisabled()
        #else
        EmptyView()
        #endif
    }
}

#if os(macOS)
// MARK: - CheckboxButtonStyle

private struct CheckboxButtonStyle: ButtonStyle {
    var toggleState: ToggleState
    var toggleAction: () -> Void

    @Environment(\.isEnabled)
    private var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        LabeledContent {
            Checkbox(state: toggleState, isPressed: configuration.isPressed, isEnabled: isEnabled)
                .contentShape(Rectangle())
                .alignmentGuide(.firstTextBaseline) { $0[.bottom] }
                .fixedSize()
                .accessibilityConfiguration(AccessibilityToggleModifier.Checkbox())
        } label: {
            configuration.label
        }
        .accessibilityLabeledContent()
        .modifier(
            StyleContextWriter<FormBoxStyleContext>()
                .requiring(StyleContextAcceptsPredicate<GroupedFormValueStyleContext>.Inverted.self)
        )
        .focusable(false, onFocusChange: { _ in })
    }
}

// MARK: - AccessibilityToggleModifier.Checkbox

extension AccessibilityToggleModifier {
    struct Checkbox: AccessibilityConfigurationModifier {
        func body(content: Content) -> some View {
            content
                .accessibilityCaptureViewResponders()
                .accessibilityAddTraits(.isCheckbox)
                .accessibilityIgnoreViewResponders()
        }
    }
}

// MARK: - Checkbox

private struct Checkbox: NSViewRepresentable {
    let state: ToggleState
    let isPressed: Bool
    let isEnabled: Bool

    func makeNSView(context: Context) -> FocusRingNSButton {
        let view = FocusRingNSButton(checkboxWithTitle: "", target: nil, action: nil)
        view.imagePosition = .imageOnly
        view.ignoreHitTest = true
        view.cell?.setAccessibilityElement(false)
        view.canShowFocusRing = true
        view.allowsMixedState = true
        return view
    }

    func updateNSView(_ nsView: FocusRingNSButton, context: Context) {
        nsView.state = switch state {
        case .on: .on
        case .off: .off
        case .mixed: .mixed
        }
        nsView.isEnabled = isEnabled
        nsView.highlight(isPressed)
    }
}

// MARK: - FormBoxStyleContext

struct FormBoxStyleContext: StyleContext {}

// MARK: - FormBoxLabeledContentStyle

struct FormBoxLabeledContentStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        _Body(configuration: configuration)
    }

    private struct _Body: View {
        var configuration: Configuration

        @Environment(\.controlSize)
        private var controlSize: ControlSize

        @Environment(\.isEnabled)
        private var isEnabled: Bool

        var body: some View {
            HStack(alignment: ._firstTextLineCenter, spacing: 0) {
                configuration.content
                    .contentShape(Rectangle())
                styledLabel
                    .defaultForegroundStyle(DisabledForegroundStyle(isDisabled: !isEnabled))
            }
            .spacing(Spacing())
        }

        private var styledLabel: some View {
            StaticIf(_SemanticFeature_v4.self) {
                _VariadicView.Tree(LabelRoot(
                    leadingPadding: leadingPadding,
                    trailingPadding: 0,
                    style: FormBoxLabelGroupStyle(controlSize: controlSize)
                )) {
                    configuration.label
                }
            } else: {
                configuration.label
                    .padding(.leading, leadingPadding)
                    .contentShape(Rectangle())
            }
        }

        private var leadingPadding: Double {
            switch controlSize {
            case .mini: 1
            case .small: 4
            default: 5
            }
        }
    }

    struct LabelRoot<Style>: _VariadicView.UnaryViewRoot where Style: LabelGroupStyle_v0 {
        var leadingPadding: Double
        var trailingPadding: Double
        var style: Style

        private struct EnumeratedView {
            var view: _VariadicView.Children.Element
            var offset: Int
        }

        func stackBody(children: _VariadicView.Children) -> some View {
            LabelGroup {
                ForEach(
                    children.enumerated().map { EnumeratedView(view: $0.element, offset: $0.offset) },
                    id: \.view.id
                ) { view in
                    view.view
                        .padding(.leading, leadingPadding)
                        .padding(.trailing, trailingPadding)
                        .contentShape(Rectangle())
                        .allowsHitTesting(view.offset == 0)
                }
            }
            .labelGroupStyle_v0(style)
        }

        func body(children: _VariadicView.Children) -> some View {
            StaticIf(in: GroupedFormStyleContext()) {
                VStack(alignment: stackAlignment, spacing: 2) {
                    stackBody(children: children)
                }
            } else: {
                VStack(alignment: stackAlignment) {
                    stackBody(children: children)
                }
            }
        }
    }
}

private let stackAlignment: HorizontalAlignment = .leading

// MARK: - FormBoxLabelGroupStyle

private struct FormBoxLabelGroupStyle: LabelGroupStyle_v0 {
    var controlSize: ControlSize

    func font(at level: Int) -> Font {
        switch controlSize {
        case .mini, .small: ._system(controlSize: controlSize)
        default: BodyLabelGroupStyle().font(at: level)
        }
    }

    func foregroundStyle(at level: Int) -> HierarchicalShapeStyle {
        BodyLabelGroupStyle().foregroundStyle(at: level)
    }
}

// MARK: - DisabledForegroundStyle

private struct DisabledForegroundStyle: ShapeStyle {
    var isDisabled: Bool
    var base: AnyShapeStyle?

    func _apply(to shape: inout _ShapeStyle_Shape) {
        switch shape.operation {
        case .copyStyle:
            if let foregroundStyle = shape.currentForegroundStyle {
                let base = foregroundStyle.primaryStyle(in: shape.environment) ?? foregroundStyle
                shape.result = .style(AnyShapeStyle(DisabledForegroundStyle(isDisabled: isDisabled, base: base)))
            }
        case .primaryStyle:
            break
        default:
            (base ?? LegacyContentStyle.sharedPrimary)
                .offset(by: isDisabled ? 2 : 0)
                ._apply(to: &shape)
        }
    }
}
#endif
