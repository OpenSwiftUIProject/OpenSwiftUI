//
//  MultiViewResponder.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 4A74C6B0E69BD6BC864CC77E33CF2D28 (SwiftUICore)

public import Foundation

// MARK: - MultiViewResponder

@_spi(ForOpenSwiftUIOnly)
open class MultiViewResponder: ViewResponder {
    private var _children: [ViewResponder] = []
    private var cache: ContainsPointsCache = .init()
    private var observers: ContentPathObservers = .init()

    override public init() {
        _children = []
        cache = ContainsPointsCache()
        observers = .init()
        super.init()
    }

    override final public var children: [ViewResponder] {
        get { _children }
        set {
            var count = _children.count
            var index = 0
            var changed = false
            for child in newValue {
                var foundIndex: Int?
                if child.parent === self {
                    for candidateIndex in index..<count {
                        if _children[candidateIndex] === child {
                            foundIndex = candidateIndex
                            break
                        }
                    }
                }
                if let foundIndex {
                    if foundIndex != index {
                        _children.swapAt(index, foundIndex)
                        changed = true
                    }
                } else {
                    child.parent = self
                    _children.append(child)
                    if index < count {
                        _children.swapAt(index, count)
                    }
                    count += 1
                    changed = true
                }
                index += 1
            }
            if index < count {
                for removalIndex in index..<count {
                    let child = _children[removalIndex]
                    if child.parent === self {
                        child.parent = nil
                    }
                }
                _children.removeSubrange(index..<count)
                changed = true
            }
            if changed {
                childrenDidChange()
            }
        }
    }

    final package func updateChildren(_ data: (value: [ViewResponder], changed: Bool)) {
        if data.changed {
            children = data.value
        }
    }

    open func childrenDidChange() {
        observers.notifyDidChange(for: self)
    }

    override open func bindEvent(_ event: any EventType) -> ResponderNode? {
        for child in children {
            guard let result = child.bindEvent(event) else {
                continue
            }
            return result
        }
        return nil
    }

    override open func resetGesture() {
        for child in children {
            child.resetGesture()
        }
    }

    override open func containsGlobalPoints(
        _ points: [PlatformPoint],
        cacheKey: UInt32?,
        options: ViewResponder.ContainsPointsOptions
    ) -> ViewResponder.ContainsPointsResult {
        cache.fetch(key: cacheKey) {
            var mask: BitVector64 = []
            var priority: Double = 0
            for child in children {
                let childResult = child.containsGlobalPoints(
                    points,
                    cacheKey: cacheKey,
                    options: options
                )
                mask.formUnion(childResult.mask)
                priority.formMax(childResult.priority)
            }
            return ContainsPointsResult(mask: mask, priority: priority, children: children)
        }
    }

    override open func addContentPath(
        to path: inout Path,
        kind: ContentShapeKinds,
        in space: CoordinateSpace,
        observer: (any ContentPathObserver)?
    ) {
        if let observer {
            observers.addObserver(observer)
        }
        for child in children {
            child.addContentPath(
                to: &path,
                kind: kind,
                in: space,
                observer: observer
            )
        }
    }

    override open func addObserver(_ observer: any ContentPathObserver) {
        observers.addObserver(observer)
    }

    @discardableResult
    override final public func visit(
        applying visitor: (ResponderNode) -> ResponderVisitorResult
    ) -> ResponderVisitorResult {
        let result = visitor(self)
        guard result == .next else {
            return result
        }
        for child in children {
            let childResult = child.visit(applying: visitor)
            guard childResult != .cancel else {
                return .cancel
            }
        }
        return .next
    }
}

@available(*, unavailable)
extension MultiViewResponder: Sendable {}
