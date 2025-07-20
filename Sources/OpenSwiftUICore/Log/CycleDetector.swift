//
//  CycleDetector.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

import OpenGraphShims

// MARK: - UpdateCycleDetector

package struct UpdateCycleDetector {
    var updateSeed: Attribute<UInt32>
    var lastSeed: UInt32
    var ttl: UInt32
    var hasLogged: Bool

    package init() {
        updateSeed = ViewGraph.current.data.$updateSeed
        lastSeed = .max
        ttl = .zero
        hasLogged = false
    }

    package mutating func reset() {
        lastSeed = .max
        ttl = .zero
        hasLogged = false
    }

    package mutating func dispatch(
        label: @autoclosure () -> String,
        isDebug: Bool = false
    ) -> Bool {
        let seed = Graph.withoutUpdate { updateSeed.value }
        guard lastSeed == seed else {
            lastSeed = seed
            ttl = 2
            return true
        }
        if ttl != 0 {
            ttl &-= 1
        }
        guard ttl == 0 else {
            return true
        }
        if !hasLogged {
            if isDebug {
                Log.externalWarning("\(label()) tried to update multiple times per frame.")
            }
            hasLogged = true
        }
        return false
    }
}

// MARK: - ValueCycleDetector

package struct ValueCycleDetector<Value> where Value: Equatable {
    var updateSeed: Attribute<UInt32>
    var lastSeed: UInt32
    var hasLogged: Bool
    var values: Stack3<Value>

    package init() {
        updateSeed = ViewGraph.current.data.$updateSeed
        lastSeed = .max
        hasLogged = false
        values = .init()
    }

    package mutating func reset() {
        lastSeed = .max
        hasLogged = false
        values = .init()
    }

    package mutating func dispatch(
        value: Value,
        label: @autoclosure () -> String,
        isDebug: Bool = false
    ) -> Bool {
        let seed = Graph.withoutUpdate { updateSeed.value }
        if lastSeed != seed {
            lastSeed = seed
            values = .init()
        }
        guard values.contains(value) else {
            values.push(value)
            return true
        }
        if !hasLogged {
            if isDebug {
                Log.externalWarning("\(label()) is cycling between duplicate values.")
            }
            hasLogged = true
        }
        return false
    }
}
