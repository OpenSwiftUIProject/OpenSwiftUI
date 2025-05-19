public import Foundation
#if canImport(Darwin)
public import CoreGraphics
#endif
package import OpenGraphShims

// MARK: - LayoutValueKey

public protocol LayoutValueKey {
    associatedtype Value
    static var defaultValue: Value { get }
}

// MARK: - LayoutSubview

public struct LayoutSubview: Equatable {
    let proxy: LayoutProxy
    let index: Int32
    let containerLayoutDirection: LayoutDirection

    public var priority: Double {
        proxy.layoutPriority
    }

    public func dimensions(in size: ProposedViewSize) -> ViewDimensions {
        proxy.dimensions(in: _ProposedSize(width: size.width, height: size.height))
    }

    package func place(in geometry: ViewGeometry, layoutDirection: LayoutDirection = .leftToRight) {
        fatalError("TODO")
    }

    public var spacing: ViewSpacing {
        ViewSpacing(proxy.spacing(), layoutDirection: containerLayoutDirection)
    }

    public func place(at point: CGPoint, anchor: UnitPoint = .topLeading, proposal: ProposedViewSize) {
        place(at: point, anchor: anchor, dimensions: proxy.dimensions(in: .init(proposal)))
    }

    package func _trait<K: _ViewTraitKey>(key: K.Type) -> K.Value {
        proxy[key]
    }

    public subscript<K: LayoutValueKey>(key: K.Type) -> K.Value where K: _ViewTraitKey {
        proxy[key]
    }

    public func sizeThatFits(_ size: ProposedViewSize) -> CGSize {
        proxy.size(in: .init(width: size.width, height: size.height))
    }

    package func lengthThatFits(_ size: ProposedViewSize, in axis: Axis) -> CGFloat {
        proxy.lengthThatFits(.init(width: size.width, height: size.height), in: axis)
    }

    package func place(at point: CGPoint, anchor: UnitPoint = .topLeading, dimensions: ViewDimensions) {
        let origin: CGPoint = .init(point - anchor.in(dimensions.size.value))
        guard !origin.isNaN else {
            fatalError("view origin is invalid: \(origin)")
        }
        place(
            in: ViewGeometry(origin: origin, dimensions: dimensions),
            layoutDirection: containerLayoutDirection
        )
    }
}

// MARK: - LayoutSubviews

public struct LayoutSubviews: RandomAccessCollection, Equatable {
    package var context: AnyRuleContext
    private var storage: Storage
    public var layoutDirection: LayoutDirection

    private enum Storage: Equatable {
        case direct([LayoutProxyAttributes])
        case indirect([IndexedAttributes])

        struct IndexedAttributes: Equatable {
            var attributes: LayoutProxyAttributes
            var index: Int32
        }
    }

    public typealias Element = LayoutSubview
    public typealias Index = Int
    public typealias SubSequence = LayoutSubviews

    public var startIndex: Int { 0 }

    public var endIndex: Index {
        switch storage {
        case .direct(let attributes):
            return attributes.endIndex
        case .indirect(let attributes):
            return attributes.endIndex
        }
    }

    public subscript(index: Index) -> Element {
        switch storage {
        case .direct(let attributes):
            LayoutSubview(
                proxy: LayoutProxy(context: context, attributes: attributes[index]),
                index: Int32(index),
                containerLayoutDirection: layoutDirection
            )
        case .indirect(let attributes):
            LayoutSubview(
                proxy: LayoutProxy(context: context, attributes: attributes[index].attributes),
                index: attributes[index].index,
                containerLayoutDirection: layoutDirection
            )
        }
    }

    public subscript(range: Range<Int>) -> LayoutSubviews {
        LayoutSubviews(
            context: context,
            storage: .indirect(range.map { index in
                Storage.IndexedAttributes(
                    attributes: self[index].proxy.attributes,
                    index: Int32(index)
                )
            }),
            layoutDirection: layoutDirection
        )
    }

    package subscript<Indeces>(indices: Indeces) -> LayoutSubviews where Indeces: Sequence, Indeces.Element == Int {
        selecting(indices: indices)
    }

    package func selecting<Indices>(indices: Indices) -> LayoutSubviews where Indices: Sequence, Indices.Element == Int {
        return LayoutSubviews(
            context: context,
            storage: .indirect(indices.map { index in
                Storage.IndexedAttributes(
                    attributes: self[index].proxy.attributes,
                    index: Int32(index)
                )
            }),
            layoutDirection: layoutDirection
        )
    }
}
