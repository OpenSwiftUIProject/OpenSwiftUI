//
//  VerticalAlignment.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete
//  ID: E20796D15DD3D417699102559E024115

import Foundation

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
/// particular view using the ``View/alignmentGuide(_:computeValue:)-6y3u2``
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
/// ``View/alignmentGuide(_:computeValue:)-6y3u2`` view modifier.
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
public struct VerticalAlignment: Equatable {
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

    @usableFromInline
    let key: AlignmentKey

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
            context.height / 2
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
            parentValue = max(childValue, parentValue ?? -.infinity)
        }
    }
}
