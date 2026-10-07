//
//  BorderedButtonStyle_Phone.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 23BA9706730FD9E83431548B5C759F22 (SwiftUI)

#if os(iOS) || os(visionOS)

import OpenSwiftUICore

// MARK: - BorderedButtonStyle_Phone

struct BorderedButtonStyle_Phone: ButtonStyle {
    var tint: Color?
    var isProminent: Bool

    @Environment(\.isToggleOn)
    var isOn: Bool?

    @Environment(\.buttonBorderShape)
    var borderShape: ButtonBorderShape

    @Environment(\.dynamicTypeSize)
    var dynamicTypeSize: DynamicTypeSize

    @Environment(\.tintColor)
    var controlTint: Color?

    init(tint: Color?, isProminent: Bool) {
        self.tint = tint
        self.isProminent = isProminent
    }

    func makeBody(configuration: Configuration) -> some View {
        let button = ResolvedBorderedButton(
            configuration: configuration,
            style: self,
            borderShape: borderShape
        )
        let scale: Image.Scale = switch dynamicTypeSize {
        case .xSmall, .small, .medium, .large, .xLarge, .xxLarge, .xxxLarge:
            .medium
        case .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5:
            .small
        }
        return button.imageScale(scale)
    }
}

// MARK: - UseImageBackground

private struct UseImageBackground: ViewInputBoolFlag {}

// MARK: - ResolvedBorderedButton

private struct ResolvedBorderedButton: View {
    @Environment(\.backgroundMaterial)
    var backgroundMaterial: Material?

    @Environment(\.colorScheme)
    var colorScheme: ColorScheme

    @Environment(\.isEnabled)
    var isEnabled: Bool

    @Environment(\.accessibilityReduceTransparency)
    var isReducedTransparencyEnabled: Bool

    @Environment(\.isToggleOn)
    var isOn: Bool?

    var configuration: ButtonStyleConfiguration
    var style: BorderedButtonStyle_Phone
    var borderShape: ButtonBorderShape
    let borderedButtonSpec: BorderedButtonSpec

    init(
        configuration: ButtonStyleConfiguration,
        style: BorderedButtonStyle_Phone,
        borderShape: ButtonBorderShape
    ) {
        self.configuration = configuration
        self.style = style
        self.borderShape = borderShape
        borderedButtonSpec = BorderedButtonSpec()
    }

    var body: some View {
        let label = HStack {
            configuration.label
        }
        .font(borderedButtonSpec.defaultFont)
        .multilineTextAlignment(.center)
        .buttonDefaultRenderingMode()
        return StaticIf(UseImageBackground.self) {
            label
                .defaultForegroundStyle(labelStyle)
                .padding(borderedButtonSpec.padding)
                .background(imageBackgroundSpec.shapeColor.opacity(imageBackgroundSpec.shapeOpacity))
                .background(imageBackgroundSpec.shapeMaterial!)
                .clipShape(ResolvedBorderShape(
                    controlSize: borderedButtonSpec.controlSize,
                    base: borderShape,
                    padding: .zero
                ))
        } else: {
            label
                .opacity((backgroundMaterial == nil ? opaqueBackgroundSpec : materialBackgroundSpec).labelOpacity)
                .defaultForegroundStyle(labelStyle)
                .padding(borderedButtonSpec.padding)
                .background {
                    background
                        .compositingGroup()
                        .blendMode((backgroundMaterial == nil ? opaqueBackgroundSpec : materialBackgroundSpec).shapeBlendMode)
                }
        }
        .contentShape([.interaction, .hoverEffect], ResolvedBorderShape(
            controlSize: borderedButtonSpec.controlSize,
            base: borderShape,
            padding: .zero
        ))
    }

    var labelStyle: BorderedButtonColorSpec.LabelStyle {
        if style.isOn == true, style.isProminent {
            .color(.white)
        } else {
            (backgroundMaterial == nil ? opaqueBackgroundSpec : materialBackgroundSpec).labelStyle
        }
    }

    var imageBackgroundSpec: BorderedButtonColorSpec {
        guard isEnabled else {
            return BorderedButtonColorSpec(
                shapeColor: .clear,
                shapeMaterial: .ultraThin,
                labelStyle: .color(Color(white: colorScheme == .light ? 0 : 1)),
                labelOpacity: colorScheme == .light ? 0.25 : 0.4
            )
        }
        let shapeColor: Color
        let labelStyle: BorderedButtonColorSpec.LabelStyle
        var shapeOpacity = 1.0
        var shapeMaterial = Material.thick
        var labelOpacity = 1.0
        switch resolvedTint {
        case let .tint(tint):
            if colorScheme == .light {
                shapeColor = tint.opacity(tint == .yellow ? 0.2 : 0.18)
                labelStyle = .color(tint)
                if configuration.isPressed {
                    shapeMaterial = .ultraThin
                    labelOpacity = 0.75
                }
            } else {
                shapeColor = tint.opacity(tint == .red || tint == .pink ? 0.15 : 0.2)
                if configuration.isPressed {
                    shapeMaterial = .ultraThin
                    labelStyle = .color(Color(white: 1, opacity: 0.1).over(tint))
                } else {
                    labelStyle = .color(tint)
                }
            }
        case let .prominent(tint):
            labelStyle = .primaryDark
            if configuration.isPressed {
                shapeMaterial = .ultraThin
                labelOpacity = 0.75
                if colorScheme == .light {
                    shapeColor = tint
                    shapeOpacity = 0.75
                } else {
                    shapeColor = Color(white: 1, opacity: 0.2).over(tint)
                }
            } else {
                shapeColor = tint
            }
        case .automatic:
            shapeColor = .clear
            if configuration.isPressed {
                if colorScheme == .light {
                    shapeMaterial = .thin
                    labelStyle = .color(defaultTint)
                    labelOpacity = 0.75
                } else {
                    shapeMaterial = .ultraThin
                    labelStyle = .color(Color(white: 1, opacity: 0.1).over(defaultTint))
                }
            } else {
                labelStyle = .color(defaultTint)
            }
        }
        return BorderedButtonColorSpec(
            shapeColor: shapeColor,
            shapeOpacity: shapeOpacity,
            shapeMaterial: shapeMaterial,
            labelStyle: labelStyle,
            labelOpacity: labelOpacity
        )
    }

    var background: some View {
        let spec = backgroundMaterial == nil ? opaqueBackgroundSpec : materialBackgroundSpec
        return ResolvedBorderShape(
            controlSize: borderedButtonSpec.controlSize,
            base: borderShape,
            padding: .zero
        )
        .fill(spec.shapeColor.opacity(spec.shapeOpacity))
    }

    var materialBackgroundSpec: BorderedButtonColorSpec {
        guard isEnabled else {
            if colorScheme == .light {
                return BorderedButtonColorSpec(
                    shapeColor: Color(white: 1, opacity: isReducedTransparencyEnabled ? 1 : 0.3),
                    labelStyle: .color(Color(white: 0)),
                    labelOpacity: 0.15
                )
            } else {
                return BorderedButtonColorSpec(
                    shapeColor: Color(white: 0, opacity: isReducedTransparencyEnabled ? 1 : 0.16),
                    shapeBlendMode: isReducedTransparencyEnabled ? .normal : .plusDarker,
                    labelStyle: .quaternary
                )
            }
        }
        let shapeColor: Color
        let labelStyle: BorderedButtonColorSpec.LabelStyle
        var shapeOpacity = 1.0
        var labelOpacity = 1.0
        switch resolvedTint {
        case let .tint(tint):
            if colorScheme == .light {
                let color = tint.opacity(tint == .yellow ? 0.2 : 0.18)
                shapeColor = isReducedTransparencyEnabled ? color.over(.white) : color
                labelStyle = .color(tint)
                if configuration.isPressed {
                    shapeOpacity = 0.65
                    labelOpacity = 0.75
                }
            } else {
                let color = tint.opacity(tint == .red || tint == .pink ? 0.15 : 0.2)
                if configuration.isPressed {
                    shapeColor = isReducedTransparencyEnabled ? color.over(.black) : color
                    labelStyle = .color(Color(white: 1, opacity: 0.1).over(tint))
                } else {
                    shapeColor = color.over(Color(white: 0, opacity: isReducedTransparencyEnabled ? 1 : 0.3))
                    labelStyle = .color(tint)
                }
            }
        case let .prominent(tint):
            labelStyle = .primaryDark
            if configuration.isPressed {
                labelOpacity = 0.75
                if colorScheme == .light {
                    shapeColor = isReducedTransparencyEnabled ? tint.over(.white) : tint
                    shapeOpacity = 0.75
                } else {
                    shapeColor = Color(white: 1, opacity: 0.2).over(tint)
                }
            } else {
                shapeColor = tint
            }
        case .automatic:
            if colorScheme == .light {
                shapeColor = Color(white: 1, opacity: isReducedTransparencyEnabled ? 1 : 0.6)
                labelStyle = .color(defaultTint)
                if configuration.isPressed {
                    shapeOpacity = isReducedTransparencyEnabled ? 1 : 0.65
                    labelOpacity = 0.75
                }
            } else {
                shapeColor = Color(white: 0, opacity: isReducedTransparencyEnabled ? 1 : 0.5)
                if configuration.isPressed {
                    shapeOpacity = isReducedTransparencyEnabled ? 1 : 0.65
                    labelStyle = .color(Color(white: 1, opacity: 0.1).over(defaultTint))
                } else {
                    labelStyle = .color(defaultTint)
                }
            }
        }
        return BorderedButtonColorSpec(
            shapeColor: shapeColor,
            shapeOpacity: shapeOpacity,
            labelStyle: labelStyle,
            labelOpacity: labelOpacity
        )
    }

    var opaqueBackgroundSpec: BorderedButtonColorSpec {
        guard isEnabled else {
            return BorderedButtonColorSpec(
                shapeColor: .secondarySystemFill,
                labelStyle: .tertiary,
                labelOpacity: 0.75
            )
        }
        let shapeColor: Color
        let labelStyle: BorderedButtonColorSpec.LabelStyle
        var shapeOpacity = 1.0
        var labelOpacity = 1.0
        switch resolvedTint {
        case let .tint(tint):
            if colorScheme == .light {
                shapeColor = isOn == false ? .secondarySystemFill : tint.opacity(tint == .yellow ? 0.2 : 0.18)
                labelStyle = .color(tint)
                if configuration.isPressed {
                    shapeOpacity = 0.65
                    labelOpacity = 0.75
                }
            } else {
                shapeColor = isOn == false ? .secondarySystemFill : tint.opacity(tint == .red || tint == .pink ? 0.2 : 0.25)
                if configuration.isPressed {
                    shapeOpacity = 1.4
                    labelStyle = .color(Color(white: 1, opacity: 0.1).over(tint))
                } else {
                    labelStyle = .color(tint)
                }
            }
        case let .prominent(tint):
            labelStyle = isOn == false ? .color(tint) : .primaryDark
            if configuration.isPressed {
                labelOpacity = 0.75
                if colorScheme == .light {
                    shapeColor = tint
                    shapeOpacity = 0.75
                } else {
                    shapeColor = Color(white: 1, opacity: 0.2).over(tint)
                }
            } else {
                shapeColor = tint.opacity(isOn == false ? 0 : 1)
            }
        case .automatic:
            if configuration.isPressed {
                if colorScheme == .light {
                    shapeColor = .secondarySystemFill
                    shapeOpacity = 0.75
                    labelStyle = .color(defaultTint)
                    labelOpacity = 0.75
                } else {
                    shapeColor = Color(white: 1, opacity: 0.05).over(.secondarySystemFill)
                    labelStyle = .color(Color(white: 1, opacity: 0.1).over(defaultTint))
                }
            } else {
                shapeColor = isOn == true ? defaultTint.opacity(defaultTint == .yellow ? 0.2 : 0.18) : .secondarySystemFill
                labelStyle = .color(defaultTint)
            }
        }
        return BorderedButtonColorSpec(
            shapeColor: shapeColor,
            shapeOpacity: shapeOpacity,
            labelStyle: labelStyle,
            labelOpacity: labelOpacity
        )
    }

    var defaultTint: Color {
        configuration.role == .destructive ? .red : .accentColor
    }

    var resolvedTint: ResolvedTint {
        if style.isProminent {
            .prominent(style.tint ?? style.controlTint ?? defaultTint)
        } else if let tint = style.tint ?? style.controlTint {
            .tint(tint)
        } else {
            .automatic
        }
    }
}

// MARK: - ResolvedTint

private enum ResolvedTint {
    case tint(Color)
    case prominent(Color)
    case automatic
}

#endif
