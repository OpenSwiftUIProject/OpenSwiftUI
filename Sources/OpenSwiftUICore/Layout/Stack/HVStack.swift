//
//  HVStack.swift
//  OpenSwiftUICore
//
//  Audited for 6.4.41
//  Status: WIP

package import Foundation

package protocol HVStack: Layout, _VariadicView_UnaryViewRoot where Cache == _StackLayoutCache {
    associatedtype MinorAxisAlignment: AlignmentGuide

    var spacing: CGFloat? { get }

    var alignment: MinorAxisAlignment { get }

    static var majorAxis: Axis { get }

    static var resizeChildrenWithTrailingOverflow: Bool { get }
}

public struct _StackLayoutCache {
    var stack: StackLayout
}

@available(*, unavailable)
extension _StackLayoutCache: Sendable {}

extension HVStack {
    package static var resizeChildrenWithTrailingOverflow: Bool {
        false
    }

    nonisolated public static func _makeView(
        root: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: (_Graph, _ViewInputs) -> _ViewListOutputs
    ) -> _ViewOutputs {
        _makeLayoutView(root: root, inputs: inputs, body: body)
    }
}

extension HVStack {
    public static var layoutProperties: LayoutProperties {
        var properties = LayoutProperties()
        properties.stackOrientation = Self.majorAxis
        properties.isDefaultEmptyLayout = false
        properties.isIdentityUnaryLayout = true
        return properties
    }

    public func makeCache(subviews: Subviews) -> Cache {
        preconditionFailure("TODO")
    }

    public func updateCache(_ cache: inout Cache, subviews: Self.Subviews) {
        preconditionFailure("TODO")
    }

    public func spacing(subviews: Subviews, cache: inout Cache) -> ViewSpacing {
        preconditionFailure("TODO")
    }

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Self.Subviews,
        cache: inout Self.Cache
    ) -> CGSize {
        preconditionFailure("TODO")
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Self.Subviews,
        cache: inout Self.Cache
    ) {
        preconditionFailure("TODO")
    }

    public func explicitAlignment(
        of guide: HorizontalAlignment,
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Self.Subviews,
        cache: inout Self.Cache
    ) -> CGFloat? {
        preconditionFailure("TODO")
    }

    public func explicitAlignment(
        of guide: VerticalAlignment,
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Self.Subviews,
        cache: inout Self.Cache
    ) -> CGFloat? {
        preconditionFailure("TODO")
    }
}
