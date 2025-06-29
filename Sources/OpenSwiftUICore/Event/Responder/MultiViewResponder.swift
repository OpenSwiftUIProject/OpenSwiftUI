//
//  MultiViewResponder.swift
//  OpenSwiftUICore
//
//  Status: Blocked by children.setter
//  ID: 4A74C6B0E69BD6BC864CC77E33CF2D28 (SwiftUICore?)

public import Foundation

// MARK: - MultiViewResponder [6.5.4] [WIP]

@_spi(ForOpenSwiftUIOnly)
open class MultiViewResponder: ViewResponder {
    private var _children: [ViewResponder]
    private var cache: ContainsPointsCache
    private var observers: ContentPathObservers

    override public init() {
        _children = []
        cache = ContainsPointsCache()
        observers = .init()
        super.init()
    }

    // MARK: - MultiViewResponder: ResponderNode

    override open func bindEvent(_ event: any EventType) -> ResponderNode? {
        for child in children {
            guard let result = child.bindEvent(event) else {
                continue
            }
            return result
        }
        return nil
    }

    @discardableResult
    override final public func visit(applying visitor: (ResponderNode) -> ResponderVisitorResult) -> ResponderVisitorResult {
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

    override open func resetGesture() {
        for child in children {
            child.resetGesture()
        }
    }

    // MARK: - MultiViewResponder: ViewResponder

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
                priority = max(priority, childResult.priority)
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

    override final public var children: [ViewResponder] {
        get { _children }
        set { _openSwiftUIUnimplementedFailure() }
    }

    open func childrenDidChange() {
        observers.notifyDidChange(for: self)
    }
}

@available(*, unavailable)
extension MultiViewResponder: Sendable {}
