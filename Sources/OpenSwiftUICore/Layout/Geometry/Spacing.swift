//
//  Spacing.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: 127A76D3C8081D0134153BE9AE746714 (SwiftUI)
//  ID: EF1C7FCB82CB27FA7772A4944789FD3D (SwiftUICore)

package import Foundation

/// The default spacing value used throughout the framework
package let defaultSpacingValue = CoreGlue.shared.defaultSpacing

// MARK: Spacing

/// A structure that represents spacing between views in a layout
///
/// Spacing is used to define the distances between views in various contexts, such as
/// within stacks, grids, and other container views. It supports both fixed distances
/// and text-aware spacing metrics.
@_spi(ForOpenSwiftUIOnly)
public struct Spacing: Equatable, Sendable {
    // MARK: - Spacing.Category

    /// A type that categorizes different types of spacing
    ///
    /// Categories allow the spacing system to apply different rules for different
    /// spacing contexts, such as text-to-text spacing, edge spacing, and baseline spacing.
    package struct Category: Hashable {
        /// The underlying type used to uniquely identify this category
        var type: any Any.Type

        /// Creates a new spacing category from the given type
        ///
        /// - Parameter t: The type used to identify this category
        package init(_ t: any Any.Type) {
            self.type = t
        }

        package func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(type))
        }

        package static func == (lhs: Spacing.Category, rhs: Spacing.Category) -> Bool {
            lhs.type == rhs.type
        }
    }

    // MARK: - Spacing.Key

    /// A key that uniquely identifies a spacing value by its category and edge
    ///
    /// A spacing key combines a category (optional) with an absolute edge to identify
    /// a specific spacing value within a `Spacing` instance.
    package struct Key: Hashable {
        /// The optional category for this spacing key
        package var category: Category?

        /// The absolute edge this spacing applies to
        package var edge: AbsoluteEdge

        /// Creates a new spacing key with the given category and edge
        ///
        /// - Parameters:
        ///   - category: The optional category for this spacing
        ///   - edge: The absolute edge this spacing applies to
        package init(category: Category?, edge: AbsoluteEdge) {
            self.category = category
            self.edge = edge
        }
    }

    // MARK: - Spacing.TextMetrics

    /// Metrics that define spacing in the context of text layout
    ///
    /// TextMetrics captures the vertical dimensions of text, including ascenders, descenders,
    /// and leading, which are used to calculate appropriate spacing between text elements.
    package struct TextMetrics: Comparable {
        /// The ascend height of the text (distance above the baseline)
        package var ascend: CGFloat

        /// The descend height of the text (distance below the baseline)
        package var descend: CGFloat

        /// The leading space between lines of text
        package var leading: CGFloat

        /// The pixel length used for rounding
        package var pixelLength: CGFloat

        /// Creates a new TextMetrics instance with the specified dimensions
        ///
        /// - Parameters:
        ///   - ascend: The ascend height of the text
        ///   - descend: The descend height of the text
        ///   - leading: The leading space between lines
        ///   - pixelLength: The pixel length used for rounding
        package init(ascend: CGFloat, descend: CGFloat, leading: CGFloat, pixelLength: CGFloat) {
            self.ascend = ascend
            self.descend = descend
            self.leading = leading
            self.pixelLength = pixelLength
        }

        /// The total line spacing (ascend + descend + leading)
        package var lineSpacing: CGFloat {
            ascend + descend + leading
        }

        package static func < (lhs: TextMetrics, rhs: TextMetrics) -> Bool {
            lhs.lineSpacing < rhs.lineSpacing
        }

        /// Determines if this TextMetrics instance is approximately equal to another
        ///
        /// Two TextMetrics instances are considered approximately equal if their ascend, descend,
        /// and leading values are approximately equal, regardless of pixel length.
        ///
        /// - Parameter other: The TextMetrics to compare with
        /// - Returns: True if the metrics are approximately equal
        package func isAlmostEqual(to other: TextMetrics) -> Bool {
            return ascend.isAlmostEqual(to: other.ascend)
                && descend.isAlmostEqual(to: other.descend)
                && leading.isAlmostEqual(to: other.leading)
        }

        /// Calculates the spacing between two TextMetrics instances
        ///
        /// This method determines the appropriate spacing between text elements based on
        /// their metrics, taking into account the semantic rules for text spacing.
        ///
        /// - Parameters:
        ///   - top: The TextMetrics for the top text element
        ///   - bottom: The TextMetrics for the bottom text element
        /// - Returns: The calculated spacing value
        package static func spacing(top: TextMetrics, bottom: TextMetrics) -> CGFloat {
            guard Semantics.TextSpacingUIKit0059v2.isEnabled else {
                return 0
            }

            var result = bottom.leading
            if !top.isAlmostEqual(to: bottom) {
                // NOTE: Actually this is still bottom.leading 🤔
                result = top.descend + bottom.lineSpacing - bottom.descend - top.descend - bottom.ascend
            }
            result.round(.up, toMultipleOf: top.pixelLength)
            return result
        }

        package static func == (a: TextMetrics, b: TextMetrics) -> Bool {
            a.ascend == b.ascend && a.descend == b.descend && a.leading == b.leading && a.pixelLength == b.pixelLength
        }
    }

    // MARK: - Spacing.Value

    /// A value that represents different types of spacing
    ///
    /// This enum can represent either a fixed distance or text-based metrics
    /// for more sophisticated spacing calculations.
    package enum Value: Comparable {
        /// A fixed distance value
        case distance(CGFloat)

        /// Metrics for the top of text
        case topTextMetrics(TextMetrics)

        /// Metrics for the bottom of text
        case bottomTextMetrics(TextMetrics)

        /// Creates a new Value instance with the given distance
        ///
        /// - Parameter value: The fixed distance value
        @inlinable
        package init(_ value: CGFloat) {
            self = .distance(value)
        }

        /// Returns the fixed distance value if available
        ///
        /// - Returns: The distance value if this is a distance type, nil otherwise
        package var value: CGFloat? {
            guard case let .distance(value) = self else {
                return nil
            }
            return value
        }

        /// Calculates the distance between this spacing value and another
        ///
        /// This method handles different combinations of spacing value types to determine
        /// the appropriate distance between them.
        ///
        /// - Parameter other: The other spacing value
        /// - Returns: The calculated distance, or nil if no distance can be determined
        package func distance(to other: Value) -> CGFloat? {
            switch (self, other) {
            case let (.distance(a), .distance(b)): a + b
            case let (.distance(a), _): a
            case let (_, .distance(b)): b
            case (.topTextMetrics, .topTextMetrics): nil
            case let (.topTextMetrics(top), .bottomTextMetrics(bottom)): TextMetrics.spacing(top: top, bottom: bottom)
            case let (.bottomTextMetrics(bottom), .topTextMetrics(top)): TextMetrics.spacing(top: top, bottom: bottom)
            case (.bottomTextMetrics, .bottomTextMetrics): nil
            }
        }

        package static func < (a: Value, b: Value) -> Bool {
            switch (a, b) {
            case let (.distance(a), .distance(b)): a < b
            case (.distance, .topTextMetrics): true
            case (.distance, .bottomTextMetrics): true
            case (.topTextMetrics, .distance): false
            case let (.topTextMetrics(a), .topTextMetrics(b)): a < b
            case (.topTextMetrics, .bottomTextMetrics): true
            case (.bottomTextMetrics, .distance): false
            case (.bottomTextMetrics, .topTextMetrics): false
            case let (.bottomTextMetrics(a), .bottomTextMetrics(b)): a < b
            }
        }

        package static func == (a: Value, b: Value) -> Bool {
            switch (a, b) {
            case let (.distance(a), .distance(b)): a == b
            case let (.topTextMetrics(a), .topTextMetrics(b)): a == b
            case let (.bottomTextMetrics(a), .bottomTextMetrics(b)): a == b
            default: false
            }
        }
    }

    /// Incorporates spacing values from another Spacing instance for specified edges
    ///
    /// This method merges values from another Spacing instance, taking the maximum value
    /// when both instances have values for the same key.
    ///
    /// - Parameters:
    ///   - edges: The set of edges to incorporate
    ///   - other: The other Spacing instance to incorporate values from
    package mutating func incorporate(_ edges: AbsoluteEdge.Set, of other: Spacing) {
        guard !edges.isEmpty else {
            return
        }
        minima.merge(
            other.minima
                .lazy
                .filter { key, _ in
                    edges.contains(key.edge)
                }
        ) { max($0, $1) }
    }

    /// Clears spacing values for the specified edges with the given layout direction
    ///
    /// - Parameters:
    ///   - edges: The set of edges to clear
    ///   - layoutDirection: The layout direction to use for resolving edges
    package mutating func clear(_ edges: Edge.Set, layoutDirection: LayoutDirection) {
        clear(AbsoluteEdge.Set(edges, layoutDirection: layoutDirection))
    }

    /// Clears spacing values for the specified absolute edges
    ///
    /// - Parameter edges: The set of absolute edges to clear
    package mutating func clear(_ edges: AbsoluteEdge.Set) {
        guard !edges.isEmpty else {
            return
        }
        minima = minima.filter { key, _ in
            !edges.contains(key.edge)
        }
    }

    /// Resets spacing values for the specified edges with the given layout direction
    ///
    /// This method clears the existing values and sets new default values for the specified edges.
    ///
    /// - Parameters:
    ///   - edges: The set of edges to reset
    ///   - layoutDirection: The layout direction to use for resolving edges
    package mutating func reset(_ edges: Edge.Set, layoutDirection: LayoutDirection) {
        reset(AbsoluteEdge.Set(edges, layoutDirection: layoutDirection))
    }

    /// Resets spacing values for the specified absolute edges
    ///
    /// This method clears the existing values and sets new default values for the specified edges.
    ///
    /// - Parameter edges: The set of absolute edges to reset
    package mutating func reset(_ edges: AbsoluteEdge.Set) {
        guard !edges.isEmpty else {
            return
        }
        minima = minima.filter { key, _ in
            !edges.contains(key.edge)
        }
        if edges.contains(.top) {
            minima[Key(category: .edgeBelowText, edge: .top)] = .distance(0)
        }
        if edges.contains(.left) {
            minima[Key(category: .edgeRightText, edge: .left)] = .distance(0)
        }
        if edges.contains(.bottom) {
            minima[Key(category: .edgeAboveText, edge: .bottom)] = .distance(0)
        }
        if edges.contains(.right) {
            minima[Key(category: .edgeLeftText, edge: .right)] = .distance(0)
        }
    }

    /// The dictionary of spacing values by key
    package var minima: [Spacing.Key: Spacing.Value]

    /// Creates a new Spacing instance with default values
    package init() {
        minima = [
            Key(category: .edgeBelowText, edge: .top): .distance(0),
            Key(category: .edgeAboveText, edge: .bottom): .distance(0),
            Key(category: .edgeRightText, edge: .left): .distance(0),
            Key(category: .edgeLeftText, edge: .right): .distance(0),
        ]
    }

    /// Creates a new Spacing instance with the given spacing values
    ///
    /// - Parameter minima: Dictionary of spacing values by key
    package init(minima: [Spacing.Key: Spacing.Value]) {
        self.minima = minima
    }

    /// Calculates the distance to a successor view along a specified axis
    ///
    /// This method determines the appropriate spacing between adjacent views
    /// based on their spacing preferences.
    ///
    /// - Parameters:
    ///   - axis: The axis along which to calculate the distance
    ///   - layoutDirection: The layout direction to use for resolving edges
    ///   - nextPreference: The spacing preferences of the successor view
    /// - Returns: The calculated distance, or nil if no distance can be determined
    package func distanceToSuccessorView(along axis: Axis, layoutDirection: LayoutDirection, preferring nextPreference: Spacing) -> CGFloat? {
        let trailingEdge: AbsoluteEdge = layoutDirection == .leftToRight ? .right : .left
        let leadingEdge: AbsoluteEdge = layoutDirection != .leftToRight ? .right : .left

        let bottomTrailingEdge = axis == .horizontal ? trailingEdge : .bottom
        let topLeadingEdge = axis == .horizontal ? leadingEdge : .top

        let source: Spacing
        let fromEdge: AbsoluteEdge
        let toEdge: AbsoluteEdge
        let target: Spacing

        if minima.count >= nextPreference.minima.count {
            source = nextPreference
            fromEdge = topLeadingEdge
            toEdge = bottomTrailingEdge
            target = self
        } else {
            source = self
            fromEdge = bottomTrailingEdge
            toEdge = topLeadingEdge
            target = nextPreference
        }
        return source._distance(from: fromEdge, to: toEdge, ofViewPreferring: target)
    }

    private func _distance(from fromEdge: AbsoluteEdge, to toEdge: AbsoluteEdge, ofViewPreferring nextPreference: Spacing) -> CGFloat? {
        let (hasValue, distance) = minima.reduce((false, -Double.infinity)) { partialResult, pair in
            let (_, distance) = partialResult
            let (key, value) = pair
            guard let category = key.category, key.edge == fromEdge else {
                return partialResult
            }
            let toEdgeKey = Key(category: category, edge: toEdge)
            guard let nextValue = nextPreference.minima[toEdgeKey] else {
                return partialResult
            }
            guard let newDistance = value.distance(to: nextValue) else {
                return partialResult
            }
            return (true, max(distance, newDistance))
        }
        guard !hasValue else {
            return distance
        }
        let fromValue = minima[Key(category: nil, edge: fromEdge)]?.value
        let toValue = nextPreference.minima[Key(category: nil, edge: toEdge)]?.value
        guard fromValue != nil || toValue != nil else {
            return nil
        }
        return max(fromValue ?? -.infinity, toValue ?? -.infinity)
    }
}

@_spi(ForOpenSwiftUIOnly)
extension Spacing: CustomStringConvertible {
    public var description: String {
        guard !minima.isEmpty else {
            return "Spacing (empty)"
        }
        var result = "Spacing [\n"
        var sortedKeys = Array(minima.keys)
        sortedKeys.sort { a, b in
            // Sort by edge first
            if a.edge.rawValue != b.edge.rawValue {
                return a.edge.rawValue < b.edge.rawValue
            }
            // NOTE: SwiftUICore.Spacing only sort edge currently, we sort the category so that the unit test result is stable.
            // Then sort by category name (nil categories come first)
            guard let aType = a.category?.type, let bType = b.category?.type else {
                return a.category == nil && b.category != nil
            }
            return String(describing: aType) < String(describing: bType)
        }
        for key in sortedKeys {
            let value = minima[key]!
            let categoryName: String
            if let category = key.category {
                categoryName = String(describing: category.type)
            } else {
                categoryName = "default"
            }
            let valueDescription: String
            switch value {
            case let .distance(distance):
                valueDescription = "\(distance)"
            case let .topTextMetrics(metrics), let .bottomTextMetrics(metrics):
                valueDescription = "\(metrics)"
            }
            result += "  (\(categoryName), \(key.edge)) : \(valueDescription)\n"
        }
        result += "]"
        return result
    }
}

@_spi(ForOpenSwiftUIOnly)
extension Spacing {
    /// Determines whether the spacing values are symmetric with respect to layout direction
    ///
    /// This property checks if horizontal spacing values (left and right) would produce
    /// the same visual results regardless of whether the layout direction is left-to-right
    /// or right-to-left.
    ///
    /// A spacing is considered layout direction symmetric when:
    /// - It has no horizontal spacing values at all (only top/bottom)
    /// - It has equal values for both left and right edges with the same category
    /// - It has matching pairs of edge-category combinations
    package var isLayoutDirectionSymmetric: Bool {
        var horizontalEdgesByCategory: [Category?: (left: Value?, right: Value?)] = [:]
        for (key, value) in minima where key.edge == .left || key.edge == .right {
            let category = key.category
            var pair = horizontalEdgesByCategory[category] ?? (left: nil, right: nil)
            if key.edge == .left {
                pair.left = value
            } else {
                pair.right = value
            }
            horizontalEdgesByCategory[category] = pair
        }
        let values = horizontalEdgesByCategory.values
        guard !values.isEmpty else {
            return true
        }
        return values.allSatisfy { $0.left == $0.right }
    }
}

// MARK: - Spacing + Extension

@_spi(ForOpenSwiftUIOnly)
extension Spacing {
    /// A spacing instance with zero values for all edges
    package static let zero: Spacing = .init(minima: [
        Key(category: nil, edge: .left): .distance(0),
        Key(category: nil, edge: .right): .distance(0),
        Key(category: nil, edge: .top): .distance(0),
        Key(category: nil, edge: .bottom): .distance(0),
    ])

    /// Creates a spacing instance with the same value for all edges
    ///
    /// - Parameter value: The spacing value to apply to all edges
    /// - Returns: A new Spacing instance with the specified value
    package static func all(_ value: CGFloat) -> Spacing {
        Spacing(minima: [
            Key(category: nil, edge: .left): .distance(value),
            Key(category: nil, edge: .right): .distance(value),
            Key(category: nil, edge: .top): .distance(value),
            Key(category: nil, edge: .bottom): .distance(value),
        ])
    }

    /// Creates a spacing instance with the specified value for horizontal edges only
    ///
    /// - Parameter value: The spacing value to apply to horizontal edges
    /// - Returns: A new Spacing instance with the specified horizontal spacing
    package static func horizontal(_ value: CGFloat) -> Spacing {
        Spacing(minima: [
            Key(category: nil, edge: .left): .distance(value),
            Key(category: nil, edge: .right): .distance(value),
        ])
    }

    /// Creates a spacing instance with the specified value for vertical edges only
    ///
    /// - Parameter value: The spacing value to apply to vertical edges
    /// - Returns: A new Spacing instance with the specified vertical spacing
    package static func vertical(_ value: CGFloat) -> Spacing {
        Spacing(minima: [
            Key(category: nil, edge: .top): .distance(value),
            Key(category: nil, edge: .bottom): .distance(value),
        ])
    }
}

// MARK: - Spacing.Category + Extension

@_spi(ForOpenSwiftUIOnly)
extension Spacing.Category {
    private enum TextToText {}
    private enum EdgeAboveText {}
    private enum EdgeBelowText {}
    private enum TextBaseline {}
    private enum EdgeLeftText {}
    private enum EdgeRightText {}
    private enum LeftTextBaseline {}
    private enum RightTextBaseline {}

    /// A category for spacing between text elements
    package static var textToText = Spacing.Category(TextToText.self)

    /// A category for spacing above text elements
    package static var edgeAboveText = Spacing.Category(EdgeAboveText.self)

    /// A category for spacing below text elements
    package static var edgeBelowText = Spacing.Category(EdgeBelowText.self)

    /// A category for text baseline spacing
    package static var textBaseline = Spacing.Category(TextBaseline.self)

    /// A category for spacing to the left of text
    package static var edgeLeftText = Spacing.Category(EdgeLeftText.self)

    /// A category for spacing to the right of text
    package static var edgeRightText = Spacing.Category(EdgeRightText.self)

    /// A category for left text baseline spacing
    package static var leftTextBaseline = Spacing.Category(LeftTextBaseline.self)

    /// A category for right text baseline spacing
    package static var rightTextBaseline = Spacing.Category(RightTextBaseline.self)
}
