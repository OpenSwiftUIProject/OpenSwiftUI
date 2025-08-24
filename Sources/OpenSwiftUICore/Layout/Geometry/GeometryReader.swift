//
//  GeometryReader.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 7D6D22DF7076CCC1FC5284D8E2D1B049 (SwiftUICore)

public import Foundation
package import OpenGraphShims

// MARK: - GeometryReader [WIP]

@available(OpenSwiftUI_v1_0, *)
@frozen
public struct GeometryReader<Content>: View, UnaryView, PrimitiveView where Content: View {

    public var content: (GeometryProxy) -> Content

    @inlinable
    public init(@ViewBuilder content: @escaping (GeometryProxy) -> Content) {
        self.content = content
    }

    nonisolated public static func _makeView(
        view: _GraphValue<GeometryReader<Content>>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        _openSwiftUIUnimplementedFailure()
    }
}

@available(*, unavailable)
extension GeometryReader: Sendable {}

// MARK: - GeometryProxy [WIP]

/// A proxy for access to the size and coordinate space (for anchor resolution)
/// of the container view.
@available(OpenSwiftUI_v1_0, *)
public struct GeometryProxy {
    package init(
        owner: AnyAttribute,
        size: Attribute<ViewSize>,
        environment: Attribute<EnvironmentValues>,
        transform: Attribute<ViewTransform>,
        position: Attribute<ViewOrigin>,
        safeAreaInsets: Attribute<SafeAreaInsets>?,
        seed: UInt32
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    package var context: AnyRuleContext {
        _openSwiftUIUnimplementedFailure()
    }

    /// The size of the container view.
    public var size: CGSize {
        _openSwiftUIUnimplementedFailure()
    }

    package var placementContext: _PositionAwarePlacementContext? {
        _openSwiftUIUnimplementedFailure()
    }

    /// Resolves the value of an anchor to the container view.
    public subscript<T>(anchor: Anchor<T>) -> T {
        _openSwiftUIUnimplementedFailure()
    }

    /// The safe area inset of the container view.
    public var safeAreaInsets: EdgeInsets {
        _openSwiftUIUnimplementedFailure()
    }

    /// Returns the container view's bounds rectangle, converted to a defined
    /// coordinate space.
    @available(OpenSwiftUI_v1_0, *)
    @available(*, deprecated, message: "use overload that accepts a CoordinateSpaceProtocol instead")
    @_disfavoredOverload
    public func frame(in coordinateSpace: CoordinateSpace) -> CGRect {
        _openSwiftUIUnimplementedFailure()
    }

    @_spi(Private)
    public func frameClippedToScrollViews(in space: CoordinateSpace) -> (frame: CGRect, exact: Bool) {
        _openSwiftUIUnimplementedFailure()
    }

    package func rect(_ r: CGRect, in coordinateSpace: CoordinateSpace) -> CGRect {
        _openSwiftUIUnimplementedFailure()
    }

    package var transform: ViewTransform {
        _openSwiftUIUnimplementedFailure()
    }

    package var environment: EnvironmentValues {
        _openSwiftUIUnimplementedFailure()
    }

    package static var current: GeometryProxy? {
        _openSwiftUIUnimplementedFailure()
    }

    package func asCurrent<Result>(do body: () throws -> Result) rethrows -> Result {
        _openSwiftUIUnimplementedFailure()
    }
}

@available(OpenSwiftUI_v5_0, *)
extension GeometryProxy {
    /// Returns the given coordinate space's bounds rectangle, converted to the
    /// local coordinate space.
    public func bounds(of coordinateSpace: NamedCoordinateSpace) -> CGRect? {
        _openSwiftUIUnimplementedFailure()
    }

    /// Returns the container view's bounds rectangle, converted to a defined
    /// coordinate space.
    public func frame(in coordinateSpace: some CoordinateSpaceProtocol) -> CGRect {
        _openSwiftUIUnimplementedFailure()
    }
}

@available(OpenSwiftUI_v6_0, *)
extension GeometryProxy {
    package func convert(
        globalPoint: CGPoint,
        to coordinateSpace: some CoordinateSpaceProtocol
    ) -> CGPoint {
        _openSwiftUIUnimplementedFailure()
    }
}

@available(*, unavailable)
extension GeometryProxy: Sendable {}

// MARK: - GeometryReaderLayout

private struct GeometryReaderLayout: Layout {
    static var layoutProperties: LayoutProperties {
        var properties = LayoutProperties()
        if !isLinkedOnOrAfter(.v2) {
            properties.isDefaultEmptyLayout = true
            properties.isIdentityUnaryLayout = true
        }
        return properties
    }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        proposal.replacingUnspecifiedDimensions(by: .zero)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        guard !subviews.isEmpty else {
            return
        }
        let anchor = UnitPoint.topLeading
        for subview in subviews {
            let dimensions = subview.dimensions(in: .init(bounds.size))
            subview.place(
                at: bounds.origin,
                anchor: anchor,
                dimensions: dimensions
            )
        }
    }
}
