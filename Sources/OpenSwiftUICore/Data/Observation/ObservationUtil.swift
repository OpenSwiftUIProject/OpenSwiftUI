//
//  ObservationUtil.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Blocked by TraceEvent
//  ID: 7DF024579E4FC31D4E92A33BBA0366D6 (SwiftUI?)

import Foundation
package import OpenAttributeGraphShims
@_spi(OpenSwiftUI)
package import OpenObservation

// MARK: - ObservationEntry

private struct ObservationEntry {
    let context: AnyObject
    var properties: Set<AnyKeyPath>

    func union(_ entry: ObservationEntry) -> ObservationEntry {
        ObservationEntry(context: context, properties: properties.union(entry.properties))
    }
}

extension ObservationTracking._AccessList {
    mutating func merge(_ other: ObservationTracking._AccessList) {
        withUnsafeMutablePointer(to: &self) { ptr1 in
            withUnsafePointer(to: other) { ptr2 in
                let selfPtr = UnsafeMutableRawPointer(mutating: ptr1)
                    .assumingMemoryBound(to: [ObjectIdentifier: ObservationEntry].self)
                let otherPtr = UnsafeRawPointer(ptr2)
                    .assumingMemoryBound(to: [ObjectIdentifier: ObservationEntry].self)
                selfPtr.pointee.merge(otherPtr.pointee) { $0.union($1) }
            }
        }
    }
}

// MARK: - ObservationGraphMutation

private struct ObservationGraphMutation: GraphMutation {
    var invalidatingMutation: InvalidatingGraphMutation
    var observationTracking: [ObservationTracking]
    var subgraphObservers: [(Subgraph, Int)]

    func apply() {
        for (subgraph, observerID) in subgraphObservers {
            subgraph.removeObserver(observerID)
        }
        ObservationRegistrar.latestTriggers.removeAll(keepingCapacity: true)

        for tracking in observationTracking {
            if let changedKeyPath = tracking.changed {
                ObservationRegistrar.latestTriggers.append(changedKeyPath)
            }
            tracking.cancel()
        }
        invalidatingMutation.apply()
        ObservationRegistrar.invalidations.value.removeValue(forKey: invalidatingMutation.attribute)
    }

    mutating func combine<T>(with other: T) -> Bool where T: GraphMutation {
        guard invalidatingMutation.combine(with: other) else {
            return false
        }
        if let otherObservation = other as? ObservationGraphMutation {
            observationTracking.append(contentsOf: otherObservation.observationTracking)
            subgraphObservers.append(contentsOf: otherObservation.subgraphObservers)
        }
        return true
    }

    func cancel() {
        for tracking in observationTracking {
            tracking.cancel()
        }
        for (subgraph, observerID) in subgraphObservers {
            subgraph.removeObserver(observerID)
        }
    }
}

// MARK: - ObservationRegistrar + Extension

extension ObservationRegistrar {
    package static var latestTriggers: [AnyKeyPath] = []

    package static var latestAccessLists: [ObservationTracking._AccessList] = []

    fileprivate static var invalidations: ThreadSpecific<[AnyWeakAttribute: (mutation: ObservationGraphMutation, accessList: ObservationTracking._AccessList)]> = .init([:])
}

// MARK: - Observation Utilities

@inline(__always)
package func _withObservation<T>(
    do work: () throws -> T
) rethrows -> (value: T, accessList: ObservationTracking._AccessList?) {
    var accessList: ObservationTracking._AccessList?
    let result = try withUnsafeMutablePointer(to: &accessList) { ptr in
        let previous = _ThreadLocal.value
        _ThreadLocal.value = UnsafeMutableRawPointer(ptr)
        defer { _ThreadLocal.value = previous }
        return try work()
    }
    if let accessList {
        ObservationRegistrar.latestAccessLists.append(accessList)
    }
    return (result, accessList)
}

@inline(__always)
package func _withObservation<V, T>(
    attribute: Attribute<V>,
    do work: () throws -> T
) rethrows -> T {
    let previousAccessLists = ObservationRegistrar.latestAccessLists
    ObservationRegistrar.latestAccessLists = []
    defer { ObservationRegistrar.latestAccessLists = previousAccessLists }

    let (result, _) = try _withObservation(do: work)
    for accessList in ObservationRegistrar.latestAccessLists {
        installObservationSlow(accessList: accessList, attribute: attribute)
    }
    return result
}

@inline(__always)
package func _installObservation<T>(
    accessLists: [ObservationTracking._AccessList],
    attribute: Attribute<T>
) {
    guard !accessLists.isEmpty else { return }
    for accessList in accessLists {
        installObservationSlow(accessList: accessList, attribute: attribute)
    }
}

private func installObservationSlow<T>(
    accessList: ObservationTracking._AccessList,
    attribute: Attribute<T>
) {
    guard let subgraph = attribute.identifier.subgraph2 else {
        return
    }
    let weakViewGraph = WeakUncheckedSendable(ViewGraph.current)
    let weakAttribute = AnyWeakAttribute(attribute.identifier)

    var newAccessList = accessList
    let removedValue = ObservationRegistrar.invalidations.value.removeValue(forKey: weakAttribute)
    if let removedValue {
        newAccessList.merge(removedValue.accessList)
        removedValue.mutation.cancel()
    }

    let tracking = ObservationTracking(newAccessList)
    let observerID = subgraph.addObserver {
        let removedValue = ObservationRegistrar.invalidations.value.removeValue(forKey: weakAttribute)
        if let removedValue {
            removedValue.mutation.cancel()
        }
    }
    let mutation = ObservationGraphMutation(
        invalidatingMutation: InvalidatingGraphMutation(attribute: weakAttribute),
        observationTracking: [tracking],
        subgraphObservers: [(subgraph, observerID)]
    )
    ObservationRegistrar.invalidations.value[weakAttribute] = (mutation: mutation, accessList: newAccessList)
    ObservationTracking._installTracking(
        tracking,
        willSet: { tracking in
            guard subgraph.isValid else { return }
            Update.ensure {
                guard let attribute = weakAttribute.attribute,
                      let viewGraph = weakViewGraph.value else {
                    mutation.cancel()
                    return
                }
                // TODO: transaction result
                let _ = viewGraph.asyncTransaction(
                    Transaction.current,
                    mutation: mutation,
                    style: Thread.isMainThread ? .immediate : .deferred,
                )
                // TODO: AGGraphAddTraceEvent
            }
        }
    )
}

// MARK: - Rule + Observation

extension Rule {
    @inline(__always)
    package func withObservation<T>(do work: () throws -> T) rethrows -> T {
        try _withObservation(attribute: attribute, do: work)
    }

    package var observationInstaller: (ObservationTracking._AccessList) -> Void {
        { [attribute] accessList in
            guard attribute.subgraph.isValid else {
                return
            }
            attribute.subgraph.apply {
                installObservationSlow(accessList: accessList, attribute: attribute)
            }
        }
    }
}

// MARK: - StatefulRule + Observation

extension StatefulRule {
    @inline(__always)
    package func withObservation<T>(do work: () throws -> T) rethrows -> T {
        try _withObservation(attribute: attribute, do: work)
    }

    package var observationInstaller: (ObservationTracking._AccessList) -> Void {
        { [attribute] accessList in
            guard attribute.subgraph.isValid else {
                return
            }
            attribute.subgraph.apply {
                installObservationSlow(accessList: accessList, attribute: attribute)
            }
        }
    }
}
