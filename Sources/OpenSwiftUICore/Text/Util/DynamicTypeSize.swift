//
//  DynamicTypeSize.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: B498FA81088CF7FADFFFFFC897E05C74 (SwiftUICore)

/// A Dynamic Type size, which specifies how large scalable content should be.
///
/// For more information, see
/// [Typography](https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/typography/)
/// in the Human Interface Guidelines.
@available(OpenSwiftUI_v3_0, *)
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
        case .accessibility1, .accessibility2,
             .accessibility3, .accessibility4,
             .accessibility5:
            true
        default:
            false
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
    /// The current Dynamic Type size.
    ///
    /// This value changes as the user's chosen Dynamic Type size changes. The
    /// default value is device-dependent.
    ///
    /// When limiting the Dynamic Type size, consider if adding a
    /// large content view with ``View/accessibilityShowsLargeContentViewer()``
    /// would be appropriate.
    ///
    /// On macOS, this value cannot be changed by users and does not affect the
    /// text size.
    public var dynamicTypeSize: DynamicTypeSize {
        get { self[DynamicTypeSizeKey.self] }
        set { self[DynamicTypeSizeKey.self] = newValue }
    }
}

@available(OpenSwiftUI_v3_0, *)
extension View {
    /// Sets the Dynamic Type size within the view to the given value.
    ///
    /// As an example, you can set a Dynamic Type size in `ContentView` to be
    /// ``DynamicTypeSize/xLarge`` (this can be useful in previews to see your
    /// content at a different size) like this:
    ///
    ///     ContentView()
    ///         .dynamicTypeSize(.xLarge)
    ///
    /// If a Dynamic Type size range is applied after setting a value,
    /// the value is limited by that range:
    ///
    ///     ContentView() // Dynamic Type size will be .large
    ///         .dynamicTypeSize(...DynamicTypeSize.large)
    ///         .dynamicTypeSize(.xLarge)
    ///
    /// When limiting the Dynamic Type size, consider if adding a
    /// large content view with ``View/accessibilityShowsLargeContentViewer()``
    /// would be appropriate.
    ///
    /// - Parameter size: The size to set for this view.
    ///
    /// - Returns: A view that sets the Dynamic Type size to the specified
    ///   `size`.
    nonisolated public func dynamicTypeSize(_ size: DynamicTypeSize) -> some View {
        environment(\.dynamicTypeSize, size)
    }

    /// Limits the Dynamic Type size within the view to the given range.
    ///
    /// As an example, you can constrain the maximum Dynamic Type size in
    /// `ContentView` to be no larger than ``DynamicTypeSize/large``:
    ///
    ///     ContentView()
    ///         .dynamicTypeSize(...DynamicTypeSize.large)
    ///
    /// If the Dynamic Type size is limited to multiple ranges, the result is
    /// their intersection:
    ///
    ///     ContentView() // Dynamic Type sizes are from .small to .large
    ///         .dynamicTypeSize(.small...)
    ///         .dynamicTypeSize(...DynamicTypeSize.large)
    ///
    /// A specific Dynamic Type size can still be set after a range is applied:
    ///
    ///     ContentView() // Dynamic Type size is .xLarge
    ///         .dynamicTypeSize(.xLarge)
    ///         .dynamicTypeSize(...DynamicTypeSize.large)
    ///
    /// When limiting the Dynamic Type size, consider if adding a
    /// large content view with ``View/accessibilityShowsLargeContentViewer()``
    /// would be appropriate.
    ///
    /// - Parameter range: The range of sizes that are allowed in this view.
    ///
    /// - Returns: A view that constrains the Dynamic Type size of this view
    ///   within the specified `range`.
    nonisolated public func dynamicTypeSize<T>(_ range: T) -> some View where T: RangeExpression, T.Bound == DynamicTypeSize {
        transformEnvironment(\.dynamicTypeSize) {
            $0 = $0.clamped(to: range)
        }
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
