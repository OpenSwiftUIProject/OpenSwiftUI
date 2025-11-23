//
//  PlainDividerStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Blocked by Shape
//  ID: 4E7A7B805FC8F5CEEF99A1E333CA7AA7 (SwiftUI)

@_spi(Private)
import OpenSwiftUICore

// MARK: - PlainDividerStyle

extension DividerStyle where Self == PlainDividerStyle {
    static var plain: PlainDividerStyle {
        .init()
    }
}

struct PlainDividerStyle: DividerStyle {
    @Environment(\.dividerThickness)
    private var thickness: CGFloat

    func makeBody(configuration: DividerStyleConfiguration) -> some View {
        // TODO: Shape is not implemented yet
        Color(provider: PlainDividerShapeStyle())
//        DividerShape(base: Rectangle())
//            .fill(PlainDividerShapeStyle())
            .frame(
                width: configuration.orientation == .horizontal ? nil : thickness,
                height: configuration.orientation == .horizontal ? thickness : nil
            )
    }
}

// MARK: - PlainDividerShapeStyle

struct PlainDividerShapeStyle: ShapeStyle, ColorProvider {
    private static let sharedColor = Color(provider: PlainDividerShapeStyle())

    func _apply(to shape: inout _ShapeStyle_Shape) {
        if shape.environment.isVisionEnabled {
            SeparatorShapeStyle()._apply(to: &shape)
        } else {
            let color: Color
            if shape.environment.backgroundMaterial != nil {
                color = Color.quaternary
            } else {
                color = Self.sharedColor
            }
            color._apply(to: &shape)
        }
    }

    func resolve(in environment: EnvironmentValues) -> Color.Resolved {
        if environment.colorScheme == .dark {
            Color.Resolved(red: 84 / 255, green: 84 / 255, blue: 88 / 255, opacity: 0.6)
        } else {
            Color.Resolved(red: 60 / 255, green: 60 / 255, blue: 67 / 255, opacity: 0.29)
        }
    }
}

// MARK: - DividerShape

private struct DividerShape<S>: Shape where S: Shape {
    var base: S

    nonisolated func path(in rect: CGRect) -> Path {
        base.path(in: rect)
    }

    nonisolated static var role: ShapeRole {
        .separator
    }

    nonisolated var layoutDirectionBehavior: LayoutDirectionBehavior {
        base.layoutDirectionBehavior
    }
}
