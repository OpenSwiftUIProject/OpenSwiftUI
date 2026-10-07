//
//  WidgetBorderedButtonStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 3B58ACDCE4E26D8F5A1699D1D953246C (SwiftUI)

import OpenSwiftUICore

// MARK: - WidgetBorderedButtonStyle

struct WidgetBorderedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ResolvedBorderedButton(configuration: configuration, isProminent: false)
    }
}

// MARK: - WidgetBorderedProminentButtonStyle

struct WidgetBorderedProminentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ResolvedBorderedButton(configuration: configuration, isProminent: true)
    }
}

// MARK: - ResolvedBorderedButton

private struct ResolvedBorderedButton: View {
    @Environment(\.controlSize)
    var controlSize: ControlSize

    @Environment(\.isEnabled)
    var isEnabled: Bool

    @Environment(\.colorScheme)
    var colorScheme: ColorScheme

    @Environment(\.tintColor)
    var tint: Color?

    @Environment(\.buttonBorderShape)
    var borderShape: ButtonBorderShape

    @Environment(\.isToggleOn)
    var isToggleOn: Bool?

    let configuration: ButtonStyleConfiguration
    let isProminent: Bool
    let borderedButtonSpec: BorderedButtonSpec
    let secondaryColor: Color

    init(configuration: ButtonStyleConfiguration, isProminent: Bool) {
        self.configuration = configuration
        self.isProminent = isProminent
        borderedButtonSpec = BorderedButtonSpec()
        #if os(macOS)
        secondaryColor = .secondary
        #else
        secondaryColor = .secondarySystemFill
        #endif
    }

    var body: some View {
        HStack {
            configuration.label
        }
        .defaultForegroundStyle(_OpacityShapeStyle(style: specs.labelStyle, opacity: Float(specs.labelOpacity)))
        .scaleEffect(specs.labelScale)
        .font(defaultFont)
        .padding(borderShape == .circle ? circleButtonPadding : borderedButtonSpec.padding)
        .background(background)
        .input(ButtonContainerIsBorderedInput.self)
    }

    var specs: BorderedButtonColorSpec {
        guard isEnabled else {
            return BorderedButtonColorSpec(
                shapeColor: secondaryColor,
                labelStyle: .tertiary,
                labelOpacity: 0.75
            )
        }
        let shapeScale = configuration.isPressed ? 0.9 : 1.0
        let labelScale = configuration.isPressed ? (borderShape == .circle ? 0.8 : 0.9) : 1.0
        let tint = tint ?? defaultTint
        let shapeColor: Color
        let shapeOpacity: Double
        let labelStyle: BorderedButtonColorSpec.LabelStyle
        if isToggleOn ?? true {
            if isProminent {
                shapeColor = Color(white: 0, opacity: configuration.isPressed ? 0.06 : 0).over(tint)
                shapeOpacity = 1
                labelStyle = .primaryDark
            } else {
                shapeColor = tint
                if colorScheme == .light {
                    if tint == .yellow {
                        shapeOpacity = configuration.isPressed ? 0.2 : 0.14
                    } else {
                        shapeOpacity = configuration.isPressed ? 0.18 : 0.12
                    }
                } else {
                    shapeOpacity = configuration.isPressed ? 0.24 : 0.32
                }
                labelStyle = .color(tint)
            }
        } else {
            shapeColor = secondaryColor
            shapeOpacity = 1
            labelStyle = .color(tint)
        }
        return BorderedButtonColorSpec(
            shapeColor: shapeColor,
            shapeOpacity: shapeOpacity,
            shapeScale: shapeScale,
            labelStyle: labelStyle,
            labelScale: labelScale
        )
    }

    var defaultFont: Font {
        let style: Font.TextStyle = switch controlSize {
        case .mini, .small: .subheadline
        case .regular, .large, .extraLarge: .body
        }
        return .system(style, design: nil, weight: .semibold)
    }

    var background: some View {
        ResolvedBorderShape(
            controlSize: controlSize,
            base: borderShape == .automatic ? .capsule : borderShape,
            padding: .zero
        )
        .fill(specs.shapeColor.opacity(specs.shapeOpacity))
        .scaleEffect(specs.shapeScale)
    }

    var circleButtonPadding: EdgeInsets {
        let extra: Double = switch borderedButtonSpec.dynamicTypeSize {
        case .accessibility1: 2
        case .accessibility2: 4
        case .accessibility3: 6
        case .accessibility4: 8
        case .accessibility5: 10
        default: 0
        }
        let padding: Double = switch controlSize {
        case .mini, .small: 8
        case .regular: 10
        case .large, .extraLarge: 18
        }
        return EdgeInsets(_all: padding + extra)
    }

    var defaultTint: Color {
        configuration.role == .destructive ? .red : .accentColor
    }
}
