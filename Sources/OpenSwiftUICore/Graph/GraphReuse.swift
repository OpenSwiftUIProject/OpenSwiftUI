//
//  GraphReuse.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: 3E2D3733C4CBF57EC1EA761D02CE8317 (SwiftUICore)

import Foundation
package import OpenGraphShims
#if OPENSWIFTUI_SWIFT_LOG
import Logging
#else
import os.log
#endif

// MARK: - IndirectAttributeMap

package final class IndirectAttributeMap {
    package final let subgraph: Subgraph

    package final var map: [AnyAttribute: AnyAttribute]

    package init(subgraph: Subgraph) {
        self.subgraph = subgraph
        self.map = [:]
    }
}

// MARK: - GraphReusable

package protocol GraphReusable {
    static var isTriviallyReusable: Bool { get }

    mutating func makeReusable(indirectMap: IndirectAttributeMap)

    func tryToReuse(by other: Self, indirectMap: IndirectAttributeMap, testOnly: Bool) -> Bool
}

extension GraphReusable {
    @inlinable
    package static var isTriviallyReusable: Bool { false }
}

// MARK: - _GraphValue + GraphReusable

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

// MARK: - _GraphInputs + GraphReusable [6.0.87]

extension _GraphInputs: GraphReusable {
    package mutating func makeReusable(indirectMap: IndirectAttributeMap) {
        time.makeReusable(indirectMap: indirectMap)
        phase.makeReusable(indirectMap: indirectMap)
        environment.makeReusable(indirectMap: indirectMap)
        transaction.makeReusable(indirectMap: indirectMap)
        let stack = customInputs[ReusableInputs.self].stack
        func project<Input>(_ type: Input.Type) where Input: GraphInput {
            guard !Input.isTriviallyReusable else {
                return
            }
            var value = self[Input.self]
            Input.makeReusable(indirectMap: indirectMap, value: &value)
            self[Input.self] = value
        }
        for value in stack {
            project(value)
        }
    }

    package func tryToReuse(by other: _GraphInputs, indirectMap: IndirectAttributeMap, testOnly: Bool) -> Bool {
        guard time.tryToReuse(by: other.time, indirectMap: indirectMap, testOnly: testOnly),
              phase.tryToReuse(by: other.phase, indirectMap: indirectMap, testOnly: testOnly),
              environment.tryToReuse(by: other.environment, indirectMap: indirectMap, testOnly: testOnly),
              transaction.tryToReuse(by: other.transaction, indirectMap: indirectMap, testOnly: testOnly)
        else {
            Log.graphReuse("Reuse failed: standard inputs")
            return false
        }
        return reuseCustomInputs(by: other, indirectMap: indirectMap, testOnly: testOnly)
    }

    private func reuseCustomInputs(by other: _GraphInputs, indirectMap: IndirectAttributeMap, testOnly: Bool) -> Bool {
        let reusableInputs = customInputs[ReusableInputs.self]
        let otherReusableInputs = other.customInputs[ReusableInputs.self]
        guard reusableInputs.filter == otherReusableInputs.filter else {
            return false
        }
        var reusableInputsArray: [ObjectIdentifier] = []
        for value in reusableInputs.stack {
            reusableInputsArray.append(ObjectIdentifier(value))
        }
        var otherReusableInputsArray: [ObjectIdentifier] = []
        for value in otherReusableInputs.stack {
            otherReusableInputsArray.append(ObjectIdentifier(value))
        }
        guard reusableInputsArray == otherReusableInputsArray else {
            Log.graphReuse("Reuse failed: custom inputs type mismatch")
            return false
        }
        var ignoredTypes = reusableInputsArray + [ObjectIdentifier(ReusableInputs.self)]
        guard !customInputs.mayNotBeEqual(to: other.customInputs, ignoredTypes: &ignoredTypes) else {
            Log.graphReuse("Reuse failed: custom inputs plist equality")
            return false
        }
        func project<Input>(_ type: Input.Type) -> Bool where Input: GraphInput {
            guard let index = ignoredTypes.firstIndex(of: ObjectIdentifier(type)) else {
                return true
            }
            let lastIndex = ignoredTypes.count - 1
            ignoredTypes.swapAt(index, lastIndex)
            guard !Input.isTriviallyReusable else {
                return true
            }
            guard Input.tryToReuse(self[type], by: other[type], indirectMap: indirectMap, testOnly: testOnly) else {
                Log.graphReuse("Reuse failed: custom input \(Input.self)")
                return false
            }
            return true
        }
        let stack = reusableInputs.stack
        for value in stack {
            guard project(value) else {
                return false
            }
            continue
        }
        return true
    }
}

// MARK: - Attribute + GraphReusable

extension Attribute: GraphReusable {
    package mutating func makeReusable(indirectMap: IndirectAttributeMap) {
        let indirect: AnyAttribute
        if let result = indirectMap.map[identifier] {
            indirect = result
        } else {
            indirect = indirectMap.subgraph.apply {
                IndirectAttribute(source: self).identifier
            }
            indirectMap.map[identifier] = indirect
        }
        identifier = indirect
    }

    package func tryToReuse(by other: Attribute<Value>, indirectMap: IndirectAttributeMap, testOnly: Bool) -> Bool {
        guard let result = indirectMap.map[identifier] else {
            Log.graphReuse("Reuse failed: missing indirection for \(Value.self)")
            return false
        }
        if !testOnly {
            result.source = other.identifier
        }
        return true
    }
}

private struct EnableGraphReuseLogging: UserDefaultKeyedFeature {
    static var key: String { "org.OpenSwiftUIProject.OpenSwiftUI.GraphReuseLogging" }

    static var cachedValue: Bool?
}

extension Log {
    private static let graphReuseLog: Logger = Logger(subsystem: Log.subsystem, category: "GraphReuse")

    static func graphReuse(_ message: @autoclosure () -> String) {
        if EnableGraphReuseLogging.isEnabled {
            let message = message()
            #if OPENSWIFTUI_SWIFT_LOG
            graphReuseLog.log(level: .info, "\(message)")
            #else
            graphReuseLog.log("\(message)")
            #endif
        }
    }
}
