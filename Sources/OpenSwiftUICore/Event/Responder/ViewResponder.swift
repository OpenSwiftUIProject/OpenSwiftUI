//
//  ViewResponder.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 5DC9CCF050AF89FBA971AEC7E32C63B6 (SwiftUICore)

public import Foundation
package import OpenAttributeGraphShims

// MARK: - ViewRespondersKey

package struct ViewRespondersKey: PreferenceKey {
    package static var defaultValue: [ViewResponder] { [] }
    
    package static var _includesRemovedValues: Bool { true }
    
    package static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}

extension PreferencesInputs {
    @inline(__always)
    package var requiresViewResponders: Bool {
        get { contains(ViewRespondersKey.self) }
        set {
            if newValue {
                add(ViewRespondersKey.self)
            } else {
                remove(ViewRespondersKey.self)
            }
        }
    }
}

extension PreferencesOutputs {
    @inline(__always)
    package var viewResponders: Attribute<[ViewResponder]>? {
        get { self[ViewRespondersKey.self] }
        set { self[ViewRespondersKey.self] = newValue }
    }
}

// MARK: - ViewResponder

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
open class ViewResponder: ResponderNode, CustomStringConvertible, CustomRecursiveStringConvertible {
    final package private(set) weak var host: (any ViewGraphDelegate)? = nil

    override public init() {
        host = ViewGraph.current.delegate
    }

    final package weak var parent: ViewResponder? = nil {
        willSet {
            guard parent != nil,
                  newValue == nil,
                  let host,
                  let eventGraphHost = host.as(EventGraphHost.self) else {
                return
            }
            eventGraphHost.eventBindingManager.willRemoveResponder(self)
            resetGesture()
        }
    }

    override final public var nextResponder: ResponderNode? { parent }

    open var gestureContainer: AnyObject? { nil }

    open var opacity: Double { 1.0 }

    open var allowsHitTesting: Bool { true }

    package struct ContainsPointsCache {
        var storage: (key: UInt32?, value: ContainsPointsResult)?

        package init() {
            storage = nil
        }

        package mutating func fetch(
            key: UInt32?,
            _ body: () -> ContainsPointsResult
        ) -> ContainsPointsResult {
            guard let storage, let storageKey = storage.key, let key, storageKey == key else {
                let result = body()
                storage = (key, result)
                return result
            }
            return storage.value
        }
    }

    package static let gestureContainmentPriority: Double = 16.0

    public struct ContainsPointsOptions: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        package static let allowDisabledViews: ContainsPointsOptions = .init(rawValue: 1 << 0)

        package static let useZDistanceAsPriority: ContainsPointsOptions = .init(rawValue: 1 << 1)

        package static let disablePointCloudHitTesting: ContainsPointsOptions = .init(rawValue: 1 << 2)

        package static let allow3DResponders: ContainsPointsOptions = .init(rawValue: 1 << 3)

        package static let crossingServerIDBoundary: ContainsPointsOptions = .init(rawValue: 1 << 4)

        package static let uncached: ContainsPointsOptions = .init(rawValue: 1 << 5)

        public static var platformDefault: ContainsPointsOptions { [] }
    }

    public struct ContainsPointsResult {
        package var mask: BitVector64
        package var priority: Double
        package var children: [ViewResponder]

        package init(mask: BitVector64, priority: Double, children: [ViewResponder]) {
            self.mask = mask
            self.priority = priority
            self.children = children
        }

        package static func passthrough(to children: [ViewResponder]) -> ContainsPointsResult {
            ContainsPointsResult(mask: .init(), priority: 0, children: children)
        }

        package static var stop: ContainsPointsResult {
            ContainsPointsResult(mask: .init(), priority: 0, children: [])
        }
    }

    open func containsGlobalPoints(
        _ points: [PlatformPoint],
        cacheKey: UInt32?,
        options: ContainsPointsOptions
    ) -> ContainsPointsResult {
        .passthrough(to: children)
    }

    open func addContentPath(
        to path: inout Path,
        kind: ContentShapeKinds,
        in space: CoordinateSpace,
        observer: (any ContentPathObserver)?
    ) {
        _openSwiftUIEmptyStub()
    }

    open func addObserver(_ observer: any ContentPathObserver) {
        _openSwiftUIEmptyStub()
    }

    open var children: [ViewResponder] { [] }

    final public var childCount: Int { children.count }

    final public func child(at index: Int) -> ViewResponder {
        children[index]
    }

    open var descriptionName: String {
        recursiveDescriptionName(Self.self)
    }

    public var description: String {
        "node(\(address(of: self)) \(descriptionName))"
    }

    final package var descriptionChildren: [any CustomRecursiveStringConvertible] {
        children
    }

    @inline(never)
    final package func printTree(depth: Int = 0) {
        var string = "\(indentString(depth))+"
        string += " \(descriptionName) \(address(of: self)) "
        extendPrintTree(string: &string)
        Log.eventDebug(string)
        for child in children {
            child.printTree(depth: depth + 1)
        }
    }

    open func extendPrintTree(string: inout String) {
        _openSwiftUIEmptyStub()
    }
}

private func indentString(_ depth: Int) -> String {
    var result = ""
    for _ in 0..<depth {
        result.append("| ")
    }
    return result
}

extension ViewGraph {
    package static var eventGraphHost: (any EventGraphHost)? {
        ViewGraph.current.delegate?.as(EventGraphHost.self)
    }
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension ViewResponder: Sendable {}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension ViewResponder.ContainsPointsOptions: Sendable {}
