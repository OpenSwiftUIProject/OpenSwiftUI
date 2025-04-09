//
//  VibrantColorStyle.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: 9E3352CE4697DF56A738786E16992848 (SwiftUICore)

package protocol VibrantColorStyle {
    static func apply(_ type: SystemColorType, color: Color, material: Material, to shape: inout _ShapeStyle_Shape)
}

private struct VibrantColorStyleKey: EnvironmentKey {
    static var defaultValue: (any VibrantColorStyle.Type)? { nil }
}

extension EnvironmentValues {
    package var vibrantColorStyle: (any VibrantColorStyle.Type)? {
        get { self[VibrantColorStyleKey.self] }
        set { self[VibrantColorStyleKey.self] = newValue }
    }
}

package struct SystemVibrantColorStyle: VibrantColorStyle {
    package static func apply(_ type: SystemColorType, color: Color, material: Material, to shape: inout _ShapeStyle_Shape) {
        let environment = shape.environment
        let colorScheme = environment.colorScheme
        let vibrantColor: Color.ResolvedVibrant
        switch type {
        case .red: vibrantColor = colorScheme == .dark ? .init(scale: 0.5, bias: (0.554157, -0.214443, -0.257643)) : .init(scale: 0.5, bias: (0.554166, -0.214462, -0.257599))
        case .orange: vibrantColor = colorScheme == .dark ? .init(scale: 0.5, bias: (0.484754, 0.0690543, -0.515246)) : .init(scale: 0.5, bias: (0.484749, 0.0690631, -0.515251))
        case .yellow: vibrantColor = colorScheme == .dark ? .init(scale: 0.5, bias: (0.48262, 0.28262, -0.51738)) : .init(scale: 0.5, bias: (0.48262, 0.28262, -0.51738))
        case .green: vibrantColor = colorScheme == .dark ? .init(scale: 0.5, bias: (-0.309444, 0.267056, -0.164345)) : .init(scale: 0.5, bias: (-0.309423, 0.267047, -0.164325))
        case .teal: vibrantColor = colorScheme == .dark ? .init(scale: 0.5, bias: (-0.306794, 0.195206, 0.285406)) : .init(scale: 0.5, bias: (-0.30676, 0.1952, 0.285396))
        case .mint: vibrantColor = colorScheme == .dark ? .init(scale: 0.5, bias: (-0.505969, 0.274431, 0.239131)) : .init(scale: 0.5, bias: (-0.505966, 0.274426, 0.239132))
        case .cyan: vibrantColor = colorScheme == .dark ? .init(scale: 0.5, bias: (-0.299904, 0.182397, 0.405997)) : .init(scale: 0.5, bias: (-0.299933, 0.18242, 0.40595))
        case .blue: vibrantColor = colorScheme == .dark ? .init(scale: 0.5, bias: (-0.457176, 0.0212242, 0.542824)) : .init(scale: 0.5, bias: (-0.457187, 0.0212443, 0.542813))
        case .indigo: vibrantColor = colorScheme == .dark ? .init(scale: 0.5, bias: (-0.117498, -0.125298, 0.376602)) : .init(scale: 0.5, bias: (-0.117484, -0.125327, 0.376634))
        case .purple: vibrantColor = colorScheme == .dark ? .init(scale: 0.5, bias: (0.216914, -0.147786, 0.401213)) : .init(scale: 0.5, bias: (0.216902, -0.147804, 0.401216))
        case .pink: vibrantColor = colorScheme == .dark ? .init(scale: 0.5, bias: (0.568551, -0.254948, -0.0981485)) : .init(scale: 0.5, bias: (0.568561, -0.254969, -0.0981058))
        case .brown: vibrantColor = colorScheme == .dark ? .init(scale: 0.5, bias: (0.119367, 0.00166739, -0.147333)) : .init(scale: 0.5, bias: (0.119344, 0.00169725, -0.147322))
        default:
            type._apply(color: color, to: &shape)
            return
        }
        switch shape.operation {
        case let .prepareText(level):
            shape.result = .preparedText(.foregroundKeyColor)
        case let .resolveStyle(name, levels):
            guard levels.lowerBound != levels.upperBound else {
                break
            }
            shape.stylePack[name, levels.lowerBound] = .init(.vibrantColor(vibrantColor))
        case let .fallbackColor(level):
            shape.result = .color(Color(type.resolve(in: environment)))
        default:
            break
        }
    }
}
