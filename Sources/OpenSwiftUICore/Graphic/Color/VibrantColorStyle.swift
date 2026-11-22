//
//  VibrantColorStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 8CCD408021CD268DDD1874045F6AD3D9 (SwiftUICore)

// MARK: - VibrantColorStyle

package protocol VibrantColorStyle {
    static func apply(_ type: SystemColorType, color: Color, material: Material, to shape: inout _ShapeStyle_Shape)
}

// MARK: - VibrantColorStyleKey

private struct VibrantColorStyleKey: EnvironmentKey {
    static var defaultValue: (any VibrantColorStyle.Type)? { nil }
}

// MARK: - EnvironmentValues + vibrantColorStyle

extension EnvironmentValues {
    package var vibrantColorStyle: (any VibrantColorStyle.Type)? {
        get { self[VibrantColorStyleKey.self] }
        set { self[VibrantColorStyleKey.self] = newValue }
    }
}

// MARK: - SystemVibrantColorStyle

package struct SystemVibrantColorStyle: VibrantColorStyle {
    package static func apply(_ type: SystemColorType, color: Color, material: Material, to shape: inout _ShapeStyle_Shape) {
        func vibrantColor(_ red: Float, _ green: Float, _ blue: Float) -> _ShapeStyle_Pack.Fill {
            .vibrantColor(.init(scale: 0.5, bias: (red, green, blue)))
        }

        let environment = shape.environment
        let fill: _ShapeStyle_Pack.Fill
        switch (environment.colorScheme, type) {
        case (.light, .red): fill = vibrantColor(0.5541659, -0.2144615, -0.2575988)
        case (.light, .orange): fill = vibrantColor(0.4847494, 0.06906313, -0.5152506)
        case (.light, .yellow): fill = vibrantColor(0.4826199, 0.28262, -0.51738)
        case (.light, .green): fill = vibrantColor(-0.3094232, 0.2670474, -0.1643251)
        case (.light, .teal): fill = vibrantColor(-0.3067604, 0.1952004, 0.2853964)
        case (.light, .mint): fill = vibrantColor(-0.5059663, 0.2744258, 0.2391317)
        case (.light, .cyan): fill = vibrantColor(-0.2999325, 0.1824204, 0.4059497)
        case (.light, .blue): fill = vibrantColor(-0.457187, 0.02124431, 0.5428129)
        case (.light, .indigo): fill = vibrantColor(-0.1174839, -0.125327, 0.3766337)
        case (.light, .purple): fill = vibrantColor(0.2169024, -0.1478035, 0.4012161)
        case (.light, .pink): fill = vibrantColor(0.5685608, -0.2549686, -0.0981058)
        case (.light, .brown): fill = vibrantColor(0.1193443, 0.001697254, -0.1473223)
        case (.dark, .red):
            fill = .vibrantMatrix(.init(
                row1: (0.30315, 0.1788, 0.01805, 0, 0.55416),
                row2: (0.05315, 0.4288, 0.01805, 0, 0.25932),
                row3: (0.05315, 0.1788, 0.26805, 0, 0.21622),
                row4: (0, 0, 0, 1, 0)
            ))
        case (.dark, .orange): fill = vibrantColor(0.91932, 0.54282, -0.04146)
        case (.dark, .yellow): fill = vibrantColor(0.94219, 0.78139, -0.01859)
        case (.dark, .green): fill = vibrantColor(0.11265, 0.74405, 0.26955)
        case (.dark, .teal): fill = vibrantColor(0.16214, 0.69544, 0.78954)
        case (.dark, .mint): fill = vibrantColor(0.24238, 0.75618, 0.74048)
        case (.dark, .cyan): fill = vibrantColor(0.26993, 0.70123, 0.87773)
        case (.dark, .blue): fill = vibrantColor(0.01386, 0.49224, 0.97464)
        case (.dark, .indigo): fill = vibrantColor(0.34283, 0.33503, 0.87623)
        case (.dark, .purple): fill = vibrantColor(0.73393, 0.33783, 0.93393)
        case (.dark, .pink): fill = vibrantColor(1.05312, 0.26882, 0.42562)
        case (.dark, .brown): fill = vibrantColor(0.61393, 0.49633, 0.34723)
        default:
            type._apply(color: color, to: &shape)
            return
        }
        switch shape.operation {
        case .prepareText:
            shape.result = .preparedText(.foregroundKeyColor)
        case let .resolveStyle(name, levels):
            guard let level = levels.first else { return }
            shape.stylePack[name, level] = .init(fill)
        case .fallbackColor:
            shape.result = .color(Color(type.resolve(in: environment)))
        default:
            break
        }
    }
}
