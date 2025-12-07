//
//  Anchor.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: DB1D6A7FECCB5A05E5E6B385ABD35CE6 (SwiftUICore)

package import OpenAttributeGraphShims
package import OpenCoreGraphicsShims

// MARK: - AnchorGeometry

package struct AnchorGeometry {
    private var _position: Attribute<ViewOrigin>
    private var _size: Attribute<CGSize>
    private var _transform: Attribute<ViewTransform>

    package init(
        position: Attribute<ViewOrigin>,
        size: Attribute<CGSize>,
        transform: Attribute<ViewTransform>
    ) {
        _position = position
        _size = size
        _transform = transform
    }

    package var transform: ViewTransform {
        _transform.value.withPosition(_position.value)
    }

    package var size: CGSize {
        _size.value
    }
}

// MARK: Anchor

/// An opaque value derived from an anchor source and a particular view.
///
/// You can convert the anchor to a `Value` in the coordinate space of a target
/// view by using a ``GeometryProxy`` to specify the target view.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct Anchor<Value> {
    fileprivate let box: AnchorValueBoxBase<Value>

    package func `in`(_ context: _PositionAwarePlacementContext) -> Value {
        let transform = context.transform
        return convert(to: transform)
    }

    package func convert(to transform: ViewTransform) -> Value {
        box.convert(to: transform)
    }

    package var defaultValue: Value {
        box.defaultValue
    }

    /// A type-erased geometry value that produces an anchored value of a given
    /// type.
    ///
    /// OpenSwiftUI passes anchored geometry values around the view tree via
    /// preference keys. It then converts them back into the local coordinate
    /// space using a ``GeometryProxy`` value.
    @frozen
    public struct Source {
        private var box: AnchorBoxBase<Value>

        package func prepare(geometry: AnchorGeometry) -> Anchor<Value> {
            Anchor(box: box.prepare(geometry: geometry))
        }

        package init(box: AnchorBoxBase<Value>) {
            self.box = box
        }
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Anchor.Source: Sendable where Value: Sendable {}

@available(OpenSwiftUI_v1_0, *)
extension Anchor: Sendable where Value: Sendable {}

@available(OpenSwiftUI_v3_0, *)
extension Anchor: Equatable where Value: Equatable {
    public static func == (lhs: Anchor<Value>, rhs: Anchor<Value>) -> Bool {
        lhs.box.isEqual(to: rhs.box)
    }
}

@available(OpenSwiftUI_v3_0, *)
extension Anchor: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        box.hash(into: &hasher)
    }
}

// MARK: - AnchorBoxBase

@available(OpenSwiftUI_v1_0, *)
@usableFromInline
package class AnchorBoxBase<T> {
    func prepare(geometry: AnchorGeometry) -> AnchorValueBoxBase<T> {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

@available(OpenSwiftUI_v1_0, *)
extension AnchorBoxBase: @unchecked Sendable where T: Sendable {}

// MARK: - AnchorValueBoxBase

@available(OpenSwiftUI_v1_0, *)
@usableFromInline
internal class AnchorValueBoxBase<T> {
    var defaultValue: T {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func convert(to transform: ViewTransform) -> T {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func isEqual(to other: AnchorValueBoxBase<T>) -> Bool {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func hash(into hasher: inout Hasher) {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

@available(OpenSwiftUI_v1_0, *)
extension AnchorValueBoxBase: @unchecked Sendable where T: Sendable {}

// MARK: - AnchorProtocol

package protocol AnchorProtocol {
    associatedtype AnchorValue: ViewTransformable

    static var defaultAnchor: AnchorValue { get }

    func prepare(geometry: AnchorGeometry) -> AnchorValue

    static func valueIsEqual(lhs: AnchorValue, rhs: AnchorValue) -> Bool

    static func hashValue(_ value: AnchorValue, into hasher: inout Hasher)
}

extension AnchorProtocol where AnchorValue: Equatable {
    package static func valueIsEqual(lhs: AnchorValue, rhs: AnchorValue) -> Bool {
        lhs == rhs
    }
}

extension AnchorProtocol where AnchorValue: Hashable {
    package static func hashValue(_ value: AnchorValue, into hasher: inout Hasher) {
        value.hash(into: &hasher)
    }
}

// MARK: - AnchorBox

private class AnchorBox<T>: AnchorBoxBase<T.AnchorValue>, @unchecked Sendable where T: AnchorProtocol {
    let value: T

    init(value: T) {
        self.value = value
    }

    override func prepare(geometry: AnchorGeometry) -> AnchorValueBoxBase<T.AnchorValue> {
        AnchorValueBox<T>(value: value.prepare(geometry: geometry))
    }
}

private class AnchorValueBox<T>: AnchorValueBoxBase<T.AnchorValue>, @unchecked Sendable where T: AnchorProtocol {
    let value: T.AnchorValue

    init(value: T.AnchorValue) {
        self.value = value
    }

    override var defaultValue: T.AnchorValue {
        T.defaultAnchor
    }

    override func convert(to transform: ViewTransform) -> T.AnchorValue {
        _openSwiftUIUnimplementedFailure()
    }

    override func isEqual(to other: AnchorValueBoxBase<T.AnchorValue>) -> Bool {
        guard let other = other as? AnchorValueBox<T> else {
            return false
        }
        return T.valueIsEqual(lhs: value, rhs: other.value)
    }

    override func hash(into hasher: inout Hasher) {
        T.hashValue(value, into: &hasher)
    }
}

extension Anchor.Source {
    package init<A>(anchor value: A) where Value == A.AnchorValue, A: AnchorProtocol {
        self.init(box: AnchorBox(value: value))
    }
}

// MARK: - ArrayAnchorBox

private class ArrayAnchorBox<T>: AnchorBoxBase<[T]>, @unchecked Sendable {
    let value: [Anchor<T>.Source]

    init(value: [Anchor<T>.Source]) {
        self.value = value
    }

    override func prepare(geometry: AnchorGeometry) -> AnchorValueBoxBase<[T]> {
        ArrayAnchorValueBox<T>(value: value.map { $0.prepare(geometry: geometry) })
    }
}

private class ArrayAnchorValueBox<T>: AnchorValueBoxBase<[T]>, @unchecked Sendable {
    let value: [Anchor<T>]

    init(value: [Anchor<T>]) {
        self.value = value
    }

    override var defaultValue: [T] {
        value.map { $0.defaultValue }
    }

    override func convert(to transform: ViewTransform) -> [T] {
        value.map { $0.convert(to: transform) }
    }

    override func isEqual(to other: AnchorValueBoxBase<[T]>) -> Bool {
        guard let other = other as? ArrayAnchorValueBox<T> else {
            return false
        }
        guard value.count == other.value.count else {
            return false
        }
        for index in value.indices {
            if !value[index].box.isEqual(to: other.value[index].box) {
                return false
            }
        }
        return true
    }

    override func hash(into hasher: inout Hasher) {
        value.forEach { $0.box.hash(into: &hasher) }
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Anchor.Source {
    public init<T>(_ array: [Anchor<T>.Source]) where Value == [T] {
        self.init(box: ArrayAnchorBox(value: array))
    }
}

// MARK: - OptionalAnchorBox

private class OptionalAnchorBox<T>: AnchorBoxBase<T?>, @unchecked Sendable {
    let value: Anchor<T>.Source?

    init(value: Anchor<T>.Source?) {
        self.value = value
    }

    override func prepare(geometry: AnchorGeometry) -> AnchorValueBoxBase<T?> {
        OptionalAnchorValueBox<T>(value: value.map { $0.prepare(geometry: geometry) })
    }
}

private class OptionalAnchorValueBox<T>: AnchorValueBoxBase<T?>, @unchecked Sendable {
    let value: Anchor<T>?

    init(value: Anchor<T>?) {
        self.value = value
    }

    override var defaultValue: T? {
        value.map { $0.defaultValue }
    }

    override func convert(to transform: ViewTransform) -> T? {
        value.map { $0.convert(to: transform) }
    }

    override func isEqual(to other: AnchorValueBoxBase<T?>) -> Bool {
        guard let other = other as? OptionalAnchorValueBox<T> else {
            return false
        }
        guard let value, let otherValue = other.value else {
            return value == nil && other.value == nil
        }
        return value.box.isEqual(to: otherValue.box)
    }

    override func hash(into hasher: inout Hasher) {
        if let value {
            value.box.hash(into: &hasher)
        }
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Anchor.Source {
    public init<T>(_ anchor: Anchor<T>.Source?) where Value == T? {
        self.init(box: OptionalAnchorBox(value: anchor))
    }
}
