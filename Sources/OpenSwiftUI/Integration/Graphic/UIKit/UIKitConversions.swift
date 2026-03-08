//
//  UIKitConversions.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 6DC24D5146AF4B80347A1025025F68EE (SwiftUI)

#if canImport(UIKit)

public import OpenSwiftUICore
public import UIKit
import COpenSwiftUI

// MARK: - UIColor Conversions

@available(OpenSwiftUI_v1_0, *)
@available(*, deprecated, message: "Use Color(uiColor:) when converting a UIColor, or create a standard Color directly")
@available(macOS, unavailable)
extension Color {
    /// Creates a color from a UIKit color.
    ///
    /// Use this method to create a OpenSwiftUI color from a
    /// [UIColor](https://developer.apple.com/documentation/UIKit/UIColor) instance.
    /// The new color preserves the adaptability of the original.
    /// For example, you can create a rectangle using
    /// [link](https://developer.apple.com/documentation/uikit/uicolor/3173132-link)
    /// to see how the shade adjusts to match the user's system settings:
    ///
    ///     struct Box: View {
    ///         var body: some View {
    ///             Color(UIColor.link)
    ///                 .frame(width: 200, height: 100)
    ///         }
    ///     }
    ///
    /// The `Box` view defined above automatically changes its
    /// appearance when the user turns on Dark Mode. With the light and dark
    /// appearances placed side by side, you can see the subtle difference
    /// in shades:
    ///
    /// ![A side by side comparison of light and dark appearance screenshots of
    ///   rectangles rendered with the link color. The light variant appears on
    ///   the left, and the dark variant on the right.](Color-init-3)
    ///
    /// > Note: Use this initializer only if you need to convert an existing
    /// [UIColor](https://developer.apple.com/documentation/UIKit/UIColor) to a
    /// OpenSwiftUI color. Otherwise, create an OpenSwiftUI ``Color`` using an
    /// initializer like ``init(_:red:green:blue:opacity:)``, or use a system
    /// color like ``ShapeStyle/blue``.
    ///
    /// - Parameter color: A
    ///   [UIColor](https://developer.apple.com/documentation/UIKit/UIColor) instance
    ///   from which to create a color.
    @_disfavoredOverload
    public init(_ color: UIColor) {
        self.init(uiColor: color)
    }
}

@available(OpenSwiftUI_v3_0, *)
@available(macOS, unavailable)
extension Color {
    /// Creates a color from a UIKit color.
    ///
    /// Use this method to create a OpenSwiftUI color from a
    /// [UIColor](https://developer.apple.com/documentation/UIKit/UIColor) instance.
    /// The new color preserves the adaptability of the original.
    /// For example, you can create a rectangle using
    /// [link](https://developer.apple.com/documentation/uikit/uicolor/3173132-link)
    /// to see how the shade adjusts to match the user's system settings:
    ///
    ///     struct Box: View {
    ///         var body: some View {
    ///             Color(UIColor.link)
    ///                 .frame(width: 200, height: 100)
    ///         }
    ///     }
    ///
    /// The `Box` view defined above automatically changes its
    /// appearance when the user turns on Dark Mode. With the light and dark
    /// appearances placed side by side, you can see the subtle difference
    /// in shades:
    ///
    /// ![A side by side comparison of light and dark appearance screenshots of
    ///   rectangles rendered with the link color. The light variant appears on
    ///   the left, and the dark variant on the right.](Color-init-3)
    ///
    /// > Note: Use this initializer only if you need to convert an existing
    /// [UIColor](https://developer.apple.com/documentation/UIKit/UIColor) to a
    /// OpenSwiftUI color. Otherwise, create an OpenSwiftUI ``Color`` using an
    /// initializer like ``init(_:red:green:blue:opacity:)``, or use a system
    /// color like ``ShapeStyle/blue``.
    ///
    /// - Parameter color: A
    ///   [UIColor](https://developer.apple.com/documentation/UIKit/UIColor) instance
    ///   from which to create a color.
    public init(uiColor: UIColor) {
        self.init(provider: uiColor)
    }
}

private let dynamicColorCache: NSMapTable<ObjcColor, UIColor> = NSMapTable.strongToWeakObjects()

extension UIColor: ColorProvider {
    @available(OpenSwiftUI_v2_0, *)
    @available(macOS, unavailable)
    convenience public init(_ color: Color) {
        if let color = color.provider.as(UIColor.self) {
            self.init(color__openSwiftUI__: color)
        } else if let cgColor = color.provider.staticColor {
            self.init(cgColor: cgColor)
        } else {
            let objCColor = ObjcColor(color)
            let cache = dynamicColorCache
            if let color = cache.object(forKey: objCColor) {
                self.init(color__openSwiftUI__: color)
            } else {
                let value: UIColor
                if let kitColor = color.provider.kitColor {
                    value = kitColor as! UIColor
                } else {
                    value = UIColor { trait in
                        let env = trait.resolvedEnvironment(base: trait.environment)
                        let resolved = color.resolve(in: env)
                        return resolved.kitColor as! UIColor
                    }
                }
                self.init(color__openSwiftUI__: value)
                cache.setObject(value, forKey: objCColor)
            }
        }
    }
    
    package func resolve(in environment: EnvironmentValues) -> Color.Resolved {
        if _UIColorDependsOnTraitCollection(self) {
            let trait = UITraitCollection.current.byOverriding(with: environment, viewPhase: .init(), focusedValues: .init())
            let color = resolvedColor(with: trait)
            return Color.Resolved(platformColor: color) ?? .clear
        } else {
            return Color.Resolved(cgColor)
        }
    }
    
    package var staticColor: CGColor? {
        if _UIColorDependsOnTraitCollection(self) {
            nil
        } else {
            cgColor
        }
    }
}

// MARK: - UIUserInterfaceStyle Conversions

extension ColorScheme {

    /// Creates a color scheme from its user interface style equivalent.
    @available(OpenSwiftUI_v2_0, *)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    public init?(_ uiUserInterfaceStyle: UIUserInterfaceStyle) {
        switch uiUserInterfaceStyle {
            case .unspecified: return nil
            case .light: self = .light
            case .dark: self = .dark
            @unknown default: return nil
        }
    }
}

extension UIUserInterfaceStyle {

    /// Creates a user interface style from its ColorScheme equivalent.
    @available(OpenSwiftUI_v2_0, *)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    public init(_ colorScheme: ColorScheme?) {
        switch colorScheme {
            case .light: self = .light
            case .dark: self = .dark
            case nil: self = .unspecified
        }
    }
}

// MARK: - UIAccessibilityContrast Conversions

extension ColorSchemeContrast {

    /// Creates a contrast from its accessibility contrast equivalent.
    @available(OpenSwiftUI_v2_0, *)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    public init?(_ uiAccessibilityContrast: UIAccessibilityContrast) {
        switch uiAccessibilityContrast {
        case .normal: self = .standard
        case .high: self = .increased
        default: return nil
        }
    }
}

extension UIAccessibilityContrast {

    /// Create a contrast from its ColorSchemeContrast equivalent.
    /// 
    @available(OpenSwiftUI_v2_0, *)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    public init(_ colorSchemeContrast: ColorSchemeContrast?) {
        switch colorSchemeContrast {
            case .standard: self = .normal
            case .increased: self = .high
            case nil: self = .unspecified
            @unknown default: _openSwiftUIUnreachableCode()
        }
    }
}

// MARK: - UIContentSizeCategory Conversions

extension ContentSizeCategory {

    /// Create a size category from its UIContentSizeCategory equivalent.
    @available(OpenSwiftUI_v2_0, *)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    public init?(_ uiSizeCategory: UIContentSizeCategory) {
        switch uiSizeCategory {
        case .extraSmall: self = .extraSmall
        case .small: self = .small
        case .medium: self = .medium
        case .large: self = .large
        case .extraLarge: self = .extraLarge
        case .extraExtraLarge: self = .extraExtraLarge
        case .extraExtraExtraLarge: self = .extraExtraExtraLarge
        case .accessibilityMedium: self = .accessibilityMedium
        case .accessibilityLarge: self = .accessibilityLarge
        case .accessibilityExtraLarge: self = .accessibilityExtraLarge
        case .accessibilityExtraExtraLarge: self = .accessibilityExtraExtraLarge
        case .accessibilityExtraExtraExtraLarge: self = .accessibilityExtraExtraExtraLarge
        default: return nil
        }
    }
}

@available(OpenSwiftUI_v3_0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
extension DynamicTypeSize {

    /// Create a Dynamic Type size from its `UIContentSizeCategory` equivalent.
    public init?(_ uiSizeCategory: UIContentSizeCategory) {
        switch uiSizeCategory {
        case .extraSmall: self = .xSmall
        case .small: self = .small
        case .medium: self = .medium
        case .large: self = .large
        case .extraLarge: self = .xLarge
        case .extraExtraLarge: self = .xxLarge
        case .extraExtraExtraLarge: self = .xxxLarge
        case .accessibilityMedium: self = .accessibility1
        case .accessibilityLarge: self = .accessibility2
        case .accessibilityExtraLarge: self = .accessibility3
        case .accessibilityExtraExtraLarge: self = .accessibility4
        case .accessibilityExtraExtraExtraLarge: self = .accessibility5
        default: return nil
        }
    }
}

extension UIContentSizeCategory {

    /// Create a size category from its `ContentSizeCategory` equivalent.
    @available(OpenSwiftUI_v2_0, *)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    public init(_ sizeCategory: ContentSizeCategory?) {
        switch sizeCategory {
        case .extraSmall: self = .extraSmall
        case .small: self = .small
        case .medium: self = .medium
        case .large: self = .large
        case .extraLarge: self = .extraLarge
        case .extraExtraLarge: self = .extraExtraLarge
        case .extraExtraExtraLarge: self = .extraExtraExtraLarge
        case .accessibilityMedium: self = .accessibilityMedium
        case .accessibilityLarge: self = .accessibilityLarge
        case .accessibilityExtraLarge: self = .accessibilityExtraLarge
        case .accessibilityExtraExtraLarge: self = .accessibilityExtraExtraLarge
        case .accessibilityExtraExtraExtraLarge: self = .accessibilityExtraExtraExtraLarge
        case nil: self = .unspecified
        @unknown default: _openSwiftUIUnreachableCode()
        }
    }

    @available(OpenSwiftUI_v3_0, *)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    public init(_ dynamicTypeSize: DynamicTypeSize?) {
        switch dynamicTypeSize {
        case .xSmall: self = .extraSmall
        case .small: self = .small
        case .medium: self = .medium
        case .large: self = .large
        case .xLarge: self = .extraLarge
        case .xxLarge: self = .extraExtraLarge
        case .xxxLarge: self = .extraExtraExtraLarge
        case .accessibility1: self = .accessibilityMedium
        case .accessibility2: self = .accessibilityLarge
        case .accessibility3: self = .accessibilityExtraLarge
        case .accessibility4: self = .accessibilityExtraExtraLarge
        case .accessibility5: self = .accessibilityExtraExtraExtraLarge
        case nil: self = .unspecified
        @unknown default: _openSwiftUIUnreachableCode()
        }
    }
}

// MARK: UITraitEnvironmentLayoutDirection Conversions

extension LayoutDirection {

    /// Create a direction from its UITraitEnvironmentLayoutDirection equivalent.
    @available(OpenSwiftUI_v2_0, *)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    public init?(_ uiLayoutDirection: UITraitEnvironmentLayoutDirection) {
        switch uiLayoutDirection {
        case .unspecified:
            return nil
        case .leftToRight:
            self = .leftToRight
        case .rightToLeft:
            self = .rightToLeft
        @unknown default:
            return nil
        }
    }
}

extension UITraitEnvironmentLayoutDirection {

    /// Create a direction from its LayoutDirection equivalent.
    @available(OpenSwiftUI_v2_0, *)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    public init(_ layoutDirection: LayoutDirection) {
        switch layoutDirection {
        case .leftToRight: self = .leftToRight
        case .rightToLeft: self = .rightToLeft
        }
    }
}

// MARK: - UILegibilityWeight Conversions

extension LegibilityWeight {

    /// Creates a legibility weight from its UILegibilityWeight equivalent.
    @available(OpenSwiftUI_v2_0, *)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    public init?(_ uiLegibilityWeight: UILegibilityWeight) {
        switch uiLegibilityWeight {
        case .regular: self = .regular
        case .bold: self = .bold
        case .unspecified: return nil
        @unknown default: return nil
        }
    }
}

extension UILegibilityWeight {

    /// Creates a legibility weight from its LegibilityWeight equivalent.
    @available(OpenSwiftUI_v2_0, *)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    public init(_ legibilityWeight: LegibilityWeight?) {
        switch legibilityWeight {
        case .regular: self = .regular
        case .bold: self = .bold
        case nil: self = .unspecified
        @unknown default: _openSwiftUIUnreachableCode()
        }
    }
}

// MARK: - UIUserInterfaceSizeClass Conversions

extension UserInterfaceSizeClass {

    /// Creates a OpenSwiftUI size class from the specified UIKit size class.
    @available(OpenSwiftUI_v2_0, *)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public init?(_ uiUserInterfaceSizeClass: UIUserInterfaceSizeClass) {
        switch uiUserInterfaceSizeClass {
        case .compact: self = .compact
        case .regular: self = .regular
        case .unspecified: return nil
        @unknown default: return nil
        }
    }
}

extension UIUserInterfaceSizeClass {

    /// Creates a UIKit size class from the specified OpenSwiftUI size class.
    @available(OpenSwiftUI_v2_0, *)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public init(_ sizeClass: UserInterfaceSizeClass?) {
        switch sizeClass {
        case .compact: self = .compact
        case .regular: self = .regular
        case nil: self = .unspecified
        @unknown default: _openSwiftUIUnreachableCode()
        }
    }
}

// MARK: - Animation Conversions

extension Animation {
    package var caBasicAnimation: CABasicAnimation? {
        switch function {
        case .linear, .circularEaseIn, .circularEaseOut, .circularEaseInOut, .bezier:
            guard let bezierForm = function.bezierForm else {
                return nil
            }
            let animation = CABasicAnimation()
            animation.timeOffset = 0
            animation.speed = 1
            let timingFunction = CAMediaTimingFunction(
                controlPoints: Float(bezierForm.cp1.x),
                Float(bezierForm.cp1.y),
                Float(bezierForm.cp2.x),
                Float(bezierForm.cp2.y)
            )
            animation.timingFunction = timingFunction
            animation.duration = bezierForm.duration
            return animation
        case let .spring(duration, mass, stiffness, damping, initialVelocity):
            let animation = CASpringAnimation()
            animation.timeOffset = 0
            animation.speed = 1
            animation.duration = duration
            animation.mass = mass
            animation.stiffness = stiffness
            animation.damping = damping
            animation.initialVelocity = initialVelocity
            return animation
        default:
            return nil
        }
    }

    package static func uiViewAnimation(curve: Int, duration: Double) -> Animation? {
        switch curve {
        case 0: .easeInOut(duration: duration)
        case 1: .easeIn(duration: duration)
        case 2: .easeOut(duration: duration)
        case 3: .linear(duration: duration)
        case 4: .timingCurve(0.66, 0, 0.33, 1.0, duration: duration)
        case 5: .coreAnimationDefault(duration: duration)
        case 6: .easeInOut(duration: duration)
        case 7: .interpolatingSpring(mass: 3.0, stiffness: 1000.0, damping: 500.0, initialVelocity: 0.0)
        default: nil
        }
    }
}

// MARK: - Transaction + UIView Animation

extension Transaction {
    package static func currentUIViewTransaction(canDisableAnimations: Bool) -> Transaction? {
        if canDisableAnimations, !UIView.areAnimationsEnabled {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            return transaction
        }
        guard UIView._isInAnimationBlockWithAnimationsEnabled else {
            return nil
        }
        let duration = UIView._currentAnimationDuration
        let curve = UIView._currentAnimationCurve
        guard let animation = Animation.uiViewAnimation(curve: curve, duration: duration) else {
            return nil
        }
        var transaction = Transaction(animation: animation)
        if let item = _CATransactionCompletionItem() {
            transaction.addAnimationListener {
                item.invalidate()
            }
        }
        return transaction
    }
}

// WIP

// MARK: - UIUserInterfaceIdiom Conversions

extension UIUserInterfaceIdiom {
    package var idiom: AnyInterfaceIdiom? {
        switch self {
        case .phone: AnyInterfaceIdiom(.phone)
        case .pad: AnyInterfaceIdiom(.pad)
        case .tv: AnyInterfaceIdiom(.tv)
        case .carPlay: AnyInterfaceIdiom(.carPlay)
        case .watch: AnyInterfaceIdiom(.watch)
        case .mac: AnyInterfaceIdiom(.mac)
        case .vision: AnyInterfaceIdiom(.vision)
        default: nil
        }
    }
}

extension UIUserInterfaceIdiom {
    static let watch = UIUserInterfaceIdiom(rawValue: 4)!
}

#endif
