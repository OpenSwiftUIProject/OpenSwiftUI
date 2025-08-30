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

private struct ObservationEntry {
    let context: AnyObject
    var properties: Set<AnyKeyPath>
}

private struct ObservationGraphMutation {
    var invalidatingMutation: InvalidatingGraphMutation
    var observationTracking: [ObservationTracking]
    var subgraphObservers: [(Subgraph, Int)]
}

extension ObservationRegistrar {
    package static var latestTriggers: [AnyKeyPath] = []

    private var invalidation: ThreadSpecific<[AnyWeakAttribute: (mutation: ObservationGraphMutation, accessList: ObservationTracking._AccessList)]> {
        _openSwiftUIUnimplementedFailure()
    }
}

@inline(__always)
package func _withObservation<T>(
    do work: () throws -> T
) rethrows -> (value: T, accessList: ObservationTracking._AccessList?) {
    _openSwiftUIUnimplementedFailure()
}

@inline(__always)
package func _installObservation<T>(
    accessList: ObservationTracking._AccessList?,
    attribute: Attribute<T>
) {
    _openSwiftUIUnimplementedFailure()
}

extension Rule {
    @inline(__always)
    package func withObservation<T>(do work: () throws -> T) rethrows -> T {
        _openSwiftUIUnimplementedFailure()
    }

    package var observationInstaller: (ObservationTracking._AccessList) -> Void {
        _openSwiftUIUnimplementedFailure()
    }
}

extension StatefulRule {
    @inline(__always)
    package func withObservation<T>(do work: () throws -> T) rethrows -> T {
        _openSwiftUIUnimplementedFailure()
    }

    package var observationInstaller: (ObservationTracking._AccessList) -> Void {
        _openSwiftUIUnimplementedFailure()
    }
}
