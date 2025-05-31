//
//  AlignmentGuide.swift
//  OpenSwiftUICore
//
//  Status: Complete
//  ID: E20796D15DD3D417699102559E024115 (SwiftUI)
//  ID: 1135C055CD2C2B1265C25B13E3E74C01 (SwiftUICore)

public import Foundation

// MARK: - AlignmentID [6.4.41]

/// A type that you use to create custom alignment guides.
///
/// Every built-in alignment guide that ``VerticalAlignment`` or
/// ``HorizontalAlignment`` defines as a static property, like
/// ``VerticalAlignment/top`` or ``HorizontalAlignment/leading``, has a
/// unique alignment identifier type that produces the default offset for
/// that guide. To create a custom alignment guide, define your own alignment
/// identifier as a type that conforms to the `AlignmentID` protocol, and
/// implement the required ``AlignmentID/defaultValue(in:)`` method:
///
///     private struct FirstThirdAlignment: AlignmentID {
///         static func defaultValue(in context: ViewDimensions) -> CGFloat {
///             context.height / 3
///         }
///     }
///
/// When implementing the method, calculate the guide's default offset
/// from the view's origin. If it's helpful, you can use information from the
/// ``ViewDimensions`` input in the calculation. This parameter provides context
/// about the specific view that's using the guide. The above example creates an
/// identifier called `FirstThirdAlignment` and calculates a default value
/// that's one-third of the height of the aligned view.
///
/// Use the identifier's type to create a static property in an extension of
/// one of the alignment guide types, like ``VerticalAlignment``:
///
///     extension VerticalAlignment {
///         static let firstThird = VerticalAlignment(FirstThirdAlignment.self)
///     }
///
/// You can apply your custom guide like any of the built-in guides. For
/// example, you can use an ``HStack`` to align its views at one-third
/// of their height using the guide defined above:
///
///     struct StripesGroup: View {
///         var body: some View {
///             HStack(alignment: .firstThird, spacing: 1) {
///                 HorizontalStripes().frame(height: 60)
///                 HorizontalStripes().frame(height: 120)
///                 HorizontalStripes().frame(height: 90)
///             }
///         }
///     }
///
///     struct HorizontalStripes: View {
///         var body: some View {
///             VStack(spacing: 1) {
///                 ForEach(0..<3) { _ in Color.blue }
///             }
///         }
///     }
///
/// Because each set of stripes has three equal, vertically stacked
/// rectangles, they align at the bottom edge of the top rectangle. This
/// corresponds in each case to a third of the overall height, as
/// measured from the origin at the top of each set of stripes:
///
/// ![Three vertical stacks of rectangles, arranged in a row.
/// The rectangles in each stack have the same height as each other, but
/// different heights than the rectangles in the other stacks. The bottom edges
/// of the top-most rectangle in each stack are aligned with each
/// other.](AlignmentId-1-iOS)
///
/// You can also use the ``View/alignmentGuide(_:computeValue:)`` view
/// modifier to alter the behavior of your custom guide for a view, as you
/// might alter a built-in guide. For example, you can change
/// one of the stacks of stripes from the previous example to align its
/// `firstThird` guide at two thirds of the height instead:
///
///     struct StripesGroupModified: View {
///         var body: some View {
///             HStack(alignment: .firstThird, spacing: 1) {
///                 HorizontalStripes().frame(height: 60)
///                 HorizontalStripes().frame(height: 120)
///                 HorizontalStripes().frame(height: 90)
///                     .alignmentGuide(.firstThird) { context in
///                         2 * context.height / 3
///                     }
///             }
///         }
///     }
///
/// The modified guide calculation causes the affected view to place the
/// bottom edge of its middle rectangle on the `firstThird` guide, which aligns
/// with the bottom edge of the top rectangle in the other two groups:
///
/// ![Three vertical stacks of rectangles, arranged in a row.
/// The rectangles in each stack have the same height as each other, but
/// different heights than the rectangles in the other stacks. The bottom edges
/// of the top-most rectangle in the first two stacks are aligned with each
/// other, and with the bottom edge of the middle rectangle in the third
/// stack.](AlignmentId-2-iOS)
///
public protocol AlignmentID {
    /// Calculates a default value for the corresponding guide in the specified
    /// context.
    ///
    /// Implement this method when you create a type that conforms to the
    /// ``AlignmentID`` protocol. Use the method to calculate the default
    /// offset of the corresponding alignment guide. SwiftUI interprets the
    /// value that you return as an offset in the coordinate space of the
    /// view that's being laid out. For example, you can use the context to
    /// return a value that's one-third of the height of the view:
    ///
    ///     private struct FirstThirdAlignment: AlignmentID {
    ///         static func defaultValue(in context: ViewDimensions) -> CGFloat {
    ///             context.height / 3
    ///         }
    ///     }
    ///
    /// You can override the default value that this method returns for a
    /// particular guide by adding the
    /// ``View/alignmentGuide(_:computeValue:)`` view modifier to a
    /// particular view.
    ///
    /// - Parameter context: The context of the view that you apply
    ///   the alignment guide to. The context gives you the view's dimensions,
    ///   as well as the values of other alignment guides that apply to the
    ///   view, including both built-in and custom guides. You can use any of
    ///   these values, if helpful, to calculate the value for your custom
    ///   guide.
    ///
    /// - Returns: The offset of the guide from the origin in the
    ///   view's coordinate space.
    static func defaultValue(in context: ViewDimensions) -> CGFloat

    /// Updates `parentValue` with the `n`th explicit child guide value, as
    /// projected into the parent's coordinate space.
    static func _combineExplicit(childValue: CGFloat, _ n: Int, into parentValue: inout CGFloat?)
}

extension AlignmentID {
    // n == 0:
    // value = childValue = c0
    // parentValue = childValue = c0
    // n == 1:
    // value = parentValue! = c0
    // parentValue = (c0 + c1) / 2
    // n == 2:
    // value = parentValue! = (c0 + c1) / 2
    // parentValue = (c0 + c1 + c2) / 3
    public static func _combineExplicit(childValue: CGFloat, _ n: Int, into parentValue: inout CGFloat?) {
        let value = (n == 0) ? childValue : parentValue!
        let n = CGFloat(n)
        parentValue = (value * n + childValue) / (n + 1.0)
    }

    package static func combineExplicit<S>(_ values: S) -> CGFloat? where S: Sequence, S.Element == CGFloat? {
        var result: CGFloat? = nil
        var n = 0
        for childValue in values {
            guard let childValue else {
                continue
            }
            _combineExplicit(childValue: childValue, n, into: &result)
            n += 1
        }
        return result
    }
}

// MARK: - HorizontalAlignment [6.4.41]

/// An alignment position along the horizontal axis.
///
/// Use horizontal alignment guides to tell OpenSwiftUI how to position views
/// relative to one another horizontally, like when you place views vertically
/// in an ``VStack``. The following example demonstrates common built-in
/// horizontal alignments:
///
/// ![Three columns of content. Each column contains a string
/// inside a box with a vertical line above and below the box. The
/// lines are aligned horizontally with the text in a different way for each
/// column. The lines for the left-most string, labeled Leading, align with
/// the left edge of the string. The lines for the middle string, labeled
/// Center, align with the center of the string. The lines for the right-most
/// string, labeled Trailing, align with the right edge of the
/// string.](HorizontalAlignment-1-iOS)
///
/// You can generate the example above by creating a series of columns
/// implemented as vertical stacks, where you configure each stack with a
/// different alignment guide:
///
///     private struct HorizontalAlignmentGallery: View {
///         var body: some View {
///             HStack(spacing: 30) {
///                 column(alignment: .leading, text: "Leading")
///                 column(alignment: .center, text: "Center")
///                 column(alignment: .trailing, text: "Trailing")
///             }
///             .frame(height: 150)
///         }
///
///         private func column(alignment: HorizontalAlignment, text: String) -> some View {
///             VStack(alignment: alignment, spacing: 0) {
///                 Color.red.frame(width: 1)
///                 Text(text).font(.title).border(.gray)
///                 Color.red.frame(width: 1)
///             }
///         }
///     }
///
/// During layout, OpenSwiftUI aligns the views inside each stack by bringing
/// together the specified guides of the affected views. OpenSwiftUI calculates
/// the position of a guide for a particular view based on the characteristics
/// of the view. For example, the ``HorizontalAlignment/center`` guide appears
/// at half the width of the view. You can override the guide calculation for a
/// particular view using the ``View/alignmentGuide(_:computeValue:)``
/// view modifier.
///
/// ### Layout direction
///
/// When a user configures their device to use a left-to-right language like
/// English, the system places the leading alignment on the left and the
/// trailing alignment on the right, as the example from the previous section
/// demonstrates. However, in a right-to-left language, the system reverses
/// these. You can see this by using the ``View/environment(_:_:)`` view
/// modifier to explicitly override the ``EnvironmentValues/layoutDirection``
/// environment value for the view defined above:
///
///     HorizontalAlignmentGallery()
///         .environment(\.layoutDirection, .rightToLeft)
///
/// ![Three columns of content. Each column contains a string
/// inside a box with a vertical line above and below the box. The
/// lines are aligned horizontally with the text in a different way for each
/// column. The lines for the left-most string, labeled Trailing, align with
/// the left edge of the string. The lines for the middle string, labeled
/// Center, align with the center of the string. The lines for the right-most
/// string, labeled Leading, align with the right edge of the
/// string.](HorizontalAlignment-2-iOS)
///
/// This automatic layout adjustment makes it easier to localize your app,
/// but it's still important to test your app for the different locales that
/// you ship into. For more information about the localization process, see
/// [Localization](https://developer.apple.com/documentation/xcode/localization).
///
/// ### Custom alignment guides
///
/// You can create a custom horizontal alignment by creating a type that
/// conforms to the ``AlignmentID`` protocol, and then using that type to
/// initalize a new static property on `HorizontalAlignment`:
///
///     private struct OneQuarterAlignment: AlignmentID {
///         static func defaultValue(in context: ViewDimensions) -> CGFloat {
///             context.width / 4
///         }
///     }
///
///     extension HorizontalAlignment {
///         static let oneQuarter = HorizontalAlignment(OneQuarterAlignment.self)
///     }
///
/// You implement the ``AlignmentID/defaultValue(in:)`` method to calculate
/// a default value for the custom alignment guide. The method receives a
/// ``ViewDimensions`` instance that you can use to calculate an appropriate
/// value based on characteristics of the view. The example above places
/// the guide at one quarter of the width of the view, as measured from the
/// view's origin.
///
/// You can then use the custom alignment guide like any built-in guide. For
/// example, you can use it as the `alignment` parameter to a ``VStack``,
/// or you can change it for a specific view using the
/// ``View/alignmentGuide(_:computeValue:)`` view modifier.
/// Custom alignment guides also automatically reverse in a right-to-left
/// environment, just like built-in guides.
///
/// ### Composite alignment
///
/// Combine a ``VerticalAlignment`` with a `HorizontalAlignment` to create a
/// composite ``Alignment`` that indicates both vertical and horizontal
/// positioning in one value. For example, you could combine your custom
/// `oneQuarter` horizontal alignment from the previous section with a built-in
/// ``VerticalAlignment/center`` vertical alignment to use in a ``ZStack``:
///
///     struct LayeredVerticalStripes: View {
///         var body: some View {
///             ZStack(alignment: Alignment(horizontal: .oneQuarter, vertical: .center)) {
///                 verticalStripes(color: .blue)
///                     .frame(width: 300, height: 150)
///                 verticalStripes(color: .green)
///                     .frame(width: 180, height: 80)
///             }
///         }
///
///         private func verticalStripes(color: Color) -> some View {
///             HStack(spacing: 1) {
///                 ForEach(0..<4) { _ in color }
///             }
///         }
///     }
///
/// The example above uses widths and heights that generate two mismatched sets
/// of four vertical stripes. The ``ZStack`` centers the two sets vertically and
/// aligns them horizontally one quarter of the way from the leading edge of
/// each set. In a left-to-right locale, this aligns the right edges of the
/// left-most stripes of each set:
///
/// ![Two sets of four rectangles. The first set is blue. The
/// second set is green, is smaller, and is layered on top of the first set.
/// The two sets are centered vertically, but align horizontally at the right
/// edge of each set's left-most rectangle.](HorizontalAlignment-3-iOS)
@frozen
public struct HorizontalAlignment: AlignmentGuide, Equatable {
    /// Creates a custom horizontal alignment of the specified type.
    ///
    /// Use this initializer to create a custom horizontal alignment. Define
    /// an ``AlignmentID`` type, and then use that type to create a new
    /// static property on ``HorizontalAlignment``:
    ///
    ///     private struct OneQuarterAlignment: AlignmentID {
    ///         static func defaultValue(in context: ViewDimensions) -> CGFloat {
    ///             context.width / 4
    ///         }
    ///     }
    ///
    ///     extension HorizontalAlignment {
    ///         static let oneQuarter = HorizontalAlignment(OneQuarterAlignment.self)
    ///     }
    ///
    /// Every horizontal alignment instance that you create needs a unique
    /// identifier. For more information, see ``AlignmentID``.
    ///
    /// - Parameter id: The type of an identifier that uniquely identifies a
    ///   horizontal alignment.
    public init(_ id: any AlignmentID.Type) {
        key = AlignmentKey(id: id, axis: .horizontal)
    }

    /// You don't use this property directly.
    @_documentation(visibility: private)
    public let key: AlignmentKey
}

extension HorizontalAlignment {
    /// Merges a sequence of explicit alignment values produced by
    /// this instance.
    ///
    /// For built-in horizontal alignment types, this method returns the mean
    /// of all non-`nil` values.
    public func combineExplicit<S>(_ values: S) -> CGFloat? where S: Sequence, S.Element == CGFloat? {
        key.id.combineExplicit(values)
    }
}

// MARK: - VerticalAlignment [6.4.41]

/// An alignment position along the vertical axis.
///
/// Use vertical alignment guides to position views
/// relative to one another vertically, like when you place views side-by-side
/// in an ``HStack`` or when you create a row of views in a ``Grid`` using
/// ``GridRow``. The following example demonstrates common built-in
/// vertical alignments:
///
/// ![Five rows of content. Each row contains text inside
/// a box with horizontal lines to the left and the right of the box. The
/// lines are aligned vertically with the text in a different way for each
/// row, corresponding to the content of the text in that row. The text strings
/// are, in order, top, center, bottom, first text baseline, and last text
/// baseline.](VerticalAlignment-1-iOS)
///
/// You can generate the example above by creating a series of rows
/// implemented as horizontal stacks, where you configure each stack with a
/// different alignment guide:
///
///     private struct VerticalAlignmentGallery: View {
///         var body: some View {
///             VStack(spacing: 30) {
///                 row(alignment: .top, text: "Top")
///                 row(alignment: .center, text: "Center")
///                 row(alignment: .bottom, text: "Bottom")
///                 row(alignment: .firstTextBaseline, text: "First Text Baseline")
///                 row(alignment: .lastTextBaseline, text: "Last Text Baseline")
///             }
///         }
///
///         private func row(alignment: VerticalAlignment, text: String) -> some View {
///             HStack(alignment: alignment, spacing: 0) {
///                 Color.red.frame(height: 1)
///                 Text(text).font(.title).border(.gray)
///                 Color.red.frame(height: 1)
///             }
///         }
///     }
///
/// During layout, OpenSwiftUI aligns the views inside each stack by bringing
/// together the specified guides of the affected views. OpenSwiftUI calculates
/// the position of a guide for a particular view based on the characteristics
/// of the view. For example, the ``VerticalAlignment/center`` guide appears
/// at half the height of the view. You can override the guide calculation for a
/// particular view using the ``View/alignmentGuide(_:computeValue:)``
/// view modifier.
///
/// ### Text baseline alignment
///
/// Use the ``VerticalAlignment/firstTextBaseline`` or
/// ``VerticalAlignment/lastTextBaseline`` guide to match the bottom of either
/// the top- or bottom-most line of text that a view contains, respectively.
/// Text baseline alignment excludes the parts of characters that descend
/// below the baseline, like the tail on lower case g and j:
///
///     row(alignment: .firstTextBaseline, text: "fghijkl")
///
/// If you use a text baseline alignment on a view that contains no text,
/// OpenSwiftUI applies the equivalent of ``VerticalAlignment/bottom`` alignment
/// instead. For the row in the example above, OpenSwiftUI matches the bottom of
/// the horizontal lines with the baseline of the text:
///
/// ![A string containing the lowercase letters f, g, h, i, j, and
/// k. The string is inside a box, and horizontal lines appear to the left and
/// to the right of the box. The lines align with the bottom of the text,
/// excluding the descenders of letters g and j, which extend below the
/// baseline.](VerticalAlignment-2-iOS)
///
/// Aligning a text view to its baseline rather than to the bottom of its frame
/// produces the best layout effect in many cases, like when creating forms.
/// For example, you can align the baseline of descriptive text in
/// one ``GridRow`` cell with the baseline of a text field, or the label
/// of a checkbox, in another cell in the same row.
///
/// ### Custom alignment guides
///
/// You can create a custom vertical alignment guide by first creating a type
/// that conforms to the ``AlignmentID`` protocol, and then using that type to
/// initalize a new static property on `VerticalAlignment`:
///
///     private struct FirstThirdAlignment: AlignmentID {
///         static func defaultValue(in context: ViewDimensions) -> CGFloat {
///             context.height / 3
///         }
///     }
///
///     extension VerticalAlignment {
///         static let firstThird = VerticalAlignment(FirstThirdAlignment.self)
///     }
///
/// You implement the ``AlignmentID/defaultValue(in:)`` method to calculate
/// a default value for the custom alignment guide. The method receives a
/// ``ViewDimensions`` instance that you can use to calculate a
/// value based on characteristics of the view. The example above places
/// the guide at one-third of the height of the view as measured from the
/// view's origin.
///
/// You can then use the custom alignment guide like any built-in guide. For
/// example, you can use it as the `alignment` parameter to an ``HStack``,
/// or to alter the guide calculation for a specific view using the
/// ``View/alignmentGuide(_:computeValue:)`` view modifier.
///
/// ### Composite alignment
///
/// Combine a `VerticalAlignment` with a ``HorizontalAlignment`` to create a
/// composite ``Alignment`` that indicates both vertical and horizontal
/// positioning in one value. For example, you could combine your custom
/// `firstThird` vertical alignment from the previous section with a built-in
/// ``HorizontalAlignment/center`` horizontal alignment to use in a ``ZStack``:
///
///     struct LayeredHorizontalStripes: View {
///         var body: some View {
///             ZStack(alignment: Alignment(horizontal: .center, vertical: .firstThird)) {
///                 horizontalStripes(color: .blue)
///                     .frame(width: 180, height: 90)
///                 horizontalStripes(color: .green)
///                     .frame(width: 70, height: 60)
///             }
///         }
///
///         private func horizontalStripes(color: Color) -> some View {
///             VStack(spacing: 1) {
///                 ForEach(0..<3) { _ in color }
///             }
///         }
///     }
///
/// The example above uses widths and heights that generate two mismatched
/// sets of three vertical stripes. The ``ZStack`` centers the two sets
/// horizontally and aligns them vertically one-third from the top
/// of each set. This aligns the bottom edges of the top stripe from each set:
///
/// ![Two sets of three vertically stacked rectangles. The first
/// set is blue. The second set of rectangles are green, smaller, and layered
/// on top of the first set. The two sets are centered horizontally, but align
/// vertically at the bottom edge of each set's top-most
/// rectangle.](VerticalAlignment-3-iOS)
@frozen
public struct VerticalAlignment: AlignmentGuide, Equatable {
    /// Creates a custom vertical alignment of the specified type.
    ///
    /// Use this initializer to create a custom vertical alignment. Define
    /// an ``AlignmentID`` type, and then use that type to create a new
    /// static property on ``VerticalAlignment``:
    ///
    ///     private struct FirstThirdAlignment: AlignmentID {
    ///         static func defaultValue(in context: ViewDimensions) -> CGFloat {
    ///             context.height / 3
    ///         }
    ///     }
    ///
    ///     extension VerticalAlignment {
    ///         static let firstThird = VerticalAlignment(FirstThirdAlignment.self)
    ///     }
    ///
    /// Every vertical alignment instance that you create needs a unique
    /// identifier. For more information, see ``AlignmentID``.
    ///
    /// - Parameter id: The type of an identifier that uniquely identifies a
    ///   vertical alignment.
    public init(_ id: AlignmentID.Type) {
        key = AlignmentKey(id: id, axis: .vertical)
    }

    /// You don't use this property directly.
    @_documentation(visibility: private)
    public let key: AlignmentKey
}

extension VerticalAlignment {
    /// Merges a sequence of explicit alignment values produced by
    /// this instance.
    ///
    /// For most alignment types, this method returns the mean of all non-`nil`
    /// values. However, some types use other rules. For example,
    /// ``VerticalAlignment/firstTextBaseline`` returns the minimum value,
    /// while ``VerticalAlignment/lastTextBaseline`` returns the maximum value.
    public func combineExplicit<S>(_ values: S) -> CGFloat? where S: Sequence, S.Element == CGFloat? {
        key.id.combineExplicit(values)
    }
}

// MARK: - Alignment [6.4.41]

/// An alignment in both axes.
///
/// An `Alignment` contains a ``HorizontalAlignment`` guide and a
/// ``VerticalAlignment`` guide. Specify an alignment to direct the behavior of
/// certain layout containers and modifiers, like when you place views in a
/// ``ZStack``, or layer a view in front of or behind another view using
/// ``View/overlay(alignment:content:)`` or
/// ``View/background(alignment:content:)``, respectively. During layout,
/// OpenSwiftUI brings the specified guides of the affected views together,
/// aligning the views.
///
/// OpenSwiftUI provides a set of built-in alignments that represent common
/// combinations of the built-in horizontal and vertical alignment guides.
/// The blue boxes in the following diagram demonstrate the alignment named
/// by each box's label, relative to the background view:
///
/// ![A square that's divided into four equal quadrants. The upper-
/// left quadrant contains the text, Some text in an upper quadrant. The
/// lower-right quadrant contains the text, More text in a lower quadrant.
/// In both cases, the text is split over two lines. A variety of blue
/// boxes are overlaid atop the square. Each contains the name of a built-in
/// alignment, and is aligned with the square in a way that matches the
/// alignment name. For example, the box lableled center appears at the
/// center of the square.](Alignment-1-iOS)
///
/// The following code generates the diagram above, where each blue box appears
/// in an overlay that's configured with a different alignment:
///
///     struct AlignmentGallery: View {
///         var body: some View {
///             BackgroundView()
///                 .overlay(alignment: .topLeading) { box(".topLeading") }
///                 .overlay(alignment: .top) { box(".top") }
///                 .overlay(alignment: .topTrailing) { box(".topTrailing") }
///                 .overlay(alignment: .leading) { box(".leading") }
///                 .overlay(alignment: .center) { box(".center") }
///                 .overlay(alignment: .trailing) { box(".trailing") }
///                 .overlay(alignment: .bottomLeading) { box(".bottomLeading") }
///                 .overlay(alignment: .bottom) { box(".bottom") }
///                 .overlay(alignment: .bottomTrailing) { box(".bottomTrailing") }
///                 .overlay(alignment: .leadingLastTextBaseline) { box(".leadingLastTextBaseline") }
///                 .overlay(alignment: .trailingFirstTextBaseline) { box(".trailingFirstTextBaseline") }
///         }
///
///         private func box(_ name: String) -> some View {
///             Text(name)
///                 .font(.system(.caption, design: .monospaced))
///                 .padding(2)
///                 .foregroundColor(.white)
///                 .background(.blue.opacity(0.8), in: Rectangle())
///         }
///     }
///
///     private struct BackgroundView: View {
///         var body: some View {
///             Grid(horizontalSpacing: 0, verticalSpacing: 0) {
///                 GridRow {
///                     Text("Some text in an upper quadrant")
///                     Color.gray.opacity(0.3)
///                 }
///                 GridRow {
///                     Color.gray.opacity(0.3)
///                     Text("More text in a lower quadrant")
///                 }
///             }
///             .aspectRatio(1, contentMode: .fit)
///             .foregroundColor(.secondary)
///             .border(.gray)
///         }
///     }
///
/// To avoid crowding, the alignment diagram shows only two of the available
/// text baseline alignments. The others align as their names imply. Notice that
/// the first text baseline alignment aligns with the top-most line of text in
/// the background view, while the last text baseline aligns with the
/// bottom-most line. For more information about text baseline alignment, see
/// ``VerticalAlignment``.
///
/// In a left-to-right language like English, the leading and trailing
/// alignments appear on the left and right edges, respectively. OpenSwiftUI
/// reverses these in right-to-left language environments. For more
/// information, see ``HorizontalAlignment``.
///
/// ### Custom alignment
///
/// You can create custom alignments --- which you typically do to make use
/// of custom horizontal or vertical guides --- by using the
/// ``init(horizontal:vertical:)`` initializer. For example, you can combine
/// a custom vertical guide called `firstThird` with the built-in horizontal
/// ``HorizontalAlignment/center`` guide, and use it to configure a ``ZStack``:
///
///     ZStack(alignment: Alignment(horizontal: .center, vertical: .firstThird)) {
///         // ...
///     }
///
/// For more information about creating custom guides, including the code
/// that creates the custom `firstThird` alignment in the example above,
/// see ``AlignmentID``.
@frozen
public struct Alignment: Equatable {
    /// The alignment on the horizontal axis.
    ///
    /// Set this value when you initialize an alignment using the
    /// ``init(horizontal:vertical:)`` method. Use one of the built-in
    /// ``HorizontalAlignment`` guides, like ``HorizontalAlignment/center``,
    /// or a custom guide that you create.
    ///
    /// For information about creating custom guides, see ``AlignmentID``.
    public var horizontal: HorizontalAlignment

    /// The alignment on the vertical axis.
    ///
    /// Set this value when you initialize an alignment using the
    /// ``init(horizontal:vertical:)`` method. Use one of the built-in
    /// ``VerticalAlignment`` guides, like ``VerticalAlignment/center``,
    /// or a custom guide that you create.
    ///
    /// For information about creating custom guides, see ``AlignmentID``.
    public var vertical: VerticalAlignment

    /// Creates a custom alignment value with the specified horizontal
    /// and vertical alignment guides.
    ///
    /// OpenSwiftUI provides a variety of built-in alignments that combine built-in
    /// ``HorizontalAlignment`` and ``VerticalAlignment`` guides. Use this
    /// initializer to create a custom alignment that makes use
    /// of a custom horizontal or vertical guide, or both.
    ///
    /// For example, you can combine a custom vertical guide called
    /// `firstThird` with the built-in ``HorizontalAlignment/center``
    /// guide, and use it to configure a ``ZStack``:
    ///
    ///     ZStack(alignment: Alignment(horizontal: .center, vertical: .firstThird)) {
    ///         // ...
    ///     }
    ///
    /// For more information about creating custom guides, including the code
    /// that creates the custom `firstThird` alignment in the example above,
    /// see ``AlignmentID``.
    ///
    /// - Parameters:
    ///   - horizontal: The alignment on the horizontal axis.
    ///   - vertical: The alignment on the vertical axis.
    @inlinable
    public init(horizontal: HorizontalAlignment, vertical: VerticalAlignment) {
        self.horizontal = horizontal
        self.vertical = vertical
    }
}

// MARK: - HorizontalAlignment Const [6.4.41]

extension HorizontalAlignment {
    /// A guide that marks the leading edge of the view.
    ///
    /// Use this guide to align the leading edges of views.
    /// For a device that uses a left-to-right language, the leading edge
    /// is on the left:
    ///
    /// ![A box that contains the word, Leading. Vertical
    /// lines appear above and below the box. The lines align horizontally
    /// with the left edge of the box.](HorizontalAlignment-leading-1-iOS)
    ///
    /// The following code generates the image above using a ``VStack``:
    ///
    ///     struct HorizontalAlignmentLeading: View {
    ///         var body: some View {
    ///             VStack(alignment: .leading, spacing: 0) {
    ///                 Color.red.frame(width: 1)
    ///                 Text("Leading").font(.title).border(.gray)
    ///                 Color.red.frame(width: 1)
    ///             }
    ///         }
    ///     }
    ///
    public static let leading = HorizontalAlignment(Leading.self)

    private enum Leading: FrameAlignment {
        static func defaultValue(in _: ViewDimensions) -> CGFloat {
            .zero
        }
    }

    /// A guide that marks the horizontal center of the view.
    ///
    /// Use this guide to align the centers of views:
    ///
    /// ![A box that contains the word, Center. Vertical
    /// lines appear above and below the box. The lines align horizontally
    /// with the center of the box.](HorizontalAlignment-center-1-iOS)
    ///
    /// The following code generates the image above using a ``VStack``:
    ///
    ///     struct HorizontalAlignmentCenter: View {
    ///         var body: some View {
    ///             VStack(alignment: .center, spacing: 0) {
    ///                 Color.red.frame(width: 1)
    ///                 Text("Center").font(.title).border(.gray)
    ///                 Color.red.frame(width: 1)
    ///             }
    ///         }
    ///     }
    ///
    public static let center = HorizontalAlignment(Center.self)

    private enum Center: FrameAlignment {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context.width * 0.5
        }
    }

    /// A guide that marks the trailing edge of the view.
    ///
    /// Use this guide to align the trailing edges of views.
    /// For a device that uses a left-to-right language, the trailing edge
    /// is on the right:
    ///
    /// ![A box that contains the word, Trailing. Vertical
    /// lines appear above and below the box. The lines align horizontally
    /// with the right edge of the box.](HorizontalAlignment-trailing-1-iOS)
    ///
    /// The following code generates the image above using a ``VStack``:
    ///
    ///     struct HorizontalAlignmentTrailing: View {
    ///         var body: some View {
    ///             VStack(alignment: .trailing, spacing: 0) {
    ///                 Color.red.frame(width: 1)
    ///                 Text("Trailing").font(.title).border(.gray)
    ///                 Color.red.frame(width: 1)
    ///             }
    ///         }
    ///     }
    ///
    public static let trailing = HorizontalAlignment(Trailing.self)

    private enum Trailing: FrameAlignment {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context.width
        }
    }

    package static let leadingText = HorizontalAlignment(LeadingText.self)

    private enum LeadingText: FrameAlignment {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[.leading]
        }

        static func _combineExplicit(childValue: CGFloat, _: Int, into parentValue: inout CGFloat?) {
            parentValue = min(childValue, parentValue ?? .infinity)
        }
    }
}

// MARK: - VerticalAlignment Const [6.4.41]

extension VerticalAlignment {

    /// A guide that marks the top edge of the view.
    ///
    /// Use this guide to align the top edges of views:
    ///
    /// ![A box that contains the word, Top. A horizontal
    /// line appears on either side of the box. The lines align vertically
    /// with the top edge of the box.](VerticalAlignment-top-1-iOS)
    ///
    /// The following code generates the image above using an ``HStack``:
    ///
    ///     struct VerticalAlignmentTop: View {
    ///         var body: some View {
    ///             HStack(alignment: .top, spacing: 0) {
    ///                 Color.red.frame(height: 1)
    ///                 Text("Top").font(.title).border(.gray)
    ///                 Color.red.frame(height: 1)
    ///             }
    ///         }
    ///     }
    ///
    public static let top = VerticalAlignment(Top.self)

    private enum Top: FrameAlignment {
        static func defaultValue(in _: ViewDimensions) -> CGFloat {
            .zero
        }
    }

    /// A guide that marks the vertical center of the view.
    ///
    /// Use this guide to align the centers of views:
    ///
    /// ![A box that contains the word, Center. A horizontal
    /// line appears on either side of the box. The lines align vertically
    /// with the center of the box.](VerticalAlignment-center-1-iOS)
    ///
    /// The following code generates the image above using an ``HStack``:
    ///
    ///     struct VerticalAlignmentCenter: View {
    ///         var body: some View {
    ///             HStack(alignment: .center, spacing: 0) {
    ///                 Color.red.frame(height: 1)
    ///                 Text("Center").font(.title).border(.gray)
    ///                 Color.red.frame(height: 1)
    ///             }
    ///         }
    ///     }
    ///
    public static let center = VerticalAlignment(Center.self)

    private enum Center: FrameAlignment {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context.height * 0.5
        }
    }

    /// A guide that marks the bottom edge of the view.
    ///
    /// Use this guide to align the bottom edges of views:
    ///
    /// ![A box that contains the word, Bottom. A horizontal
    /// line appears on either side of the box. The lines align vertically
    /// with the bottom edge of the box.](VerticalAlignment-bottom-1-iOS)
    ///
    /// The following code generates the image above using an ``HStack``:
    ///
    ///     struct VerticalAlignmentBottom: View {
    ///         var body: some View {
    ///             HStack(alignment: .bottom, spacing: 0) {
    ///                 Color.red.frame(height: 1)
    ///                 Text("Bottom").font(.title).border(.gray)
    ///                 Color.red.frame(height: 1)
    ///             }
    ///         }
    ///     }
    ///
    public static let bottom = VerticalAlignment(Bottom.self)

    private enum Bottom: FrameAlignment {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context.height
        }
    }

    /// A guide that marks the top-most text baseline in a view.
    ///
    /// Use this guide to align with the baseline of the top-most text in a
    /// view. The guide aligns with the bottom of a view that contains no text:
    ///
    /// ![A box that contains the text, First Text Baseline.
    /// A horizontal line appears on either side of the box. The lines align
    /// vertically with the baseline of the first line of
    /// text.](VerticalAlignment-firstTextBaseline-1-iOS)
    ///
    /// The following code generates the image above using an ``HStack``:
    ///
    ///     struct VerticalAlignmentFirstTextBaseline: View {
    ///         var body: some View {
    ///             HStack(alignment: .firstTextBaseline, spacing: 0) {
    ///                 Color.red.frame(height: 1)
    ///                 Text("First Text Baseline").font(.title).border(.gray)
    ///                 Color.red.frame(height: 1)
    ///             }
    ///         }
    ///     }
    public static let firstTextBaseline = VerticalAlignment(FirstTextBaseline.self)

    private enum FirstTextBaseline: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context.height
        }

        static func _combineExplicit(childValue: CGFloat, _: Int, into parentValue: inout CGFloat?) {
            parentValue = min(childValue, parentValue ?? .infinity)
        }
    }

    /// A guide that marks the bottom-most text baseline in a view.
    ///
    /// Use this guide to align with the baseline of the bottom-most text in a
    /// view. The guide aligns with the bottom of a view that contains no text.
    ///
    /// ![A box that contains the text, Last Text Baseline.
    /// A horizontal line appears on either side of the box. The lines align
    /// vertically with the baseline of the last line of
    /// text.](VerticalAlignment-lastTextBaseline-1-iOS)
    ///
    /// The following code generates the image above using an ``HStack``:
    ///
    ///     struct VerticalAlignmentLastTextBaseline: View {
    ///         var body: some View {
    ///             HStack(alignment: .lastTextBaseline, spacing: 0) {
    ///                 Color.red.frame(height: 1)
    ///                 Text("Last Text Baseline").font(.title).border(.gray)
    ///                 Color.red.frame(height: 1)
    ///             }
    ///         }
    ///     }
    ///
    public static let lastTextBaseline = VerticalAlignment(LastTextBaseline.self)

    private enum LastTextBaseline: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context.height
        }

        static func _combineExplicit(childValue: CGFloat, _: Int, into parentValue: inout CGFloat?) {
            parentValue = min(childValue, parentValue ?? .infinity)
        }
    }

    package static let _firstTextLineCenter = VerticalAlignment(FirstTextLineCenter.self)

    private enum FirstTextLineCenter: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[VerticalAlignment.center]
        }

        static func _combineExplicit(childValue: CGFloat, _: Int, into parentValue: inout CGFloat?) {
            parentValue = max(childValue, parentValue ?? -.infinity)
        }
    }
}

// MARK: - Alignment Const [6.4.41]

extension Alignment {
    /// A guide that marks the center of the view.
    ///
    /// This alignment combines the ``HorizontalAlignment/center``
    /// horizontal guide and the ``VerticalAlignment/center``
    /// vertical guide:
    ///
    /// ![A square that's divided into four equal quadrants. The upper-
    /// left quadrant contains the text, Some text in an upper quadrant. The
    /// lower-right quadrant contains the text, More text in a lower quadrant.
    /// In both cases, the text is split over two lines. A blue box that
    /// contains the text, Center, appears at the center of the
    /// square.](Alignment-center-1-iOS)
    public static let center = Alignment(horizontal: .center, vertical: .center)

    /// A guide that marks the leading edge of the view.
    ///
    /// This alignment combines the ``HorizontalAlignment/leading``
    /// horizontal guide and the ``VerticalAlignment/center``
    /// vertical guide:
    ///
    /// ![A square that's divided into four equal quadrants. The upper-
    /// left quadrant contains the text, Some text in an upper quadrant. The
    /// lower-right quadrant contains the text, More text in a lower quadrant.
    /// In both cases, the text is split over two lines. A blue box that
    /// contains the text, Leading, appears on the left edge of the
    /// square, centered vertically.](Alignment-leading-1-iOS)
    public static let leading = Alignment(horizontal: .leading, vertical: .center)

    /// A guide that marks the trailing edge of the view.
    ///
    /// This alignment combines the ``HorizontalAlignment/trailing``
    /// horizontal guide and the ``VerticalAlignment/center``
    /// vertical guide:
    ///
    /// ![A square that's divided into four equal quadrants. The upper-
    /// left quadrant contains the text, Some text in an upper quadrant. The
    /// lower-right quadrant contains the text, More text in a lower quadrant.
    /// In both cases, the text is split over two lines. A blue box that
    /// contains the text, Trailing, appears on the right edge of the
    /// square, centered vertically.](Alignment-trailing-1-iOS)
    public static let trailing = Alignment(horizontal: .trailing, vertical: .center)

    /// A guide that marks the top edge of the view.
    ///
    /// This alignment combines the ``HorizontalAlignment/center``
    /// horizontal guide and the ``VerticalAlignment/top``
    /// vertical guide:
    ///
    /// ![A square that's divided into four equal quadrants. The upper-
    /// left quadrant contains the text, Some text in an upper quadrant. The
    /// lower-right quadrant contains the text, More text in a lower quadrant.
    /// In both cases, the text is split over two lines. A blue box that
    /// contains the text, Top, appears on the top edge of the
    /// square, centered horizontally.](Alignment-top-1-iOS)
    public static let top = Alignment(horizontal: .center, vertical: .top)

    /// A guide that marks the bottom edge of the view.
    ///
    /// This alignment combines the ``HorizontalAlignment/center``
    /// horizontal guide and the ``VerticalAlignment/bottom``
    /// vertical guide:
    ///
    /// ![A square that's divided into four equal quadrants. The upper-
    /// left quadrant contains the text, Some text in an upper quadrant. The
    /// lower-right quadrant contains the text, More text in a lower quadrant.
    /// In both cases, the text is split over two lines. A blue box that
    /// contains the text, Bottom, appears on the bottom edge of the
    /// square, centered horizontally.](Alignment-bottom-1-iOS)
    public static let bottom = Alignment(horizontal: .center, vertical: .bottom)

    /// A guide that marks the top and leading edges of the view.
    ///
    /// This alignment combines the ``HorizontalAlignment/leading``
    /// horizontal guide and the ``VerticalAlignment/top``
    /// vertical guide:
    ///
    /// ![A square that's divided into four equal quadrants. The upper-
    /// left quadrant contains the text, Some text in an upper quadrant. The
    /// lower-right quadrant contains the text, More text in a lower quadrant.
    /// In both cases, the text is split over two lines. A blue box that
    /// contains the text, topLeading, appears in the upper-left corner of
    /// the square.](Alignment-topLeading-1-iOS)
    public static let topLeading = Alignment(horizontal: .leading, vertical: .top)

    /// A guide that marks the top and trailing edges of the view.
    ///
    /// This alignment combines the ``HorizontalAlignment/trailing``
    /// horizontal guide and the ``VerticalAlignment/top``
    /// vertical guide:
    ///
    /// ![A square that's divided into four equal quadrants. The upper-
    /// left quadrant contains the text, Some text in an upper quadrant. The
    /// lower-right quadrant contains the text, More text in a lower quadrant.
    /// In both cases, the text is split over two lines. A blue box that
    /// contains the text, topTrailing, appears in the upper-right corner of
    /// the square.](Alignment-topTrailing-1-iOS)
    public static let topTrailing = Alignment(horizontal: .trailing, vertical: .top)

    /// A guide that marks the bottom and leading edges of the view.
    ///
    /// This alignment combines the ``HorizontalAlignment/leading``
    /// horizontal guide and the ``VerticalAlignment/bottom``
    /// vertical guide:
    ///
    /// ![A square that's divided into four equal quadrants. The upper-
    /// left quadrant contains the text, Some text in an upper quadrant. The
    /// lower-right quadrant contains the text, More text in a lower quadrant.
    /// In both cases, the text is split over two lines. A blue box that
    /// contains the text, bottomLeading, appears in the lower-left corner of
    /// the square.](Alignment-bottomLeading-1-iOS)
    public static let bottomLeading = Alignment(horizontal: .leading, vertical: .bottom)

    /// A guide that marks the bottom and trailing edges of the view.
    ///
    /// This alignment combines the ``HorizontalAlignment/trailing``
    /// horizontal guide and the ``VerticalAlignment/bottom``
    /// vertical guide:
    ///
    /// ![A square that's divided into four equal quadrants. The upper-
    /// left quadrant contains the text, Some text in an upper quadrant. The
    /// lower-right quadrant contains the text, More text in a lower quadrant.
    /// In both cases, the text is split over two lines. A blue box that
    /// contains the text, bottomTrailing, appears in the lower-right corner of
    /// the square.](Alignment-bottomTrailing-1-iOS)
    public static let bottomTrailing = Alignment(horizontal: .trailing, vertical: .bottom)
}

extension Alignment {
    /// A guide that marks the top-most text baseline in a view.
    ///
    /// This alignment combines the ``HorizontalAlignment/center``
    /// horizontal guide and the ``VerticalAlignment/firstTextBaseline``
    /// vertical guide:
    ///
    /// ![A square that's divided into four equal quadrants. The upper-
    /// left quadrant contains the text, Some text in an upper quadrant. The
    /// lower-right quadrant contains the text, More text in a lower quadrant.
    /// In both cases, the text is split over two lines. A blue box that
    /// contains the text, centerFirstTextBaseline, appears aligned with, and
    /// partially overlapping, the first line of the text in the upper quadrant,
    /// centered horizontally.](Alignment-centerFirstTextBaseline-1-iOS)
    @_alwaysEmitIntoClient
    public static var centerFirstTextBaseline: Alignment {
        .init(horizontal: .center, vertical: .firstTextBaseline)
    }

    /// A guide that marks the bottom-most text baseline in a view.
    ///
    /// This alignment combines the ``HorizontalAlignment/center``
    /// horizontal guide and the ``VerticalAlignment/lastTextBaseline``
    /// vertical guide:
    ///
    /// ![A square that's divided into four equal quadrants. The upper-
    /// left quadrant contains the text, Some text in an upper quadrant. The
    /// lower-right quadrant contains the text, More text in a lower quadrant.
    /// In both cases, the text is split over two lines. A blue box that
    /// contains the text, centerLastTextBaseline, appears aligned with, and
    /// partially overlapping, the last line of the text in the lower quadrant,
    /// centered horizontally.](Alignment-centerLastTextBaseline-1-iOS)
    @_alwaysEmitIntoClient
    public static var centerLastTextBaseline: Alignment {
        .init(horizontal: .center, vertical: .lastTextBaseline)
    }

    /// A guide that marks the leading edge and top-most text baseline in a
    /// view.
    ///
    /// This alignment combines the ``HorizontalAlignment/leading``
    /// horizontal guide and the ``VerticalAlignment/firstTextBaseline``
    /// vertical guide:
    ///
    /// ![A square that's divided into four equal quadrants. The upper-
    /// left quadrant contains the text, Some text in an upper quadrant. The
    /// lower-right quadrant contains the text, More text in a lower quadrant.
    /// In both cases, the text is split over two lines. A blue box that
    /// contains the text, leadingFirstTextBaseline, appears aligned with, and
    /// partially overlapping, the first line of the text in the upper quadrant.
    /// The box aligns with the left edge of the
    /// square.](Alignment-leadingFirstTextBaseline-1-iOS)
    @_alwaysEmitIntoClient
    public static var leadingFirstTextBaseline: Alignment {
        .init(horizontal: .leading, vertical: .firstTextBaseline)
    }

    /// A guide that marks the leading edge and bottom-most text baseline
    /// in a view.
    ///
    /// This alignment combines the ``HorizontalAlignment/leading``
    /// horizontal guide and the ``VerticalAlignment/lastTextBaseline``
    /// vertical guide:
    ///
    /// ![A square that's divided into four equal quadrants. The upper-
    /// left quadrant contains the text, Some text in an upper quadrant. The
    /// lower-right quadrant contains the text, More text in a lower quadrant.
    /// In both cases, the text is split over two lines. A blue box that
    /// contains the text, leadingLastTextBaseline, appears aligned with the
    /// last line of the text in the lower quadrant. The box aligns with the
    /// left edge of the square.](Alignment-leadingLastTextBaseline-1-iOS)
    @_alwaysEmitIntoClient
    public static var leadingLastTextBaseline: Alignment {
        .init(horizontal: .leading, vertical: .lastTextBaseline)
    }

    /// A guide that marks the trailing edge and top-most text baseline in
    /// a view.
    ///
    /// This alignment combines the ``HorizontalAlignment/trailing``
    /// horizontal guide and the ``VerticalAlignment/firstTextBaseline``
    /// vertical guide:
    ///
    /// ![A square that's divided into four equal quadrants. The upper-
    /// left quadrant contains the text, Some text in an upper quadrant. The
    /// lower-right quadrant contains the text, More text in a lower quadrant.
    /// In both cases, the text is split over two lines. A blue box that
    /// contains the text, trailingFirstTextBaseline, appears aligned with the
    /// first line of the text in the upper quadrant. The box aligns with the
    /// right edge of the square.](Alignment-trailingFirstTextBaseline-1-iOS)
    @_alwaysEmitIntoClient
    public static var trailingFirstTextBaseline: Alignment {
        .init(horizontal: .trailing, vertical: .firstTextBaseline)
    }

    /// A guide that marks the trailing edge and bottom-most text baseline
    /// in a view.
    ///
    /// This alignment combines the ``HorizontalAlignment/trailing``
    /// horizontal guide and the ``VerticalAlignment/lastTextBaseline``
    /// vertical guide:
    ///
    /// ![A square that's divided into four equal quadrants. The upper-
    /// left quadrant contains the text, Some text in an upper quadrant. The
    /// lower-right quadrant contains the text, More text in a lower quadrant.
    /// In both cases, the text is split over two lines. A blue box that
    /// contains the text, trailingLastTextBaseline, appears aligned with the
    /// last line of the text in the lower quadrant. The box aligns with the
    /// right edge of the square.](Alignment-trailingLastTextBaseline-1-iOS)
    @_alwaysEmitIntoClient
    public static var trailingLastTextBaseline: Alignment {
        .init(horizontal: .trailing, vertical: .lastTextBaseline)
    }
}

// MARK: - FrameAlignment [6.4.41]

package protocol FrameAlignment: AlignmentID {}

extension FrameAlignment {
    package static func _combineExplicit(childValue _: CGFloat, _: Int, into _: inout CGFloat?) {}
}

// MARK: - AlignmentKey [6.4.41]

/// A single sort key type for alignment guides in both axes.
///
/// You don't use this type directly.
@_documentation(visibility: private)
@frozen
public struct AlignmentKey: Hashable, Comparable {
    @AtomicBox
    private static var typeCache = TypeCache(typeIDs: [:], types: [])

    struct TypeCache {
        var typeIDs: [ObjectIdentifier: UInt]
        var types: [any AlignmentID.Type]
    }

    private let bits: UInt

    package var id: any AlignmentID.Type {
        Self.typeCache.types[index]
    }

    package var axis: Axis { bits & 1 == 0 ? .horizontal : .vertical }

    @inline(__always)
    var index: Int { Int(bits / 2 - 1) }

    package init(id: AlignmentID.Type, axis: Axis) {
        let index = Self.$typeCache.access { cache in
            let identifier = ObjectIdentifier(id)
            if let value = cache.typeIDs[identifier] {
                return value
            } else {
                let index = UInt(cache.types.count)
                cache.types.append(id)
                cache.typeIDs[identifier] = index
                return index
            }
        }
        bits = (axis == .horizontal ? 0 : 1) + (index + 1) * 2
    }

    package init() { bits = .zero }

    public static func < (lhs: AlignmentKey, rhs: AlignmentKey) -> Bool {
        lhs.bits < rhs.bits
    }

    package var fraction: CGFloat {
        let computer = LayoutComputer.defaultValue
        let dimensions = ViewDimensions(
            guideComputer: computer,
            size: .fixed(CGSize(width: 1.0, height: 1.0))
        )
        return id.defaultValue(in: dimensions)
    }
}

// MARK: - AlignmentGuide [6.4.41]

package protocol AlignmentGuide: Equatable {
    var key: AlignmentKey { get }
}

extension AlignmentGuide {
    package var fraction: CGFloat {
        key.fraction
    }
}
