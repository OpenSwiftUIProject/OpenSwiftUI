//
//  GraphReusable.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: Blocked by _GraphInputs
//  ID: 3E2D3733C4CBF57EC1EA761D02CE8317

package import OpenGraphShims

#if canImport(Darwin)
// TODO: Move down to OpenGraph Package
package typealias Subgraph = OGSubgraph
#endif

package final class IndirectAttributeMap {
    #if canImport(Darwin)
    package final let subgraph: Subgraph
    package final var map: [AnyAttribute: AnyAttribute]
    package init(subgraph: Subgraph) {
        self.subgraph = subgraph
        self.map = [:]
    }
    #endif
}

package protocol GraphReusable {
    static var isTriviallyReusable: Bool { get }
    mutating func makeReusable(indirectMap: IndirectAttributeMap)
    func tryToReuse(by other: Self, indirectMap: IndirectAttributeMap, testOnly: Bool) -> Bool
}

extension GraphReusable {
    @inlinable
    package static var isTriviallyReusable: Bool { false }
}

extension _GraphValue: GraphReusable {
    package mutating func makeReusable(indirectMap: IndirectAttributeMap) {
        value.makeReusable(indirectMap: indirectMap)
    }
    package func tryToReuse(by other: _GraphValue<Value>, indirectMap: IndirectAttributeMap, testOnly: Bool) -> Bool {
        value.tryToReuse(by: other.value, indirectMap: indirectMap, testOnly: testOnly)
    }
}

extension _GraphValue where Value: GraphReusable {
    package static var isTriviallyReusable: Bool { Value.isTriviallyReusable }
}

//extension _GraphInputs : GraphReusable {
//  package mutating func makeReusable(indirectMap: IndirectAttributeMap)
//  package func tryToReuse(by other: _GraphInputs, indirectMap: IndirectAttributeMap, testOnly: Bool) -> Bool
//}

//extension _GraphInputs {
//    private func reuseCustomInputs(by other: _GraphInputs, indirectMap: IndirectAttributeMap, testOnly: Bool) -> Bool {
//        Log.graphReuse("Reuse failed: custom input \(Self.self)")
//    }
//}

extension Attribute: GraphReusable {
    package mutating func makeReusable(indirectMap: IndirectAttributeMap) {
        #if canImport(Darwin)
        if let result = indirectMap.map[identifier] {
            identifier = result
        } else {
            let indirect = indirectMap.subgraph.apply {
                IndirectAttribute(source: self)
            }
            indirectMap.map[identifier] = indirect.identifier
        }
        #endif
    }
    
    package func tryToReuse(by other: Attribute<Value>, indirectMap: IndirectAttributeMap, testOnly: Bool) -> Bool {
        #if canImport(Darwin)
        if let result = indirectMap.map[identifier] {
            if testOnly {
                return true
            } else {
                result.source = other.identifier
                return true
            }
        } else {
            Log.graphReuse("Reuse failed: missing indirection for \(Value.self)")
            return false
        }
        #else
        false
        #endif
    }
}

import Foundation
#if canImport(Darwin)
import os.log
#endif

private enum EnableGraphReuseLogging {
    static var cacheValue: Bool? = nil
}

extension Log {
    #if canImport(Darwin)
    private static let graphReuseLog: Logger = Logger(subsystem: Log.subsystem, category: "GraphReuse")
    #endif
    
    static func graphReuse(_ message: @autoclosure () -> String) {
        #if canImport(Darwin)
        let enable = {
            if let cacheValue = EnableGraphReuseLogging.cacheValue {
                return cacheValue
            } else {
                if UserDefaults.standard.object(forKey: "org.OpenSwiftUIProject.OpenSwiftUI.GraphReuseLogging") != nil {
                    let enable = UserDefaults.standard.bool(forKey: "org.OpenSwiftUIProject.OpenSwiftUI.GraphReuseLogging")
                    EnableGraphReuseLogging.cacheValue = enable
                    return enable
                } else {
                    EnableGraphReuseLogging.cacheValue = false
                    return false
                }
            }
        }()
        if enable {
            let message = message()
            graphReuseLog.log("\(message)")
        }
        #endif
    }
}
