//
//  ObservationUtil.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 7DF024579E4FC31D4E92A33BBA0366D6 (SwiftUI?)

package import OpenAttributeGraphShims
@_spi(OpenSwiftUI)
package import OpenObservation

// MARK: - ObservationEntry

private struct ObservationEntry {
    let context: AnyObject
    var properties: Set<AnyKeyPath>
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

// MARK: - Observation Utilities [WIP]

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

    var accessList: ObservationTracking._AccessList?
    let result = try withUnsafeMutablePointer(to: &accessList) { ptr in
        let previous = _ThreadLocal.value
        _ThreadLocal.value = UnsafeMutableRawPointer(ptr)
        defer { _ThreadLocal.value = previous }
        return try work()
    }

    // TODO
    // Install observation if we collected any accesses
    if let accessList {
        _installObservation(accessList: accessList, attribute: attribute)
    }
    
    // Merge any access lists collected from nested observations
    // Since merge is internal, we'll just append to our tracking list
    if !ObservationRegistrar.latestAccessLists.isEmpty {
        if accessList == nil {
            // If we don't have an access list yet, use the first nested one
            accessList = ObservationRegistrar.latestAccessLists.first
        }
        // Additional nested access lists will be handled by the observation system
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
    // TODO
}

// MARK: - Rule + Observation [WIP]

extension Rule {
    @inline(__always)
    package func withObservation<T>(do work: () throws -> T) rethrows -> T {
        // For rules, we track observation access and install it on the rule's attribute
        var accessList: ObservationTracking._AccessList?
        let result = try withUnsafeMutablePointer(to: &accessList) { ptr in
            let previous = _ThreadLocal.value
            _ThreadLocal.value = UnsafeMutableRawPointer(ptr)
            defer {
                _ThreadLocal.value = previous
            }
            return try work()
        }
        
        // Install observation tracking if we collected any accesses
        if let accessList {
            // Get the rule's associated attribute and install observation
            // This would typically be done through the rule's context
            // For now, save the access list for later installation
            ObservationRegistrar.latestAccessLists.append(accessList)
        }
        
        return result
    }

    package var observationInstaller: (ObservationTracking._AccessList) -> Void {
        return { accessList in
            // This closure will be called to install observation tracking
            // on the rule's attribute when needed
            let tracking = ObservationTracking(accessList)
            ObservationTracking._installTracking(
                tracking,
                willSet: { _ in
                    // Trigger rule re-evaluation
                },
                didSet: { _ in
                    // Trigger rule re-evaluation
                }
            )
        }
    }
}

// MARK: - StatefulRule + Observation [WIP]

extension StatefulRule {
    @inline(__always)
    package func withObservation<T>(do work: () throws -> T) rethrows -> T {
        // For stateful rules, we track observation access and install it on the rule's attribute
        var accessList: ObservationTracking._AccessList?
        let result = try withUnsafeMutablePointer(to: &accessList) { ptr in
            let previous = _ThreadLocal.value
            _ThreadLocal.value = UnsafeMutableRawPointer(ptr)
            defer {
                _ThreadLocal.value = previous
            }
            return try work()
        }
        
        // Install observation tracking if we collected any accesses
        if let accessList {
            // Get the rule's associated attribute and install observation
            // This would typically be done through the rule's context
            // For now, save the access list for later installation
            ObservationRegistrar.latestAccessLists.append(accessList)
        }
        
        return result
    }

    package var observationInstaller: (ObservationTracking._AccessList) -> Void {
        return { accessList in
            // This closure will be called to install observation tracking
            // on the rule's attribute when needed
            let tracking = ObservationTracking(accessList)
            ObservationTracking._installTracking(
                tracking,
                willSet: { _ in
                    // Trigger rule re-evaluation
                },
                didSet: { _ in
                    // Trigger rule re-evaluation
                }
            )
        }
    }
}
