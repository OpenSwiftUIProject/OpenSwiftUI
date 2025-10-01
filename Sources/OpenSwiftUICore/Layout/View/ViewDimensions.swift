//
//  ViewDimensions.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

public import Foundation

/// A view's size and alignment guides in its own coordinate space.
///
/// This structure contains the size and alignment guides of a view.
/// You receive an instance of this structure to use in a variety of
/// layout calculations, like when you:
///
/// * Define a default value for a custom alignment guide;
///   see ``AlignmentID/defaultValue(in:)``.
/// * Modify an alignment guide on a view;
///   see ``View/alignmentGuide(_:computeValue:)-9mdoh``.
/// * Ask for the dimensions of a subview of a custom view layout;
///   see ``LayoutSubview/dimensions(in:)``.
///
/// ### Custom alignment guides
///
/// You receive an instance of this structure as the `context` parameter to
/// the ``AlignmentID/defaultValue(in:)`` method that you implement to produce
/// the default offset for an alignment guide, or as the first argument to the
/// closure you provide to the ``View/alignmentGuide(_:computeValue:)-6y3u2``
/// view modifier to override the default calculation for an alignment guide.
/// In both cases you can use the instance, if helpful, to calculate the
/// offset for the guide. For example, you could compute a default offset
/// for a custom ``VerticalAlignment`` as a fraction of the view's ``height``:
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
/// As another example, you could use the view dimensions instance to look
/// up the offset of an existing guide and modify it:
///
///     struct ViewDimensionsOffset: View {
///         var body: some View {
///             VStack(alignment: .leading) {
///                 Text("Default")
///                 Text("Indented")
///                     .alignmentGuide(.leading) { context in
///                         context[.leading] - 10
///                     }
///             }
///         }
///     }
///
/// The example above indents the second text view because the subtraction
/// moves the second text view's leading guide in the negative x direction,
/// Openwhich is to the left in the view's coordinate space. As a result,
/// OpenSwiftUI moves the second text view to the right, relative to the first
/// text view, to keep their leading guides aligned:
///
/// ![A screenshot of two strings. The first says Default and the second,
/// which appears below the first, says Indented. The left side of the second
/// string appears horizontally offset to the right from the left side of the
/// first string by about the width of one character.](ViewDimensions-1-iOS)
///
/// ### Layout direction
///
/// The discussion above describes a left-to-right language environment,
/// but you don't change your guide calculation to operate in a right-to-left
/// environment. OpenSwiftUI moves the view's origin from the left to the right side
/// of the view and inverts the positive x direction. As a result,
/// the existing calculation produces the same effect, but in the opposite
/// direction.
///
/// You can see this if you use the ``View/environment(_:_:)``
/// modifier to set the ``EnvironmentValues/layoutDirection`` property for the
/// view that you defined above:
///
///     ViewDimensionsOffset()
///         .environment(\.layoutDirection, .rightToLeft)
///
/// With no change in your guide, this produces the desired effect ---
/// it indents the second text view's right side, relative to the
/// first text view's right side. The leading edge is now on the right,
/// and the direction of the offset is reversed:
///
/// ![A screenshot of two strings. The first says Default and the second,
/// which appears below the first, says Indented. The right side of the second
/// string appears horizontally offset to the left from the right side of the
/// first string by about the width of one character.](ViewDimensions-2-iOS)
public struct ViewDimensions {
    package let guideComputer: LayoutComputer

    /// The view's width.
    public var width: CGFloat { size.width }

    /// The view's height.
    public var height: CGFloat { size.height }

    package var size: ViewSize
    
    package init(guideComputer: LayoutComputer, size: ViewSize) {
        self.guideComputer = guideComputer
        self.size = size
    }
    
    package init(guideComputer: LayoutComputer, size: CGSize, proposal: _ProposedSize) {
        self.guideComputer = guideComputer
        self.size = ViewSize(size, proposal: proposal)
    }

    /// Gets the value of the given horizontal guide.
    ///
    /// Find the offset of a particular guide in the corresponding view by
    /// using that guide as an index to read from the context:
    ///
    ///     .alignmentGuide(.leading) { context in
    ///         context[.leading] - 10
    ///     }
    ///
    /// For information about using subscripts in Swift to access member
    /// elements of a collection, list, or, sequence, see
    /// [Subscripts](https://docs.swift.org/swift-book/LanguageGuide/Subscripts.html)
    /// in _The Swift Programming Language_.
    public subscript(guide: HorizontalAlignment) -> CGFloat {
        self[guide.key]
    }

    /// Gets the value of the given vertical guide.
    ///
    /// Find the offset of a particular guide in the corresponding view by
    /// using that guide as an index to read from the context:
    ///
    ///     .alignmentGuide(.top) { context in
    ///         context[.top] - 10
    ///     }
    ///
    /// For information about using subscripts in Swift to access member
    /// elements of a collection, list, or, sequence, see
    /// [Subscripts](https://docs.swift.org/swift-book/LanguageGuide/Subscripts.html)
    /// in _The Swift Programming Language_.
    public subscript(guide: VerticalAlignment) -> CGFloat {
        self[guide.key]
    }

    @inline(__always)
    subscript(guide: Alignment) -> (CGFloat, CGFloat) {
        (self[guide.horizontal], self[guide.vertical])
    }

    /// Gets the explicit value of the given horizontal alignment guide.
    ///
    /// Find the horizontal offset of a particular guide in the corresponding
    /// view by using that guide as an index to read from the context:
    ///
    ///     .alignmentGuide(.leading) { context in
    ///         context[.leading] - 10
    ///     }
    ///
    /// This subscript returns `nil` if no value exists for the guide.
    ///
    /// For information about using subscripts in Swift to access member
    /// elements of a collection, list, or, sequence, see
    /// [Subscripts](https://docs.swift.org/swift-book/LanguageGuide/Subscripts.html)
    /// in _The Swift Programming Language_.
    public subscript(explicit guide: HorizontalAlignment) -> CGFloat? {
        self[explicit: guide.key]
    }

    /// Gets the explicit value of the given vertical alignment guide
    ///
    /// Find the vertical offset of a particular guide in the corresponding
    /// view by using that guide as an index to read from the context:
    ///
    ///     .alignmentGuide(.top) { context in
    ///         context[.top] - 10
    ///     }
    ///
    /// This subscript returns `nil` if no value exists for the guide.
    ///
    /// For information about using subscripts in Swift to access member
    /// elements of a collection, list, or, sequence, see
    /// [Subscripts](https://docs.swift.org/swift-book/LanguageGuide/Subscripts.html)
    /// in _The Swift Programming Language_.
    public subscript(explicit guide: VerticalAlignment) -> CGFloat? {
        self[explicit: guide.key]
    }

    @inline(__always)
    subscript(explicit guide: Alignment) -> (CGFloat?, CGFloat?) {
        (self[explicit: guide.horizontal], self[explicit: guide.vertical])
    }
}

@available(*, unavailable)
extension ViewDimensions: Sendable {}

extension ViewDimensions: Equatable {}

extension ViewDimensions {
    /// A constant representing an invalid view dimensions value.
    ///
    /// This value is used internally to indicate when dimensions are not valid or not yet calculated.
    package static let invalidValue = ViewDimensions(guideComputer: .defaultValue, size: .invalidValue)

    /// A view dimensions instance with zero width and height.
    ///
    /// This provides a convenient way to create dimensions for an empty view.
    package static let zero = ViewDimensions(guideComputer: .defaultValue, size: .zero)
    
    /// Creates a `ViewGeometry` instance with the receiver as dimensions and the specified point as origin.
    ///
    /// - Parameter topLeadingCorner: The point to use as the top-leading corner of the view.
    /// - Returns: A new `ViewGeometry` instance combining the dimensions with the specified origin.
    package func at(_ topLeadingCorner: CGPoint) -> ViewGeometry {
        ViewGeometry(origin: ViewOrigin(topLeadingCorner), dimensions: self)
    }
    
    /// Creates a `ViewGeometry` instance with the receiver as dimensions centered within the specified size.
    ///
    /// This method calculates the appropriate origin so that the view appears centered
    /// within the container of the given size.
    ///
    /// - Parameter setting: The containing size within which to center these dimensions.
    /// - Returns: A new `ViewGeometry` instance representing the centered placement.
    package func centered(in setting: CGSize) -> ViewGeometry {
        ViewGeometry(origin: ViewOrigin((setting - size.value) / 2 + .zero), dimensions: self)
    }
    
    /// Gets the value of the given alignment guide.
    ///
    /// This subscript calculates the guide value, either using an explicit value if one exists,
    /// or falling back to the guide's default value if no explicit value is available.
    ///
    /// - Parameter key: The alignment key to look up.
    /// - Returns: The guide value for the specified alignment.
    package subscript(key: AlignmentKey) -> CGFloat {
        self[explicit: key] ?? key.id.defaultValue(in: self)
    }
    
    /// Gets the explicit value of the given alignment guide, if one exists.
    ///
    /// This subscript returns the explicitly set alignment guide value without applying
    /// any default calculations.
    ///
    /// - Parameter key: The alignment key to look up.
    /// - Returns: The explicit guide value if one exists, or nil if no explicit value was set.
    package subscript(explicit key: AlignmentKey) -> CGFloat? {
        guideComputer.explicitAlignment(key, at: size)
    }
}
