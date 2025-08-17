//
//  ContentSizeCategory.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

/// The sizes that you can specify for content.
@available(OpenSwiftUI_v1_0, *)
@available(*, deprecated, renamed: "DynamicTypeSize")
public enum ContentSizeCategory: Hashable, CaseIterable {
    case extraSmall
    case small
    case medium
    case large
    case extraLarge
    case extraExtraLarge
    case extraExtraExtraLarge
    case accessibilityMedium
    case accessibilityLarge
    case accessibilityExtraLarge
    case accessibilityExtraExtraLarge
    case accessibilityExtraExtraExtraLarge
    
    package init(_ size: DynamicTypeSize) {
        self = switch size {
        case .xSmall: .extraSmall
        case .small: .small
        case .medium: .medium
        case .large: .large
        case .xLarge: .extraLarge
        case .xxLarge: .extraExtraLarge
        case .xxxLarge: .extraExtraExtraLarge
        case .accessibility1: .accessibilityMedium
        case .accessibility2: .accessibilityLarge
        case .accessibility3: .accessibilityExtraLarge
        case .accessibility4: .accessibilityExtraExtraLarge
        case .accessibility5: .accessibilityExtraExtraExtraLarge
        }
    }

    /// A Boolean value indicating whether the content size category is one that
    /// is associated with accessibility.
    @available(OpenSwiftUI_v1_4, *)
    public var isAccessibilityCategory: Bool {
        switch self {
        case .accessibilityMedium,
             .accessibilityLarge, .accessibilityExtraLarge,
             .accessibilityExtraExtraLarge, .accessibilityExtraExtraExtraLarge:
            return true
        default:
            return false
        }
    }
}

@available(*, unavailable)
extension ContentSizeCategory: Sendable {}

extension DynamicTypeSize {
    package init(_ size: ContentSizeCategory) {
        self = switch size {
        case .extraSmall: .xSmall
        case .small: .small
        case .medium: .medium
        case .large: .large
        case .extraLarge: .xLarge
        case .extraExtraLarge: .xxLarge
        case .extraExtraExtraLarge: .xxxLarge
        case .accessibilityMedium: .accessibility1
        case .accessibilityLarge: .accessibility2
        case .accessibilityExtraLarge: .accessibility3
        case .accessibilityExtraExtraLarge: .accessibility4
        case .accessibilityExtraExtraExtraLarge: .accessibility5
        }
    }
}

@available(OpenSwiftUI_v2_0, *)
extension ContentSizeCategory {
    @_alwaysEmitIntoClient
    public static func < (lhs: ContentSizeCategory, rhs: ContentSizeCategory) -> Bool {
        func comparisonValue(for sizeCategory: Self) -> Int {
            switch sizeCategory {
            case .extraSmall: return 0
            case .small: return 1
            case .medium: return 2
            case .large: return 3
            case .extraLarge: return 4
            case .extraExtraLarge: return 5
            case .extraExtraExtraLarge: return 6
            case .accessibilityMedium: return 7
            case .accessibilityLarge: return 8
            case .accessibilityExtraLarge: return 9
            case .accessibilityExtraExtraLarge: return 10
            case .accessibilityExtraExtraExtraLarge: return 11
            @unknown default: return 3
            }
        }
        return comparisonValue(for: lhs) < comparisonValue(for: rhs)
    }
    
    @_alwaysEmitIntoClient
    public static func <= (lhs: ContentSizeCategory, rhs: ContentSizeCategory) -> Bool {
        !(rhs < lhs)
    }
    
    @_alwaysEmitIntoClient
    public static func > (lhs: ContentSizeCategory, rhs: ContentSizeCategory) -> Bool {
        rhs < lhs
    }
    
    @_alwaysEmitIntoClient
    public static func >= (lhs: ContentSizeCategory, rhs: ContentSizeCategory) -> Bool {
        !(lhs < rhs)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension EnvironmentValues {
    /// The preferred size of the content.
    ///
    /// The default value is ``ContentSizeCategory/large``.
    @available(OpenSwiftUI_v1_0, *)
    @available(*, deprecated, renamed: "dynamicTypeSize")
    public var sizeCategory: ContentSizeCategory {
        get { .init(dynamicTypeSize) }
        set { dynamicTypeSize = .init(newValue) }
    }
}
