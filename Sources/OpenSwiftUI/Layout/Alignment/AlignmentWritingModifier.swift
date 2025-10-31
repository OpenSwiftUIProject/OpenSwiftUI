//
//  AlignmentWritingModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 3A1D0350CBB400C95A809DBE8B845F0C (SwiftUI)

import OpenAttributeGraphShims
public import OpenCoreGraphicsShims
public import OpenSwiftUICore

// MARK: - _AlignmentWritingModifier

struct _AlignmentWritingModifier: MultiViewModifier, PrimitiveViewModifier {
    let key: AlignmentKey
    let computeValue: @Sendable (ViewDimensions) -> CGFloat

    init(key: AlignmentKey, computeValue: @Sendable @escaping (ViewDimensions) -> CGFloat) {
        self.key = key
        self.computeValue = computeValue
    }

    static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = body(_Graph(), inputs)
        if inputs.requestsLayoutComputer {
            outputs.layoutComputer = Attribute(AlignmentModifiedLayoutComputer(
                modifier: modifier.value,
                childLayoutComputer: OptionalAttribute(outputs.layoutComputer)
            ))
        }
        return outputs
    }
}

// MARK: - AlignmentModifiedLayoutComputer

private struct AlignmentModifiedLayoutComputer: StatefulRule, AsyncAttribute {
    @Attribute var modifier: _AlignmentWritingModifier
    @OptionalAttribute var childLayoutComputer: LayoutComputer?
    
    typealias Value = LayoutComputer

    mutating func updateValue() {
        update(to: Engine(
            modifier: modifier,
            childLayoutComputer: childLayoutComputer ?? .defaultValue
        ))
    }
    
    struct Engine: LayoutEngine {
        var modifier: _AlignmentWritingModifier
        var childLayoutComputer: LayoutComputer

        func sizeThatFits(_ proposedSize: _ProposedSize) -> CGSize {
            childLayoutComputer.sizeThatFits(proposedSize)
        }
        
        func explicitAlignment(_ key: AlignmentKey, at size: ViewSize) -> CGFloat? {
            guard key == modifier.key else {
                return childLayoutComputer.explicitAlignment(key, at: size)
            }
            let dimensions = ViewDimensions(guideComputer: childLayoutComputer, size: size)
            return modifier.computeValue(dimensions)
        }
    }
}

extension View {
    /// Sets the view's horizontal alignment.
    ///
    /// Use `alignmentGuide(_:computeValue:)` to calculate specific offsets
    /// to reposition views in relationship to one another. You can return a
    /// constant or can use the ``ViewDimensions`` argument to the closure to
    /// calculate a return value.
    ///
    /// In the example below, the ``HStack`` is offset by a constant of 50
    /// points to the right of center:
    ///
    ///     VStack {
    ///         Text("Today's Weather")
    ///             .font(.title)
    ///             .border(.gray)
    ///         HStack {
    ///             Text("🌧")
    ///             Text("Rain & Thunderstorms")
    ///             Text("⛈")
    ///         }
    ///         .alignmentGuide(HorizontalAlignment.center) { _ in  50 }
    ///         .border(.gray)
    ///     }
    ///     .border(.gray)
    ///
    /// Changing the alignment of one view may have effects on surrounding
    /// views. Here the offset values inside a stack and its contained views is
    /// the difference of their absolute offsets.
    ///
    /// ![A view showing the two emoji offset from a text element using a
    /// horizontal alignment guide.](SwiftUI-View-HAlignmentGuide.png)
    ///
    /// - Parameters:
    ///   - g: A ``HorizontalAlignment`` value at which to base the offset.
    ///   - computeValue: A closure that returns the offset value to apply to
    ///     this view.
    ///
    /// - Returns: A view modified with respect to its horizontal alignment
    ///   according to the computation performed in the method's closure.
    @preconcurrency
    nonisolated public func alignmentGuide(
        _ g: HorizontalAlignment,
        computeValue: @escaping (ViewDimensions) -> CGFloat
    ) -> some View {
        modifier(_AlignmentWritingModifier(key: g.key, computeValue: computeValue))
    }

    /// Sets the view's vertical alignment.
    ///
    /// Use `alignmentGuide(_:computeValue:)` to calculate specific offsets
    /// to reposition views in relationship to one another. You can return a
    /// constant or can use the ``ViewDimensions`` argument to the closure to
    /// calculate a return value.
    ///
    /// In the example below, the weather emoji are offset 20 points from the
    /// vertical center of the ``HStack``.
    ///
    ///     VStack {
    ///         Text("Today's Weather")
    ///             .font(.title)
    ///             .border(.gray)
    ///
    ///         HStack {
    ///             Text("🌧")
    ///                 .alignmentGuide(VerticalAlignment.center) { _ in -20 }
    ///                 .border(.gray)
    ///             Text("Rain & Thunderstorms")
    ///                 .border(.gray)
    ///             Text("⛈")
    ///                 .alignmentGuide(VerticalAlignment.center) { _ in 20 }
    ///                 .border(.gray)
    ///         }
    ///     }
    ///
    /// Changing the alignment of one view may have effects on surrounding
    /// views. Here the offset values inside a stack and its contained views is
    /// the difference of their absolute offsets.
    ///
    /// ![A view showing the two emoji offset from a text element using a
    /// vertical alignment guide.](SwiftUI-View-VAlignmentGuide.png)
    ///
    /// - Parameters:
    ///   - g: A ``VerticalAlignment`` value at which to base the offset.
    ///   - computeValue: A closure that returns the offset value to apply to
    ///     this view.
    ///
    /// - Returns: A view modified with respect to its vertical alignment
    ///   according to the computation performed in the method's closure.
    @preconcurrency
    nonisolated public func alignmentGuide(
        _ g: VerticalAlignment,
        computeValue: @escaping (ViewDimensions) -> CGFloat
    ) -> some View {
        modifier(_AlignmentWritingModifier(key: g.key, computeValue: computeValue))
    }
}
