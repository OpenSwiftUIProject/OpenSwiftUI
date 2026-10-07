//
//  BorderlessButtonStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 8946ABD13E6925C5D5FDD316D4A45F59 (SwiftUI)

public import OpenSwiftUICore

// MARK: - PrimitiveButtonStyle + BorderlessButtonStyle

@available(OpenSwiftUI_v1_0, *)
extension PrimitiveButtonStyle where Self == BorderlessButtonStyle {
    /// A button style that doesn't apply a border.
    ///
    /// To apply this style to a button, or to a view that contains buttons, use
    /// the ``View/buttonStyle(_:)`` modifier.
    ///
    /// On tvOS, this button style adds a default hover effect to the first
    /// image of the button's content, if one exists. You can supply a different
    /// hover effect by using the ``View/hoverEffect(_:)`` modifier in the
    /// button's label.
    @_alwaysEmitIntoClient
    public static var borderless: BorderlessButtonStyle {
        BorderlessButtonStyle()
    }
}

// MARK: - BorderlessButtonStyle

/// A button style that doesn't apply a border.
///
/// You can also use ``PrimitiveButtonStyle/borderless`` to construct this
/// style.
@available(OpenSwiftUI_v1_0, *)
public struct BorderlessButtonStyle: PrimitiveButtonStyle {
    @Environment(\.tintColor)
    private var controlTint: Color?

    #if os(macOS)
    @Environment(\.isToggleOn)
    private var isOn: Bool?
    #endif

    @Environment(\.accessibilityShowButtonShapes)
    private var showsShapes: Bool

    /// Creates a borderless button style.
    public init() {
        _openSwiftUIEmptyStub()
    }

    #if os(macOS)
    private var resolvedTint: Color? {
        switch isOn {
        case nil: controlTint
        case true?: controlTint ?? .accentColor
        case false?: .secondary
        }
    }
    #endif

    public func makeBody(configuration: Configuration) -> some View {
        Button(configuration)
            .modifier(
                StaticIf(in: .menu) {
                    PrimitiveButtonStyleContainerModifier(style: PlatformItemListButtonStyle())
                } else: {
                    EmptyModifier()
                }
            )
            #if os(macOS)
            .buttonStyle(AppKitButtonStyle(appearance: .borderless(tint: resolvedTint)))
            #else
            .buttonStyle(buttonStyleRepresentation)
            .underline(showsShapes, color: controlTint)
            #endif
    }
}

@available(*, unavailable)
extension BorderlessButtonStyle: Sendable {}

#if !os(macOS)

// MARK: - BorderlessButtonStyle + ButtonStyleConvertible

@_spi(UIFrameworks)
extension BorderlessButtonStyle: ButtonStyleConvertible {
    @MainActor
    @preconcurrency
    public var buttonStyleRepresentation: some ButtonStyle {
        BorderlessButtonStyleBase()
    }
}

// MARK: - BorderlessButtonStyleBase

private struct BorderlessButtonStyleBase: ButtonStyle {
    @Environment(\.keyboardShortcut) var keyboardShortcut: KeyboardShortcut?
    @Environment(\.controlSize) var controlSize: ControlSize
    @Environment(\.isEnabled) var isEnabled: Bool

    init() {
        _openSwiftUIEmptyStub()
    }

    var defaultWeight: Font.Weight {
        keyboardShortcut == .defaultAction ? .semibold : .regular
    }

    var defaultFont: Font {
        let style: Font.TextStyle = switch controlSize {
        case .mini: .subheadline
        case .small: .subheadline
        case .regular: .body
        case .large: .body
        case .extraLarge: .body
        }
        return .system(style, design: nil, weight: defaultWeight)
    }

    func makeBody(configuration: Configuration) -> some View {
        let label = HStack {
            configuration.label
                .modifier(OpacityButtonHighlightModifier(highlighted: configuration.isPressed))
        }
        .contentShape(Rectangle())
        .environment(\.defaultFont, defaultFont)
        .multilineTextAlignment(isLinkedOnOrAfter(.v3) ? .center : .leading)
        .buttonDefaultRenderingMode()
        .defaultForegroundStyle(BorderlessButtonLabelShapeStyle(
            role: configuration.role,
            isEnabled: isEnabled,
            defaultForegroundStyle: TintShapeStyle()
        ))
        return StaticIf(IsConditionallyBorderedPredicate.self) {
            ConditionallyBorderedButton(
                base: label,
                controlSize: controlSize,
                borderedButtonSpec: BorderedButtonSpec()
            )
        } else: {
            label
        }
    }
}

// MARK: - BorderlessButtonLabelShapeStyle

struct BorderlessButtonLabelShapeStyle<Style>: ShapeStyle where Style: ShapeStyle {
    var role: ButtonRole?
    var isEnabled: Bool
    var defaultForegroundStyle: Style

    func _apply(to shape: inout _ShapeStyle_Shape) {
        apply(to: &shape)
    }

    private func apply(to shape: inout _ShapeStyle_Shape) {
        if !isEnabled {
            HierarchicalShapeStyle.tertiary._apply(to: &shape)
        } else if role == .destructive {
            Color.red._apply(to: &shape)
        } else {
            defaultForegroundStyle._apply(to: &shape)
        }
    }

    static func _apply(to type: inout _ShapeStyle_ShapeType) {
        HierarchicalShapeStyle._apply(to: &type)
    }

    typealias Resolved = Never
}

// MARK: - ConditionallyBorderedButton

private struct ConditionallyBorderedButton<Base>: View where Base: View {
    var base: Base
    var controlSize: ControlSize

    @Environment(\.isToggleOn)
    private var isOn: Bool?

    @Environment(\.buttonBorderShape)
    private var borderShape: ButtonBorderShape

    let borderedButtonSpec: BorderedButtonSpec

    init(base: Base, controlSize: ControlSize, borderedButtonSpec: BorderedButtonSpec) {
        self.base = base
        self.controlSize = controlSize
        self.borderedButtonSpec = borderedButtonSpec
    }

    var resolvedBorderShape: ResolvedBorderShape {
        ResolvedBorderShape(controlSize: controlSize, base: borderShape, padding: .zero)
    }

    var background: some View {
        resolvedBorderShape.fill(.tint.opacity(isOn == true ? 0.18 : 0))
    }

    var body: some View {
        base.padding(isOn == nil ? .zero : borderedButtonSpec.padding)
            .background(background)
    }
}

// MARK: - IsConditionallyBorderedPredicate

private struct IsConditionallyBorderedPredicate: ViewInputPredicate {
    static func evaluate(inputs: _GraphInputs) -> Bool {
        inputs[IsToggleButton.self]
    }
}

#endif

// MARK: - OpacityButtonHighlightModifier

struct OpacityButtonHighlightModifier: ViewModifier {
    var highlighted: Bool

    @Environment(\.colorScheme)
    var colorScheme: ColorScheme

    func body(content: Content) -> some View {
        content
            .modifier(OpacityRendererEffect(
                opacity: highlighted ? (colorScheme == .dark ? 0.4 : 0.2) : 1.0
            ))
    }
}
