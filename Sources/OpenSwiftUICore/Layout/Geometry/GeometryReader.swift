//
//  GeometryReader.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 7D6D22DF7076CCC1FC5284D8E2D1B049 (SwiftUICore)

public import Foundation
package import OpenAttributeGraphShims
import OpenSwiftUI_SPI

// MARK: - GeometryReader [WIP]

/// A container view that defines its content as a function of its own size and
/// coordinate space.
///
/// This view returns a flexible preferred size to its parent layout.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct GeometryReader<Content>: View, UnaryView, PrimitiveView where Content: View {
    public var content: (GeometryProxy) -> Content

    @inlinable
    public init(@ViewBuilder content: @escaping (GeometryProxy) -> Content) {
        self.content = content
    }

    public nonisolated static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs,
    ) -> _ViewOutputs {
        var inputs = inputs
        let child = Attribute(Child(
            view: view.value,
            size: inputs.size,
            position: inputs.position,
            transform: inputs.transform,
            environment: inputs.environment,
            safeAreaInsets: inputs.safeAreaInsets,
            seed: .zero
        ))
        var geometry: Attribute<ViewGeometry>!
        if inputs.needsGeometry {
            let rootGeometry = Attribute(RootGeometry(
                layoutDirection: .init(inputs.layoutDirection),
                proposedSize: inputs.size
            ))
            inputs.position = Attribute(LayoutPositionQuery(
                parentPosition: inputs.position,
                localPosition: rootGeometry.origin()
            ))
            inputs.size = rootGeometry.size()
            geometry = rootGeometry
        }
        var outputs = _VariadicView.Tree._makeView(
            view: .init(child),
            inputs: inputs
        )
        if inputs.needsGeometry {
            geometry.mutateBody(as: RootGeometry.self, invalidating: true) { geometry in
                geometry.$childLayoutComputer = outputs.layoutComputer
            }
        }
        outputs.layoutComputer = nil
        return outputs
    }

    private struct Child: StatefulRule, AsyncAttribute {
        @Attribute var view: GeometryReader
        @Attribute var size: ViewSize
        @Attribute var position: ViewOrigin
        @Attribute var transform: ViewTransform
        @Attribute var environment: EnvironmentValues
        @OptionalAttribute var safeAreaInsets: SafeAreaInsets?
        var seed: UInt32

        typealias Value = _VariadicView.Tree<_LayoutRoot<GeometryReaderLayout>, Content>

        mutating func updateValue() {
            seed &+= 1
            let proxy = GeometryProxy(
                owner: .current!,
                size: $size,
                environment: $environment,
                transform: $transform,
                position: $position,
                safeAreaInsets: $safeAreaInsets,
                seed: seed,
            )
            // TODO: Observation
            let content = view.content(proxy)
            value = .init(root: .init(GeometryReaderLayout()), content: content)
        }
    }
}

@available(*, unavailable)
extension GeometryReader: Sendable {}

// MARK: - GeometryProxy [WIP]

/// A proxy for access to the size and coordinate space (for anchor resolution)
/// of the container view.
@available(OpenSwiftUI_v1_0, *)
public struct GeometryProxy {
    var owner: AnyWeakAttribute
    var _size: WeakAttribute<ViewSize>
    var _environment: WeakAttribute<EnvironmentValues>
    var _transform: WeakAttribute<ViewTransform>
    var _position: WeakAttribute<ViewOrigin>
    var _safeAreaInsets: WeakAttribute<SafeAreaInsets>
    var seed: UInt32

    package init(
        owner: AnyAttribute,
        size: Attribute<ViewSize>,
        environment: Attribute<EnvironmentValues>,
        transform: Attribute<ViewTransform>,
        position: Attribute<ViewOrigin>,
        safeAreaInsets: Attribute<SafeAreaInsets>?,
        seed: UInt32,
    ) {
        self.owner = AnyWeakAttribute(owner)
        self._size = WeakAttribute(size)
        self._environment = WeakAttribute(environment)
        self._transform = WeakAttribute(transform)
        self._position = WeakAttribute(position)
        self._safeAreaInsets = WeakAttribute(safeAreaInsets)
        self.seed = seed
    }

    package var context: AnyRuleContext {
        AnyRuleContext(attribute: owner.attribute ?? .nil)
    }

    /// The size of the container view.
    public var size: CGSize {
        Update.perform {
            guard let size = _size.attribute else {
                return .zero
            }
            return context[size].value
        }
    }

    private var placementContext: _PositionAwarePlacementContext? {
        Update.assertIsLocked()
        guard let owner = owner.attribute,
              let size = _size.attribute,
              let environment = _environment.attribute,
              let transform = _transform.attribute,
              let position = _position.attribute
        else {
            return nil
        }
        return _PositionAwarePlacementContext(
            context: .init(attribute: owner),
            size: size,
            environment: environment,
            transform: transform,
            position: position,
            safeAreaInsets: .init(_safeAreaInsets.attribute),
        )
    }

    /// Resolves the value of an anchor to the container view.
    public subscript<T>(anchor: Anchor<T>) -> T {
        _openSwiftUIUnimplementedFailure()
    }

    /// The safe area inset of the container view.
    public var safeAreaInsets: EdgeInsets {
        Update.perform {
            guard let placementContext else {
                return .zero
            }
            return placementContext.safeAreaInsets()
        }
    }

    /// Returns the container view's bounds rectangle, converted to a defined
    /// coordinate space.
    @available(OpenSwiftUI_v1_0, *)
    @available(*, deprecated, message: "use overload that accepts a CoordinateSpaceProtocol instead")
    @_disfavoredOverload
    public func frame(in coordinateSpace: CoordinateSpace) -> CGRect {
        let size = size
        return Update.perform {
            guard let placementContext else {
                return .zero
            }
            var rect = CGRect(origin: .zero, size: size)
            rect.convert(from: placementContext, to: coordinateSpace)
            return rect
        }
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
        Update.perform {
            guard let environment = _environment.attribute else {
                return EnvironmentValues()
            }
            return context[environment]
        }
    }

    package static var current: GeometryProxy? {
        if let data = _threadGeometryProxyData() {
            data.assumingMemoryBound(to: GeometryProxy.self).pointee
        } else {
            nil
        }
    }

    package func asCurrent<Result>(do body: () throws -> Result) rethrows -> Result {
        let old = _threadGeometryProxyData()
        defer { _setThreadGeometryProxyData(old) }
        return try withUnsafePointer(to: self) { ptr in
            _setThreadGeometryProxyData(.init(mutating: ptr))
            return try body()
        }
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
        to coordinateSpace: some CoordinateSpaceProtocol,
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
        cache: inout (),
    ) -> CGSize {
        proposal.replacingUnspecifiedDimensions(by: .zero)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout (),
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
                dimensions: dimensions,
            )
        }
    }
}
