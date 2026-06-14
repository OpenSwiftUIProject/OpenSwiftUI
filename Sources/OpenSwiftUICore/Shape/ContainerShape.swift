//
//  ContainerShape.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: E7F652304F78E63E0DE3A54ABB60E18A (SwiftUICore)

public import Foundation
import OpenAttributeGraphShims

// MARK: - ContainerRelativeShape

/// A shape that is replaced by an inset version of the current
/// container shape. If no container shape was defined, is replaced by
/// a rectangle.
@available(OpenSwiftUI_v2_0, *)
@frozen
public struct ContainerRelativeShape: Shape {
    nonisolated public func path(in rect: CGRect) -> Path {
        guard let proxy = GeometryProxy.current else {
            return Path(rect)
        }
        let containerShape = proxy.environment.containerShape
        return containerShape.path(in: rect, proxy: proxy)
    }

    @inlinable
    public init() {}
}

@available(OpenSwiftUI_v2_0, *)
extension Shape where Self == ContainerRelativeShape {
    /// A shape that is replaced by an inset version of the current
    /// container shape. If no container shape was defined, is replaced by
    /// a rectangle.
    @_alwaysEmitIntoClient
    public static var containerRelative: ContainerRelativeShape {
        .init()
    }
}

@available(OpenSwiftUI_v2_0, *)
extension ContainerRelativeShape: InsettableShape {
    @inlinable
    nonisolated public func inset(by amount: CGFloat) -> some InsettableShape {
        _Inset(amount: amount)
    }

    @usableFromInline
    @frozen
    struct _Inset: InsettableShape {
        @usableFromInline
        var amount: CGFloat

        @inlinable
        init(amount: CGFloat) {
            self.amount = amount
        }

        @usableFromInline
        nonisolated func path(in rect: CGRect) -> Path {
            ContainerRelativeShape().path(in: rect.insetBy(dx: amount, dy: amount))
        }

        @usableFromInline
        var animatableData: CGFloat {
            get { amount }
            set { amount = newValue }
        }

        @inlinable
        nonisolated func inset(by amount: CGFloat) -> ContainerRelativeShape._Inset {
            var copy = self
            copy.amount += amount
            return copy
        }
    }
}

@available(OpenSwiftUI_v2_0, *)
extension ShapeStyle {
    public func _fillingContainerShape() -> some View {
        ContainerRelativeShape().fill(self)
    }
}

// MARK: - View + ContainerShape

@available(OpenSwiftUI_v3_0, *)
extension View {
    /// Sets the container shape to use for any container relative shape
    /// within this view.
    ///
    /// The example below defines a view that shows its content with a rounded
    /// rectangle background and the same container shape. Any
    /// ``ContainerRelativeShape`` within the `content` matches the rounded
    /// rectangle shape from this container inset as appropriate.
    ///
    ///     struct PlatterContainer<Content: View> : View {
    ///         @ViewBuilder var content: Content
    ///         var body: some View {
    ///             content
    ///                 .padding()
    ///                 .containerShape(shape)
    ///                 .background(shape.fill(.background))
    ///         }
    ///         var shape: RoundedRectangle { RoundedRectangle(cornerRadius: 20) }
    ///     }
    ///
    /// - SeeAlso: ``View/containerShape(_:)-(RoundedRectangularShape)``
    @inlinable
    nonisolated public func containerShape<T>(_ shape: T) -> some View where T: InsettableShape {
        modifier(_ContainerShapeModifier(shape: shape))
    }
}

@available(OpenSwiftUI_v2_0, *)
extension View {
    public func _containerShape<T>(_ shape: T) -> some View where T: InsettableShape {
        modifier(SystemContainerShapeModifier(shape: shape))
    }
}

// MARK: - ContainerShapeModifier

@available(OpenSwiftUI_v3_0, *)
@frozen
public struct _ContainerShapeModifier<Shape>: ViewModifier, MultiViewModifier, PrimitiveViewModifier where Shape: InsettableShape {
    public var shape: Shape

    @inlinable
    public init(shape: Shape) {
        self.shape = shape
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var inputs = inputs
        let shape = Shape.makeAnimatable(
            value: modifier[offset: { .of(&$0.shape) }],
            inputs: inputs.base
        )
        inputs.setContainerShape(shape, isSystemShape: false)
        return body(_Graph(), inputs)
    }

    public typealias Body = Never
}

@available(*, unavailable)
extension _ContainerShapeModifier: Sendable {}

// MARK: - AnyContainerShapeType

private protocol AnyContainerShapeType {
    static func path(
        in rect: CGRect,
        proxy: GeometryProxy,
        shape: AnyWeakAttribute,
        context: ContainerShapeContext
    ) -> Path

    #if OPENSWIFTUI_SUPPORT_2026_API
    static func corners(
        in rect: CGRect,
        proxy: GeometryProxy,
        shape: AnyWeakAttribute,
        context: ContainerShapeContext,
        corners: RoundedRectangularShapeCorners,
        uniformity: ConcentricRectangle.Uniformity
    ) -> RectangleCornerRadii?

    static func corners(
        in size: CGSize?,
        shape: AnyWeakAttribute,
        context: ContainerShapeContext,
    ) -> RectangleCornerRadii?
    #endif
}

// MARK: - SystemContainerShapeModifier

private struct SystemContainerShapeModifier<Shape>: ViewModifier, MultiViewModifier, PrimitiveViewModifier where Shape: InsettableShape {
    var shape: Shape

    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var inputs = inputs
        let shape = Shape.makeAnimatable(
            value: modifier[offset: { .of(&$0.shape) }],
            inputs: inputs.base
        )
        inputs.setContainerShape(shape, isSystemShape: true)
        return body(_Graph(), inputs)
    }

    typealias Body = Never
}

// MARK: - ImplicitContainerShape

package struct ImplicitContainerShape: Shape {
    package init() {}

    nonisolated package func path(in rect: CGRect) -> Path {
        guard let proxy = GeometryProxy.current else {
            return Path(rect)
        }
        let data = proxy.environment.containerShape
        guard !data.isSystemShape else {
            return Path(rect)
        }
        return data.path(in: rect, proxy: proxy)
    }
}

// MARK: - ContainerShape Support

extension _ViewInputs {
    mutating func setContainerShape<S>(_ shape: Attribute<S>, isSystemShape: Bool) where S: InsettableShape {
        guard S.self != ContainerRelativeShape.self else {
            return
        }
        let id = UniqueID()
        let childTransform = Attribute(ContainerShapeTransform(
            transform: transform,
            position: animatedPosition(),
            id: id
        ))
        transform = childTransform
        environment = Attribute(ContainerShapeEnvironment(
            environment: environment,
            data: ContainerShapeData(
                type: ContainerShapeType<S>.self,
                shape: AnyWeakAttribute(shape.identifier),
                context: ContainerShapeContext(
                    id: id,
                    position: WeakAttribute(animatedPosition()),
                    size: WeakAttribute(animatedSize()),
                    childTransform: WeakAttribute(childTransform)
                ),
                isSystemShape: isSystemShape
            )
        ))
        needsGeometry = true
    }
}

private struct ContainerShapeEnvironment: Rule, AsyncAttribute {
    @Attribute var environment: EnvironmentValues
    var data: ContainerShapeData

    var value: EnvironmentValues {
        var environment = environment
        environment.containerShape = data
        return environment
    }
}

private struct ContainerShapeType<Shape>: AnyContainerShapeType where Shape: InsettableShape {
    static func path(
        in rect: CGRect,
        proxy: GeometryProxy,
        shape: AnyWeakAttribute,
        context: ContainerShapeContext
    ) -> Path {
        var result: Path?
        proxy.context.update {
            guard let size = context.size?.value,
                  let shape = shape.unsafeCast(to: Shape.self).value
            else {
                result = Path(rect)
                return
            }
            let convertedRect = context.convert(rect, to: proxy)
            let bounds = CGRect(origin: .zero, size: size)
            let inset = max(
                CGFloat.zero,
                min(
                    convertedRect.minX - bounds.minX,
                    convertedRect.minY - bounds.minY,
                    bounds.maxX - convertedRect.maxX,
                    bounds.maxY - convertedRect.maxY
                )
            )
            result = shape.inset(by: inset).path(in: rect.insetBy(dx: -inset, dy: -inset))
        }
        return result!
    }
}

private struct DefaultContainerShapeType: AnyContainerShapeType {
    static func path(
        in rect: CGRect,
        proxy: GeometryProxy,
        shape: AnyWeakAttribute,
        context: ContainerShapeContext
    ) -> Path {
        Path(rect)
    }
}

private struct ContainerShapeTransform: Rule, AsyncAttribute {
    @Attribute var transform: ViewTransform
    @Attribute var position: ViewOrigin
    var id: UniqueID

    var value: ViewTransform {
        var transform = transform.withPosition(position)
        transform.appendCoordinateSpace(name: id)
        return transform
    }
}

private struct ContainerShapeData {
    var type: any AnyContainerShapeType.Type = DefaultContainerShapeType.self
    var shape: AnyWeakAttribute = .init()
    var context: ContainerShapeContext = .init()
    var isSystemShape: Bool = false

    @inline(__always)
    func path(in rect: CGRect, proxy: GeometryProxy) -> Path {
        type.path(in: rect, proxy: proxy, shape: shape, context: context)
    }
}

private struct ContainerShapeKey: EnvironmentKey {
    static var defaultValue: ContainerShapeData { .init() }
}

extension EnvironmentValues {
    @inline(__always)
    fileprivate var containerShape: ContainerShapeData {
        get { self[ContainerShapeKey.self] }
        set { self[ContainerShapeKey.self] = newValue }
    }
}

private struct ContainerShapeContext {
    var id: UniqueID = .invalid
    @WeakAttribute var position: ViewOrigin?
    @WeakAttribute var size: ViewSize?
    @WeakAttribute var childTransform: ViewTransform?

    func convert(_ rect: CGRect, to proxy: GeometryProxy) -> CGRect {
        if proxy._transform == _childTransform,
           let proxyPosition = proxy._position.value,
           let position = _position.value {
            var rect = rect
            rect.origin += proxyPosition - position
            return rect
        } else {
            return proxy.rect(rect, in: .named(id))
        }
    }
}
