//
//  DefaultSystemColorDefinition_Vision.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 241B1548FB48B9561AEF74EC402F6941 (SwiftUICore)

#if os(visionOS)

// MARK: - SystemVibrantColorStyle_Vision

package struct SystemVibrantColorStyle_Vision: VibrantColorStyle {
    package static func apply(_ type: SystemColorType, color: Color, material: Material, to shape: inout _ShapeStyle_Shape) {
        let environment = shape.environment
        guard environment.isVisionEnabled else {
            SystemVibrantColorStyle.apply(type, color: color, material: material, to: &shape)
            return
        }
        switch shape.operation {
        case .prepareText:
            shape.result = .preparedText(.foregroundKeyColor)
        case let .resolveStyle(name, levels):
            guard let level = levels.first else { return }
            let id = ContentStyle.ID(truncatingLevel: level)
            shape.stylePack[name, level] = shape.resolveStyle(id: id, material: material, color: color)
        case .fallbackColor:
            shape.result = .color(Color(type.resolve(in: environment)))
        default:
            break
        }
    }
}

extension _ShapeStyle_Shape {
    fileprivate func resolveStyle(id: ContentStyle.ID, material: Material, color: Color) -> _ShapeStyle_Pack.Style {
        let primitive: ContentStyle.Primitive
        if color == ._destructive {
            primitive = .destructive
        } else {
            primitive = .init(role)
        }
        let style = ContentStyle.MaterialStyle(
            material: material.resolve(in: environment, role: nil),
            base: .init(id: id, primitive: primitive)
        )
        return .init(.foregroundMaterial(color.resolve(in: environment), style))
    }
}

// MARK: - Color + _destructive

extension Color {
    @_spi(_)
    @available(OpenSwiftUI_v6_0, *)
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    public static let _destructive: Color = Color(provider: DestructiveColorProvider())
}

// MARK: - DestructiveColorProvider

private struct DestructiveColorProvider: ColorProvider {
    func resolve(in environment: EnvironmentValues) -> Color.Resolved {
        if environment.backgroundMaterial != nil, environment.isVisionEnabled {
            return Color(.sRGB, red: 1, green: 0.0313, blue: 0.0313).resolve(in: environment)
        }
        return SystemColorType.red.resolve(in: environment)
    }

    func apply(color: Color, to shape: inout _ShapeStyle_Shape) {
        guard let material = shape.environment.backgroundMaterial,
              let style = shape.environment.vibrantColorStyle else {
            _apply(color: color, to: &shape)
            return
        }
        style.apply(.red, color: color, material: material, to: &shape)
    }
}

#endif
