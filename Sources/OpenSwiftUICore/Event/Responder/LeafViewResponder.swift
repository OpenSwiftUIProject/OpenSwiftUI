//
//  LeafViewResponder.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: A7CB304DFEF7D87240811B051B15E2CD (SwiftUICore)

package import Foundation
package import OpenAttributeGraphShims
import OpenSwiftUI_SPI

// MARK: - ContentResponder

package protocol ContentResponder {
    func contains(points: UnsafeBufferPointer<PlatformPoint>, size: CGSize) -> BitVector64
    func contentPath(size: CGSize) -> Path
    func contentPath(size: CGSize, kind: ContentShapeKinds) -> Path
}

extension ContentResponder {
    package func contains(points: UnsafeBufferPointer<PlatformPoint>, size: CGSize) -> BitVector64 {
        points.mapBool { size.contains(point: $0) }
    }

    package func contentPath(size: CGSize) -> Path {
        Path(CGRect(origin: .zero, size: size))
    }

    package func contentPath(size: CGSize, kind: ContentShapeKinds) -> Path {
        if kind == .interaction || !_SemanticFeature_v3.isEnabled {
            return contentPath(size: size)
        } else {
            return Path()
        }
    }
}

// MARK: - TrivialContentResponder

package struct TrivialContentResponder: ContentResponder {
    package init() {
        _openSwiftUIEmptyStub()
    }
}

// MARK: - LeafResponderFilter

package struct LeafResponderFilter<Data>: StatefulRule where Data: ContentResponder {
    @Attribute var data: Data
    @Attribute var size: ViewSize
    @Attribute var position: ViewOrigin
    @Attribute var transform: ViewTransform

    lazy var responder: LeafViewResponder<Data> = LeafViewResponder()

    package init(
        data: Attribute<Data>,
        size: Attribute<ViewSize>,
        position: Attribute<ViewOrigin>,
        transform: Attribute<ViewTransform>
    ) {
        self._data = data
        self._size = size
        self._position = position
        self._transform = transform
    }

    package typealias Value = ViewRespondersKey.Value

    package mutating func updateValue() {
        responder.helper.update(
            data: $data.changedValue(),
            size: $size.changedValue(),
            position: $position.changedValue(),
            transform: $transform.changedValue(),
            parent: responder
        )
        if !hasValue {
            value = [responder]
        }
    }
}

// MARK: - LeafViewResponder

class LeafViewResponder<Data>: ViewResponder where Data: ContentResponder {
    var helper: ContentResponderHelper<Data>

    override init() {
        helper = ContentResponderHelper()
        super.init()
    }

    override func containsGlobalPoints(
        _ points: [CGPoint],
        cacheKey: UInt32?,
        options: ContainsPointsOptions
    ) -> ContainsPointsResult {
        helper.containsGlobalPoints(
            points,
            cacheKey: cacheKey,
            options: options,
            children: []
        )
    }

    override func addContentPath(
        to path: inout Path,
        kind: ContentShapeKinds,
        in space: CoordinateSpace,
        observer: (any ContentPathObserver)?
    ) {
        helper.addContentPath(to: &path, kind: kind, in: space, observer: observer)
    }

    override var descriptionName: String {
        let size = helper.size
        return "LeafViewResponder<\(Data.self)> (\(size.width), \(size.height))\""
    }

    override func extendPrintTree(string: inout String) {
        let position = helper.globalPosition
        string += "[\(helper.size.width), \(helper.size.height)] @\((position.x, position.y))"
    }
}

// MARK: - ContentResponderHelper

package struct ContentResponderHelper<Data> where Data: ContentResponder {
    package var size: CGSize
    package var data: Data?
    package var transform: ViewTransform
    var observers: ContentPathObservers
    var cache: ViewResponder.ContainsPointsCache

    package init() {
        size = .zero
        data = nil
        transform = ViewTransform()
        observers = ContentPathObservers()
        cache = ViewResponder.ContainsPointsCache()
    }

    package mutating func update(
        data: (value: Data, changed: Bool),
        size: (value: ViewSize, changed: Bool),
        position: (value: CGPoint, changed: Bool),
        transform: (value: ViewTransform, changed: Bool),
        parent: ViewResponder
    ) {
        var changes: ContentPathChanges = []
        let oldTransform = self.transform
        if transform.changed || position.changed {
            self.transform = transform.value.withPosition(position.value)
            changes.formUnion(.transform)
        }
        if size.changed {
            self.size = size.value.value
            changes.formUnion(.size)
        }
        if data.changed || self.data == nil {
            self.data = data.value
            changes.formUnion(.data)
        }
        if !changes.isEmpty {
            observers.notifyPathChanged(
                for: parent,
                changes: changes,
                transform: (old: oldTransform, new: self.transform)
            )
        }
    }

    package var globalPosition: CGPoint {
        transform.convert(.localToSpace(.global), point: .zero)
    }

    package var bounds: CGRect {
        CGRect(origin: globalPosition, size: size)
    }

    package mutating func containsGlobalPoints(
        _ points: [CGPoint],
        cacheKey: UInt32?,
        options: ViewResponder.ContainsPointsOptions,
        children: [ViewResponder]
    ) -> ViewResponder.ContainsPointsResult {
        guard let data else {
            return .passthrough(to: children)
        }
        return cache.fetch(key: cacheKey) {
            guard !points.isEmpty else {
                return .passthrough(to: children)
            }
            return withUnsafeTemporaryAllocation(of: CGPoint.self, capacity: points.count) { buffer in
                _ = buffer.initialize(from: points)
                var buffer = buffer
                transform.convert(.globalToSpace(.local), points: &buffer)
                let mask = data.contains(points: UnsafeBufferPointer(buffer), size: size)
                return ViewResponder.ContainsPointsResult(mask: mask, priority: 1, children: children)
            }
        }
    }

    package mutating func addContentPath(
        to path: inout Path,
        kind: ContentShapeKinds,
        in space: CoordinateSpace,
        observer: (any ContentPathObserver)?
    ) {
        _ = observer.map { observers.addObserver($0) }
        guard let data else {
            return
        }
        var contentPath = data.contentPath(size: size, kind: kind)
        guard !contentPath.isEmpty else {
            return
        }
        contentPath.convert(to: space, transform: transform)
        path.formTrivialUnion(contentPath)
    }
}

// MARK: - ContentPathObservers

struct ContentPathObservers {
    private struct Observer {
        weak var value: (any ContentPathObserver)?
    }

    private var observers: [Observer] = []

    @inline(__always)
    mutating func addObserver(_ observer: any ContentPathObserver) {
        guard !observers.contains(where: { $0.value === observer }) else { return }
        observers.append(Observer(value: observer))
    }

    @inline(__always)
    mutating func notifyDidChange(for parent: ViewResponder) {
        let oldObservers = observers
        observers = []
        for observer in oldObservers {
            guard let value = observer.value else { continue }
            value.respondersDidChange(for: parent)
        }
    }

    mutating func notifyPathChanged(for parent: ViewResponder, changes: ContentPathChanges, transform: (old: ViewTransform, new: ViewTransform)) {
        let oldObservers = observers
        observers = []
        for observer in oldObservers {
            var result = true
            guard let value = observer.value else { continue }
            value.contentPathDidChange(for: parent, changes: changes, transform: transform, finished: &result)
            guard !result else { continue }
            observers.append(observer)
        }
    }
}
