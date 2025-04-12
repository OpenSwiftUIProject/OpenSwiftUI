//
//  SystemColors.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: 9E3352CE4697DF56A738786E16992848 (SwiftUICore)

import OpenSwiftUI_SPI

// MARK: - Color + SystemColorType

extension Color {
    /// A context-dependent red color suitable for use in UI elements.
    public static let red: Color = Color(provider: SystemColorType.red)
    
    /// A context-dependent orange color suitable for use in UI elements.
    public static let orange: Color = Color(provider: SystemColorType.orange)
    
    /// A context-dependent yellow color suitable for use in UI elements.
    public static let yellow: Color = Color(provider: SystemColorType.yellow)
    
    /// A context-dependent green color suitable for use in UI elements.
    public static let green: Color = Color(provider: SystemColorType.green)
    
    /// A context-dependent mint color suitable for use in UI elements
    public static let mint: Color = Color(provider: SystemColorType.mint)
    
    /// A context-dependent teal color suitable for use in UI elements.
    public static let teal: Color = Color(provider: SystemColorType.teal)
    
    /// A context-dependent cyan color suitable for use in UI elements.
    public static let cyan: Color = Color(provider: SystemColorType.cyan)
    
    /// A context-dependent blue color suitable for use in UI elements.
    public static let blue: Color = Color(provider: SystemColorType.blue)
    
    /// A context-dependent indigo color suitable for use in UI elements.
    public static let indigo: Color = Color(provider: SystemColorType.indigo)
    
    /// A context-dependent purple color suitable for use in UI elements.
    public static let purple: Color = Color(provider: SystemColorType.purple)
    
    /// A context-dependent pink color suitable for use in UI elements.
    public static let pink: Color = Color(provider: SystemColorType.pink)
    
    /// A context-dependent brown color suitable for use in UI elements.
    public static let brown: Color = Color(provider: SystemColorType.brown)
    
    /// A white color suitable for use in UI elements.
    public static let white: Color = Color(Color.Resolved(linearWhite: 1.0))
    
    /// A context-dependent gray color suitable for use in
    public static let gray: Color = Color(provider: SystemColorType.gray)
    
    /// A black color suitable for use in UI elements.
    public static let black: Color = Color(Color.Resolved(linearWhite: 1.0))
    
    /// A clear color suitable for use in UI elements.
    public static let clear: Color = Color(Color.Resolved(linearWhite: 0.0, opacity: 0.0))
    
    /// The color to use for primary content.
    public static let primary: Color = Color(provider: SystemColorType.primary)
    
    /// The color to use for secondary content.
    public static let secondary: Color = Color(provider: SystemColorType.secondary)
}

// MARK: - ShapeStyle + Color

extension ShapeStyle where Self == Color {
    /// A context-dependent red color suitable for use in UI elements.
    @_alwaysEmitIntoClient
    public static var red: Color { .red }

    /// A context-dependent orange color suitable for use in UI elements.
    @_alwaysEmitIntoClient
    public static var orange: Color { .orange }
    
    /// A context-dependent yellow color suitable for use in UI elements.
    @_alwaysEmitIntoClient
    public static var yellow: Color { .yellow }
    
    /// A context-dependent green color suitable for use in UI elements.
    @_alwaysEmitIntoClient
    public static var green: Color { .green }
    
    /// A context-dependent mint color suitable for use in UI elements.
    @_alwaysEmitIntoClient
    public static var mint: Color { .mint }
    
    /// A context-dependent teal color suitable for use in UI elements.
    @_alwaysEmitIntoClient
    public static var teal: Color { .teal }
    
    /// A context-dependent cyan color suitable for use in UI elements.
    @_alwaysEmitIntoClient
    public static var cyan: Color { .cyan }
    
    /// A context-dependent blue color suitable for use in UI elements.
    @_alwaysEmitIntoClient
    public static var blue: Color { .blue }
    
    /// A context-dependent indigo color suitable for use in UI elements.
    @_alwaysEmitIntoClient
    public static var indigo: Color { .indigo }
    
    /// A context-dependent purple color suitable for use in UI elements.
    @_alwaysEmitIntoClient
    public static var purple: Color { .purple }
    
    /// A context-dependent pink color suitable for use in UI elements.
    @_alwaysEmitIntoClient
    public static var pink: Color { .pink }
    
    /// A context-dependent brown color suitable for use in UI elements.
    @_alwaysEmitIntoClient
    public static var brown: Color { .brown }
    
    /// A white color suitable for use in UI elements.
    @_alwaysEmitIntoClient
    public static var white: Color { .white }
    
    /// A context-dependent gray color suitable for use in UI elements.
    @_alwaysEmitIntoClient
    public static var gray: Color { .gray }
    
    /// A black color suitable for use in UI elements.
    @_alwaysEmitIntoClient
    public static var black: Color { .black }
    
    /// A clear color suitable for use in UI elements.
    @_alwaysEmitIntoClient
    public static var clear: Color { .clear }
}

// MARK: - Color + SystemColorType

extension Color {
    package static let primarySystemFill: Color = Color(provider: SystemColorType.primaryFill)
    package static let secondarySystemFill: Color = Color(provider: SystemColorType.secondaryFill)
    package static let tertiarySystemFill: Color = Color(provider: SystemColorType.tertiaryFill)
    package static let quaternarySystemFill: Color = Color(provider: SystemColorType.quaternaryFill)
}

extension Color {
    package static let tertiary: Color = Color(provider: SystemColorType.tertiary)
    package static let quaternary: Color = Color(provider: SystemColorType.quaternary)
    package static let quinary: Color = Color(provider: SystemColorType.quinary)
}

// MARK: - SystemColorType

package enum SystemColorType: ColorProvider {
    case red
    case orange
    case yellow
    case green
    case teal
    case mint
    case cyan
    case blue
    case indigo
    case purple
    case pink
    case brown
    case gray
    case primary
    case secondary
    case tertiary
    case quaternary
    case quinary
    case primaryFill, secondaryFill, tertiaryFill, quaternaryFill
    
    package func resolve(in environment: EnvironmentValues) -> Color.Resolved {
        environment.systemColorDefinition.base.value(for: self, environment: environment)
    }
    
    package func apply(color: Color, to shape: inout _ShapeStyle_Shape) {
        guard isLinkedOnOrAfter(.v3) else {
            _apply(color: color, to: &shape)
            return
        }
        switch self {
        case .primary: LegacyContentStyle(id: .primary, color: color)._apply(to: &shape)
        case .secondary: LegacyContentStyle(id: .secondary, color: color)._apply(to: &shape)
        case .tertiary: LegacyContentStyle(id: .tertiary, color: color)._apply(to: &shape)
        case .quaternary: LegacyContentStyle(id: .quaternary, color: color)._apply(to: &shape)
        case .quinary: LegacyContentStyle(id: .quinary, color: color)._apply(to: &shape)
        default:
            let environment = shape.environment
            guard let backgroundMaterial = environment.backgroundMaterial,
                  let vibrantColorStyle = environment.vibrantColorStyle
            else {
                _apply(color: color, to: &shape)
                return
            }
            vibrantColorStyle.apply(self, color: color, material: backgroundMaterial, to: &shape)
            break
        }
    }
    
    package var kitColor: AnyObject? {
        #if canImport(Darwin)
        switch self {
            case .red: CoreColor.systemRedColor(with: .defaults)
            case .orange: CoreColor.systemOrangeColor(with: .defaults)
            case .yellow: CoreColor.systemYellowColor(with: .defaults)
            case .green: CoreColor.systemGreenColor(with: .defaults)
            case .teal: CoreColor.systemTealColor(with: .defaults)
            case .mint: CoreColor.systemMintColor(with: .defaults)
            case .cyan: CoreColor.systemCyanColor(with: .defaults)
            case .blue: CoreColor.systemBlueColor(with: .defaults)
            case .indigo: CoreColor.systemIndigoColor(with: .defaults)
            case .purple: CoreColor.systemPurpleColor(with: .defaults)
            case .pink: CoreColor.systemPinkColor(with: .defaults)
            case .brown: CoreColor.systemBrownColor(with: .defaults)
            case .gray: CoreColor.systemGrayColor(with: .defaults)
            default: nil
        }
        #else
        nil
        #endif
    }
}

// MARK: - SystemColorDefinition

package protocol SystemColorDefinition {
    static func value(for type: SystemColorType, environment: EnvironmentValues) -> Color.Resolved
    static func opacity(at level: Int, environment: EnvironmentValues) -> Float
}

extension SystemColorDefinition {
    package static func systemRGB(_ r: Float, _ g: Float, _ b: Float, _ a: Float = 100) -> Color.Resolved {
        Color.Resolved(red: r / 255.0, green: g / 255.0, blue: b / 255.0, opacity: a * 0.01)
    }
    
    package static func opacity(at level: Int, environment: EnvironmentValues) -> Float {
        switch level {
            case 0: return 1.0
            case 1: return 0.5
            case 2: return 0.25
            default: return 0.18
        }
    }
}

struct SystemColorDefinitionType {
    var base: SystemColorDefinition.Type
}

private struct SystemColorDefinitionKey: EnvironmentKey {
    static var defaultValue: SystemColorDefinitionType {
        SystemColorDefinitionType(base: CoreUIDefaultSystemColorDefinition.self)
    }
}

extension EnvironmentValues {
    var systemColorDefinition: SystemColorDefinitionType {
        self[SystemColorDefinitionKey.self]
    }
}

// MARK: - CoreUIDefaultSystemColorDefinition

struct CoreUIDefaultSystemColorDefinition: SystemColorDefinition {
    static func value(for type: SystemColorType, environment: EnvironmentValues) -> Color.Resolved {
        #if canImport(Darwin)
        let name: CUIColorName
        switch type {
        case .red: name = .red
        case .orange: name = .orange
        case .yellow: name = .yellow
        case .green: name = .green
        case .teal: name = .teal
        case .mint: name = .mint
        case .cyan: name = .cyan
        case .blue: name = .blue
        case .indigo: name = .indigo
        case .purple: name = .purple
        case .pink: name = .pink
        case .brown: name = .brown
        case .gray: name = .gray
        case .primary: name = .primary
        case .secondary: name = .secondary
        case .tertiary: name = .tertiary
        case .quaternary: name = .quaternary
        case .quinary: name = .quinary
        default: return DefaultSystemColorDefinition_PhoneTV.value(for: type, environment: environment)
        }
        let cacheKey = CUIDesignLibraryCacheKey(name: name, in: environment, allowsBlendMode: false)
        let entry = cacheKey.fetch()
        return entry.color
        #else
        // For non CoreUI supported platform, simply return clear for now
        Color.Resolved.clear
        #endif

    }

    static func opacity(at level: Int, environment: EnvironmentValues) -> Float {
        switch level {
        case 0: return 1.0
        case 1: return 0.5
        case 2: return 0.25
        default: return 0.18
        }
    }
}

// MARK: - DefaultSystemColorDefinition_PhoneTV

struct DefaultSystemColorDefinition_PhoneTV: SystemColorDefinition {
    static func value(for type: SystemColorType, environment: EnvironmentValues) -> Color.Resolved {
        let colorScheme = environment.colorScheme
        let colorSchemeContrast = environment.colorSchemeContrast
        return switch colorScheme {
        case .light:
            switch type {
            case .red:
//                #colorLiteral(red: 0.8431373, green: 0.0, blue: 0.08235294, alpha: 1.0)
//                #colorLiteral(red: 1.0, green: 0.23137255, blue: 0.1882353, alpha: 1.0)
                colorSchemeContrast == .increased
                    ? Color.Resolved(red: 215 / 255, green: 0.0, blue: 21 / 255, opacity: 1.0)
                    : Color.Resolved(red: 1.0, green: 59 / 255, blue: 48 / 255, opacity: 1.0)
            case .orange:
//                #colorLiteral(red: 0.7882353, green: 0.20392157, blue: 0.0, alpha: 1.0)
//                #colorLiteral(red: 1.0, green: 0.58431375, blue: 0.0, alpha: 1.0)
                colorSchemeContrast == .increased
                    ? Color.Resolved(red: 201 / 255, green: 52 / 255, blue: 0.0, opacity: 1.0)
                    : Color.Resolved(red: 1.0, green: 149 / 255, blue: 0.0, opacity: 1.0)
            case .yellow:
//                #colorLiteral(red: 0.69803923, green: 0.3137255, blue: 0.0, alpha: 1.0)
//                #colorLiteral(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
                colorSchemeContrast == .increased
                    ? Color.Resolved(red: 178 / 255, green: 80 / 255, blue: 0.0, opacity: 1.0)
                    : Color.Resolved(red: 1.0, green: 204 / 255, blue: 0.0, opacity: 1.0)
            case .green:
//                #colorLiteral(red: 0.14117648, green: 0.5411765, blue: 0.23921569, alpha: 1.0)
//                #colorLiteral(red: 0.20392157, green: 0.78039217, blue: 0.34901962, alpha: 1.0)
                colorSchemeContrast == .increased
                    ? Color.Resolved(red: 36 / 255, green: 138 / 255, blue: 61 / 255, opacity: 1.0)
                    : Color.Resolved(red: 52 / 255, green: 199 / 255, blue: 89 / 255, opacity: 1.0)
            case .teal:
//                #colorLiteral(red: 0.0, green: 0.50980395, blue: 0.6, alpha: 1.0)
//                #colorLiteral(red: 0.1882353, green: 0.6901961, blue: 0.78039217, alpha: 1.0)
                colorSchemeContrast == .increased
                    ? Color.Resolved(red: 1.0, green: 130 / 255, blue: 153 / 255, opacity: 1.0)
                    : Color.Resolved(red: 48 / 255, green: 176 / 255, blue: 199 / 255, opacity: 1.0)
            case .mint:
//                #colorLiteral(red: 0.047058824, green: 0.5058824, blue: 0.48235294, alpha: 1.0)
//                #colorLiteral(red: 0.0, green: 0.78039217, blue: 0.74509805, alpha: 1.0)
                colorSchemeContrast == .increased
                    ? Color.Resolved(red: 12 / 255, green: 129 / 255, blue: 123 / 255, opacity: 1.0)
                    : Color.Resolved(red: 0.0, green: 199 / 255, blue: 190 / 255, opacity: 1.0)
            case .cyan:
//                #colorLiteral(red: 0.0, green: 0.44313726, blue: 0.6431373, alpha: 1.0)
//                #colorLiteral(red: 0.19607843, green: 0.6784314, blue: 0.9019608, alpha: 1.0)
                colorSchemeContrast == .increased
                    ? Color.Resolved(red: 0.0, green: 113 / 255, blue: 164 / 255, opacity: 1.0)
                    : Color.Resolved(red: 50 / 255, green: 191739 / 255, blue: 230 / 255, opacity: 1.0)
            case .blue:
//                #colorLiteral(red: 0.0, green: 0.2509804, blue: 0.8666667, alpha: 1.0)
//                #colorLiteral(red: 0.0, green: 0.47843137, blue: 1.0, alpha: 1.0)
                colorSchemeContrast == .increased
                    ? Color.Resolved(red: 0.0, green: 64 / 255, blue: 221 / 255, opacity: 1.0)
                    : Color.Resolved(red: 0.0, green: 122 / 255, blue: 1.0, opacity: 1.0)
            case .indigo:
//                #colorLiteral(red: 0.21176471, green: 0.0, blue: 0.8039216, alpha: 1.0)
//                #colorLiteral(red: 0.34509805, green: 0.47843137, blue: 0.8392157, alpha: 1.0)
                colorSchemeContrast == .increased
                    ? Color.Resolved(red: 54 / 255, green: 52 / 255, blue: 163 / 255, opacity: 1.0)
                    : Color.Resolved(red: 88 / 255, green: 86 / 255, blue: 214 / 255, opacity: 1.0)
            case .purple:
//                #colorLiteral(red: 0.5372549, green: 0.26666668, blue: 0.67058825, alpha: 1.0)
//                #colorLiteral(red: 0.6862745, green: 0.32156864, blue: 0.87058824, alpha: 1.0)
                colorSchemeContrast == .increased
                    ? Color.Resolved(red: 137 / 255, green: 68 / 255, blue: 171 / 255, opacity: 1.0)
                    : Color.Resolved(red: 175 / 255, green: 82 / 255, blue: 222 / 255, opacity: 1.0)
            case .pink:
//                #colorLiteral(red: 0.827451, green: 0.05882353, blue: 0.27058825, alpha: 1.0)
//                #colorLiteral(red: 1.0, green: 0.1764706, blue: 0.33333334, alpha: 1.0)
                colorSchemeContrast == .increased
                    ? Color.Resolved(red: 211 / 255, green: 15 / 255, blue: 69 / 255, opacity: 1.0)
                    : Color.Resolved(red: 1.0, green: 45 / 255, blue: 85 / 255, opacity: 1.0)
            case .brown:
//                #colorLiteral(red: 0.49803922, green: 0.39607844, blue: 0.27058825, alpha: 1.0)
//                #colorLiteral(red: 0.6862745, green: 0.5176471, blue: 0.36862746, alpha: 1.0)
                colorSchemeContrast == .increased
                    ? Color.Resolved(red: 127 / 255, green: 101 / 255, blue: 69 / 255, opacity: 1.0)
                    : Color.Resolved(red: 162 / 255, green: 132 / 255, blue: 94 / 255, opacity: 1.0)
            case .gray:
//                #colorLiteral(red: 0.42352942, green: 0.42352942, blue: 0.4392157, alpha: 1.0)
//                #colorLiteral(red: 0.5568628, green: 0.5568628, blue: 0.5764706, alpha: 1.0)
                colorSchemeContrast == .increased
                    ? Color.Resolved(red: 108 / 255, green: 108 / 255, blue: 112 / 255, opacity: 1.0)
                    : Color.Resolved(red: 142 / 255, green: 142 / 255, blue: 147 / 255, opacity: 1.0)
            case .primary:
//                #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
                Color.Resolved(linearRed: 0.0, linearGreen: 0.0, linearBlue: 0.0, opacity: 1.0)
            case .secondary:
//                #colorLiteral(red: 0.23529412, green: 0.23529412, blue: 0.2627451, alpha: 0.8)
//                #colorLiteral(red: 0.23529412, green: 0.23529412, blue: 0.2627451, alpha: 0.6)
                Color.Resolved(red: 60 / 255, green: 60 / 255, blue: 67 / 255, opacity: colorSchemeContrast == .increased ? 0.8 : 0.6)
            case .tertiary:
//                #colorLiteral(red: 0.23529412, green: 0.23529412, blue: 0.2627451, alpha: 0.7)
//                #colorLiteral(red: 0.23529412, green: 0.23529412, blue: 0.2627451, alpha: 0.3)
                Color.Resolved(red: 60 / 255, green: 60 / 255, blue: 67 / 255, opacity: colorSchemeContrast == .increased ? 0.7 : 0.3)
            case .quaternary:
//                #colorLiteral(red: 0.23529412, green: 0.23529412, blue: 0.2627451, alpha: 0.55)
//                #colorLiteral(red: 0.23529412, green: 0.23529412, blue: 0.2627451, alpha: 0.18)
                Color.Resolved(red: 60 / 255, green: 60 / 255, blue: 67 / 255, opacity: colorSchemeContrast == .increased ? 0.55 : 0.18)
            case .quinary:
//                #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.08137255)
//                #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.05)
                Color.Resolved(linearRed: 0.0, linearGreen: 0.0, linearBlue: 0.0, opacity: colorSchemeContrast == .increased ? 0.08137255 : 0.05)
            case .primaryFill:
//                #colorLiteral(red: 0.47058824, green: 0.47058824, blue: 0.5019608, alpha: 0.28)
//                #colorLiteral(red: 0.47058824, green: 0.47058824, blue: 0.5019608, alpha: 0.20)
                Color.Resolved(red: 120 / 255, green: 120 / 255, blue: 128 / 255, opacity: colorSchemeContrast == .increased ? 0.28 : 0.20)
            case .secondaryFill:
//                #colorLiteral(red: 0.47058824, green: 0.47058824, blue: 0.5019608, alpha: 0.24)
//                #colorLiteral(red: 0.47058824, green: 0.47058824, blue: 0.5019608, alpha: 0.16)
                Color.Resolved(red: 120 / 255, green: 120 / 255, blue: 128 / 255, opacity: colorSchemeContrast == .increased ? 0.24 : 0.16)
            case .tertiaryFill:
//                #colorLiteral(red: 0.4627451, green: 0.4627451, blue: 0.5019608, alpha: 0.2)
//                #colorLiteral(red: 0.47058824, green: 0.47058824, blue: 0.5019608, alpha: 0.12)
                colorSchemeContrast == .increased
                    ? Color.Resolved(red: 118 / 255, green: 118 / 255, blue: 128 / 255, opacity: 0.2)
                    : Color.Resolved(red: 120 / 255, green: 120 / 255, blue: 128 / 255, opacity: 0.12)
            case .quaternaryFill:
//                #colorLiteral(red: 0.45490196, green: 0.45490196, blue: 0.5019608, alpha: 0.12)
//                #colorLiteral(red: 0.45490196, green: 0.45490196, blue: 0.5019608, alpha: 0.08)
                Color.Resolved(red: 116 / 255, green: 116 / 255, blue: 128 / 255, opacity: colorSchemeContrast == .increased ? 0.12 : 0.08)
            }
        case .dark:
            switch type {
            case .red:
//                #colorLiteral(red: 1.0, green: 0.4117647, blue: 0.38039216, alpha: 1.0)
//                #colorLiteral(red: 1.0, green: 0.27058825, blue: 0.22745098, alpha: 1.0)
                colorSchemeContrast == .increased
                    ? Color.Resolved(red: 1.0, green: 105 / 255, blue: 97 / 255, opacity: 1.0)
                    : Color.Resolved(red: 1.0, green: 69 / 255, blue: 58 / 255, opacity: 1.0)
            case .orange:
//                #colorLiteral(red: 1.0, green: 0.7019608, blue: 0.2509804, alpha: 1.0)
//                #colorLiteral(red: 1.0, green: 0.62352943, blue: 0.039215688, alpha: 1.0)
                colorSchemeContrast == .increased
                    ? Color.Resolved(red: 1.0, green: 179 / 255, blue: 64 / 255, opacity: 1.0)
                    : Color.Resolved(red: 1.0, green: 159 / 255, blue: 10 / 255, opacity: 1.0)
            case .yellow:
//                #colorLiteral(red: 1.0, green: 0.8313726, blue: 0.1490196, alpha: 1.0)
//                #colorLiteral(red: 1.0, green: 0.8392157, blue: 0.039215688, alpha: 1.0)
                colorSchemeContrast == .increased
                    ? Color.Resolved(red: 1.0, green: 212 / 255, blue: 38 / 255, opacity: 1.0)
                    : Color.Resolved(red: 1.0, green: 214 / 255, blue: 10 / 255, opacity: 1.0)
            case .green:
//                #colorLiteral(red: 0.1882353, green: 0.85882354, blue: 0.35686275, alpha: 1.0)
//                #colorLiteral(red: 0.1882353, green: 0.81960785, blue: 0.34509805, alpha: 1.0)
                colorSchemeContrast == .increased
                    ? Color.Resolved(red: 48 / 255, green: 219 / 255, blue: 91 / 255, opacity: 1.0)
                    : Color.Resolved(red: 48 / 255, green: 209 / 255, blue: 88 / 255, opacity: 1.0)
            case .teal:
//                #colorLiteral(red: 0.3647059, green: 0.9019608, blue: 1.0, alpha: 1.0)
//                #colorLiteral(red: 0.2509804, green: 0.78431374, blue: 0.8784314, alpha: 1.0)
                colorSchemeContrast == .increased
                    ? Color.Resolved(red: 93 / 255, green: 230 / 255, blue: 1.0, opacity: 1.0)
                    : Color.Resolved(red: 64 / 255, green: 200 / 255, blue: 224 / 255, opacity: 1.0)
            case .mint:
//                #colorLiteral(red: 0.3882353, green: 0.9019608, blue: 0.8862745, alpha: 1.0)
                Color.Resolved(red: 99 / 255, green: 230 / 255, blue: 226 / 255, opacity: 1.0)
            case .cyan:
//                #colorLiteral(red: 0.039215688, green: 0.84313726, blue: 1.0, alpha: 1.0)
//                #colorLiteral(red: 0.39215687, green: 0.8235294, blue: 1.0, alpha: 1.0)
                colorSchemeContrast == .increased
                    ? Color.Resolved(red: 10 / 255, green: 215 / 255, blue: 1.0, opacity: 1.0)
                    : Color.Resolved(red: 100 / 255, green: 210 / 255, blue: 1.0, opacity: 1.0)
            case .blue:
//                #colorLiteral(red: 0.2509804, green: 0.6117647, blue: 1.0, alpha: 1.0)
//                #colorLiteral(red: 0.039215688, green: 0.5176471, blue: 1.0, alpha: 1.0)
                colorSchemeContrast == .increased
                    ? Color.Resolved(red: 64 / 255, green: 156 / 255, blue: 1.0, opacity: 1.0)
                    : Color.Resolved(red: 10 / 255, green: 132 / 255, blue: 1.0, opacity: 1.0)
            case .indigo:
//                #colorLiteral(red: 0.49019608, green: 0.47843137, blue: 1.0, alpha: 1.0)
//                #colorLiteral(red: 0.36862746, green: 0.36078432, blue: 0.9019608, alpha: 1.0)
                colorSchemeContrast == .increased
                    ? Color.Resolved(red: 125 / 255, green: 122 / 255, blue: 1.0, opacity: 1.0)
                    : Color.Resolved(red: 94 / 255, green: 92 / 255, blue: 230 / 255, opacity: 1.0)
            case .purple:
//                #colorLiteral(red: 0.85490197, green: 0.56078434, blue: 1.0, alpha: 1.0)
//                #colorLiteral(red: 0.7490196, green: 0.3529412, blue: 0.9490196, alpha: 1.0)
                colorSchemeContrast == .increased
                    ? Color.Resolved(red: 218 / 255, green: 143 / 255, blue: 1.0, opacity: 1.0)
                    : Color.Resolved(red: 191 / 255, green: 90 / 255, blue: 242 / 255, opacity: 1.0)
            case .pink:
//                #colorLiteral(red: 1.0, green: 0.39215687, blue: 0.50980395, alpha: 1.0)
//                #colorLiteral(red: 1.0, green: 0.21568628, blue: 0.37254903, alpha: 1.0)
                colorSchemeContrast == .increased
                    ? Color.Resolved(red: 1.0, green: 100 / 255, blue: 130 / 255, opacity: 1.0)
                    : Color.Resolved(red: 1.0, green: 55 / 255, blue: 95 / 255, opacity: 1.0)
            case .brown:
//                #colorLiteral(red: 0.70980394, green: 0.5803922, blue: 0.4117647, alpha: 1.0)
//                #colorLiteral(red: 0.6745098, green: 0.5568628, blue: 0.40784314, alpha: 1.0)
                colorSchemeContrast == .increased
                    ? Color.Resolved(red: 181 / 255, green: 148 / 255, blue: 105 / 255, opacity: 1.0)
                    : Color.Resolved(red: 172 / 255, green: 142 / 255, blue: 104 / 255, opacity: 1.0)
            case .gray:
//                #colorLiteral(red: 0.68235296, green: 0.68235296, blue: 0.69803923, alpha: 1.0)
//                #colorLiteral(red: 0.5568628, green: 0.5568628, blue: 0.5764706, alpha: 1.0)
                colorSchemeContrast == .increased
                    ? Color.Resolved(red: 174 / 255, green: 174 / 255, blue: 178 / 255, opacity: 1.0)
                    : Color.Resolved(red: 142 / 255, green: 142 / 255, blue: 147 / 255, opacity: 1.0)
            case .primary:
//                #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                Color.Resolved(linearRed: 1.0, linearGreen: 1.0, linearBlue: 1.0, opacity: 1.0)
            case .secondary:
//                #colorLiteral(red: 0.92156863, green: 0.92156863, blue: 0.9607843, alpha: 0.7)
//                #colorLiteral(red: 0.92156863, green: 0.92156863, blue: 0.9607843, alpha: 0.6)
                Color.Resolved(red: 235 / 255, green: 235 / 255, blue: 245 / 255, opacity: colorSchemeContrast == .increased ? 0.7 : 0.6)
            case .tertiary:
//                #colorLiteral(red: 0.92156863, green: 0.92156863, blue: 0.9607843, alpha: 0.55)
//                #colorLiteral(red: 0.92156863, green: 0.92156863, blue: 0.9607843, alpha: 0.6)
                Color.Resolved(red: 235 / 255, green: 235 / 255, blue: 245 / 255, opacity: colorSchemeContrast == .increased ? 0.55 : 0.3)
            case .quaternary:
//                #colorLiteral(red: 0.92156863, green: 0.92156863, blue: 0.9607843, alpha: 0.4)
//                #colorLiteral(red: 0.92156863, green: 0.92156863, blue: 0.9607843, alpha: 0.16)
                Color.Resolved(red: 235 / 255, green: 235 / 255, blue: 245 / 255, opacity: colorSchemeContrast == .increased ? 0.4 : 0.16)
            case .quinary:
//                #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.08137255)
//                #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.05)
                Color.Resolved(linearRed: 1.0, linearGreen: 1.0, linearBlue: 1.0, opacity: colorSchemeContrast == .increased ? 0.08137255 : 0.05)
            case .primaryFill:
//                #colorLiteral(red: 0.47058824, green: 0.47058824, blue: 0.5019608, alpha: 0.44)
//                #colorLiteral(red: 0.47058824, green: 0.47058824, blue: 0.5019608, alpha: 0.36)
                Color.Resolved(red: 120 / 255, green: 120 / 255, blue: 128 / 255, opacity: colorSchemeContrast == .increased ? 0.44 : 0.36)
            case .secondaryFill:
//                #colorLiteral(red: 0.47058824, green: 0.47058824, blue: 0.5019608, alpha: 0.4)
//                #colorLiteral(red: 0.47058824, green: 0.47058824, blue: 0.5019608, alpha: 0.32)
                Color.Resolved(red: 120 / 255, green: 120 / 255, blue: 128 / 255, opacity: colorSchemeContrast == .increased ? 0.4 : 0.32)
            case .tertiaryFill:
//                #colorLiteral(red: 0.4627451, green: 0.4627451, blue: 0.5019608, alpha: 0.2)
//                #colorLiteral(red: 0.4627451, green: 0.4627451, blue: 0.5019608, alpha: 0.12)
                Color.Resolved(red: 118 / 255, green: 118 / 255, blue: 128 / 255, opacity: colorSchemeContrast == .increased ? 0.32 : 0.24)
            case .quaternaryFill:
//                #colorLiteral(red: 0.45490196, green: 0.45490196, blue: 0.5019608, alpha: 0.26)
//                #colorLiteral(red: 0.45490196, green: 0.45490196, blue: 0.5019608, alpha: 0.18)
                Color.Resolved(red: 116 / 255, green: 116 / 255, blue: 128 / 255, opacity: colorSchemeContrast == .increased ? 0.26 : 0.18)
            }
        }
    }
}

// MARK: - TestingSystemColorDefinition

struct TestingSystemColorDefinition: SystemColorDefinition {
    static func value(for type: SystemColorType, environment: EnvironmentValues) -> Color.Resolved {
        switch type {
        case .red: Color.Resolved(linearRed: 1.0, linearGreen: 0.0, linearBlue: 0.0, opacity: 1.0)
        case .orange: Color.Resolved(linearRed: 1.0, linearGreen: 0.214, linearBlue: 0.0, opacity: 1.0)
        case .yellow: Color.Resolved(linearRed: 1.0, linearGreen: 1.0, linearBlue: 0.0, opacity: 1.0)
        case .green: Color.Resolved(linearRed: 0.0, linearGreen: 1.0, linearBlue: 0.0, opacity: 1.0)
        case .teal, .mint, .cyan: Color.Resolved(linearRed: 0.0, linearGreen: 1.0, linearBlue: 1.0, opacity: 1.0)
        case .blue: Color.Resolved(linearRed: 0.0, linearGreen: 0.0, linearBlue: 1.0, opacity: 1.0)
        case .indigo: Color.Resolved(linearRed: 0.214, linearGreen: 0.214, linearBlue: 1.0, opacity: 1.0)
        case .purple: Color.Resolved(linearRed: 0.214, linearGreen: 0.0, linearBlue: 0.214, opacity: 1.0)
        case .pink: Color.Resolved(linearRed: 1.0, linearGreen: 0.0, linearBlue: 0.214, opacity: 1.0)
        case .brown: Color.Resolved(linearRed: 0.214, linearGreen: 0.214, linearBlue: 0.0, opacity: 1.0)
        case .gray: Color.Resolved(linearRed: 0.0319, linearGreen: 0.0319, linearBlue: 0.0319, opacity: 1.0)
        case .primary, .secondary:
            environment.colorScheme == .dark
                ? Color.Resolved(linearRed: 1.0, linearGreen: 1.0, linearBlue: 1.0, opacity: 1.0)
                : Color.Resolved(linearRed: 0.0, linearGreen: 0.0, linearBlue: 0.0, opacity: 1.0)
        case .tertiary, .quaternary, .quinary, .primaryFill:
            value(for: .gray, environment: environment)
        case .secondaryFill, .tertiaryFill, .quaternaryFill:
            Color.Resolved(linearRed: 0.21404114, linearGreen: 0.21404114, linearBlue: 0.21404114, opacity: 0.25)
        }
    }
    static func opacity(at level: Int, environment: EnvironmentValues) -> Float {
        if level == 2 {
            0.5
        } else if level == 1 {
            0.75
        } else if level <= 0 {
            1.0
        } else {
            0.25
        }
    }
}

// MARK: - SystemColorsStyle

package struct SystemColorsStyle: ShapeStyle, PrimitiveShapeStyle {
    package init() {}

    package func _apply(to shape: inout _ShapeStyle_Shape) {
        switch shape.operation {
        case let .prepareText(level):
            let id = ContentStyle.ID(truncatingLevel: level)
            let color = Color(id)
            shape.result = .preparedText(.foregroundColor(color))
        case let .resolveStyle(name, levels):
            let id = ContentStyle.ID(truncatingLevel: levels.lowerBound)
            let resolved = id.resolve(in: shape.environment)
            shape.stylePack[name, levels.lowerBound] = .init(.color(resolved))
        case let .fallbackColor(level):
            let id = ContentStyle.ID(truncatingLevel: level)
            let color = Color(id)
            shape.result = .color(color)
        default:
            break
        }
    }

    package typealias Resolved = Never
}
