//
//  SystemColor.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: 9E3352CE4697DF56A738786E16992848 (SwiftUICore?)

import OpenSwiftUI_SPI

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

// MARK: - SystemColorType [WIP]

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
        guard _SemanticFeature_v3.isEnabled else {
            _apply(color: color, to: &shape)
            return
        }
        switch self {
            case .primary:
                LegacyContentStyle(id: .primary, color: color)._apply(to: &shape)
            case .secondary:
                LegacyContentStyle(id: .secondary, color: color)._apply(to: &shape)
            case .tertiary:
                LegacyContentStyle(id: .tertiary, color: color)._apply(to: &shape)
            case .quaternary:
                LegacyContentStyle(id: .quaternary, color: color)._apply(to: &shape)
            case .quinary:
                LegacyContentStyle(id: .quinary, color: color)._apply(to: &shape)
            default:
                // TODO: BackgroundMaterialKey + Material
                break
        }
    }
    
    package var kitColor: AnyObject? {
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
    }
}

// MARK: - SystemColorDefinition [WIP]

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
    static var defaultValue: SystemColorDefinitionType { SystemColorDefinitionType(base: CoreUIDefaultSystemColorDefinition.self) }
}

extension EnvironmentValues {
    var systemColorDefinition: SystemColorDefinitionType {
        self[SystemColorDefinitionKey.self]
    }
}

struct CoreUIDefaultSystemColorDefinition: SystemColorDefinition {
    static func value(for type: SystemColorType, environment: EnvironmentValues) -> Color.Resolved {
        // CUIDesignLibraryCacheKey
        fatalError("TODO")
    }
}

struct TestingSystemColorDefinition: SystemColorDefinition {
    static func value(for type: SystemColorType, environment: EnvironmentValues) -> Color.Resolved {
        fatalError("TODO")
    }
}

// MARK: - SystemColorsStyle [TODO]

//package struct SystemColorsStyle : ShapeStyle, PrimitiveShapeStyle {
//  package init()
//  package func _apply(to shape: inout _ShapeStyle_Shape)
//  @available(iOS 17.0, tvOS 17.0, watchOS 10.0, macOS 14.0, *)
//  package typealias Resolved = Never
//}
