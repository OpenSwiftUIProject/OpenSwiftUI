//
//  DynamicTypeSize.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: B498FA81088CF7FADFFFFFC897E05C74 (SwiftUICore)

/// A Dynamic Type size, which specifies how large scalable content should be.
///
/// For more information, see
/// [Typography](https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/typography/)
/// in the Human Interface Guidelines.
public enum DynamicTypeSize: Hashable, Comparable, CaseIterable, Sendable {
    /// An extra small size.
    case xSmall

    /// A small size.
    case small

    /// A medium size.
    case medium

    /// A large size.
    case large

    /// An extra large size.
    case xLarge

    /// An extra extra large size.
    case xxLarge

    /// An extra extra extra large size.
    case xxxLarge

    /// The first accessibility size.
    case accessibility1

    /// The second accessibility size.
    case accessibility2

    /// The third accessibility size.
    case accessibility3

    /// The fourth accessibility size.
    case accessibility4

    /// The fifth accessibility size.
    case accessibility5

    /// A Boolean value indicating whether the size is one that is associated
    /// with accessibility.
    public var isAccessibilitySize: Bool {
        switch self {
        case .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5: true
        default: false
        }
    }

    package static var systemDefault: DynamicTypeSize {
        CoreGlue2.shared.systemDefaultDynamicTypeSize
    }
}

private struct DynamicTypeSizeKey: EnvironmentKey {
    static var defaultValue: DynamicTypeSize { .large }
}

extension EnvironmentValues {
    public var dynamicTypeSize: DynamicTypeSize {
        get { self[DynamicTypeSizeKey.self] }
        set { self[DynamicTypeSizeKey.self] = newValue }
    }
}

extension View {
    nonisolated public func dynamicTypeSize(_ size: DynamicTypeSize) -> some View {
        self.environment(\.dynamicTypeSize, size)
    }

    nonisolated public func dynamicTypeSize<T>(_ range: T) -> some View where T: RangeExpression, T.Bound == DynamicTypeSize {
        self.transformEnvironment(\.dynamicTypeSize) { $0 = $0.clamped(to: range) }
    }
}

private struct DynamicTypeSizeCollection: Collection {
    func index(after i: DynamicTypeSize) -> DynamicTypeSize {
        let index = DynamicTypeSize.allCases.firstIndex(of: i)!
        let targetIndex = index + 1
        let count = DynamicTypeSize.allCases.count
        let resultIndex = targetIndex < count ? targetIndex : count-1
        return DynamicTypeSize.allCases[resultIndex]
    }
    
    subscript(position: DynamicTypeSize) -> Element {
        _read { yield position }
    }

    typealias Index = DynamicTypeSize

    typealias Element = DynamicTypeSize

    var startIndex: Index { .small }

    var endIndex: Index { .accessibility5 }
}

extension DynamicTypeSize {
    package func clamped<T>(to range: T) -> DynamicTypeSize where T: RangeExpression, T.Bound == DynamicTypeSize {
        let bound = range.relative(to: DynamicTypeSizeCollection())

        let upperBound: DynamicTypeSize
        if range.contains(bound.upperBound) {
            upperBound = bound.upperBound
        } else {
            let index = DynamicTypeSize.allCases.firstIndex(of: bound.upperBound)!
            let targetIndex = index + 1
            let resultIndex = max(0, index)
            upperBound = DynamicTypeSize.allCases[resultIndex]
        }
        return clamp(min: bound.lowerBound, max: upperBound)
    }
}
