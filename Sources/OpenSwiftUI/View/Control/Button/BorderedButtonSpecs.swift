//
//  BorderedButtonSpecs.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: B901BF3CF7B6DCD0C05CD02455913DF4 (SwiftUI)

import OpenSwiftUICore

// MARK: - BorderedButtonSpec

struct BorderedButtonSpec: DynamicProperty {
    @Environment(\.controlSize) var controlSize: ControlSize
    @Environment(\.keyboardShortcut) var shortcut: KeyboardShortcut?
    @Environment(\.dynamicTypeSize) var dynamicTypeSize: DynamicTypeSize

    var padding: EdgeInsets {
        let horizontal: Double
        let vertical: Double
        switch controlSize {
        case .mini, .small:
            horizontal = 10
            vertical = 5
        case .regular:
            horizontal = 12
            vertical = 7
        case .large, .extraLarge:
            horizontal = 20
            vertical = 15
        }
        let extra: Double = switch dynamicTypeSize {
        case .accessibility1: 2
        case .accessibility2: 4
        case .accessibility3: 6
        case .accessibility4: 8
        case .accessibility5: 10
        default: 0
        }
        return EdgeInsets(
            top: vertical,
            leading: horizontal + extra,
            bottom: vertical,
            trailing: horizontal + extra
        )
    }

    var defaultFont: Font {
        let style: Font.TextStyle = switch controlSize {
        case .mini, .small: .subheadline
        case .regular, .large, .extraLarge: .body
        }
        return .system(style, design: nil, weight: isDefault ? .bold : .regular)
    }

    private var isDefault: Bool {
        shortcut == .defaultAction
    }
}

// MARK: - BorderedButtonColorSpec

struct BorderedButtonColorSpec {
    let shapeColor: Color
    var shapeOpacity: Double = 1
    var shapeScale: Double = 1
    var shapeMaterial: Material?
    var shapeBlendMode: BlendMode = .normal
    let labelStyle: LabelStyle
    var labelOpacity: Double = 1
    var labelScale: Double = 1

    enum LabelStyle: ShapeStyle {
        case color(Color)
        case primaryDark
        case tertiary
        case quaternary

        func _apply(to shape: inout _ShapeStyle_Shape) {
            switch self {
            case let .color(color): color._apply(to: &shape)
            case .primaryDark: Color.white._apply(to: &shape)
            case .tertiary: HierarchicalShapeStyle.tertiary._apply(to: &shape)
            case .quaternary: HierarchicalShapeStyle.quaternary._apply(to: &shape)
            }
        }

        typealias Resolved = Never
    }
}
