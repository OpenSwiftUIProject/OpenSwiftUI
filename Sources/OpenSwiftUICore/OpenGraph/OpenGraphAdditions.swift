//
//  OpenGraphAdditions.swift
//  OpenSwiftUICore
//
//  Status: WIP
//  ID: 372497ED4F569296C4450147CA418CD0 (SwiftUICore)

package import OpenGraphShims

// FIXME
extension Subgraph {
    package typealias ChildFlags = Flags
}

extension AnyAttribute {
    package typealias Flags = Subgraph.Flags
}

extension _AttributeBody {
    package typealias Flags = _AttributeType.Flags
}

extension Graph {
    package typealias TraceOptions = TraceFlags
}


// MARK: - Defaultable [6.5.4]

package protocol Defaultable {
    associatedtype Value

    static var defaultValue: Value { get }
}

// MARK: - AsyncAttribute [6.5.4]

package protocol AsyncAttribute: _AttributeBody {}

extension AsyncAttribute {
    package static var flags: Flags { [] }
}

// MARK: - DefaultRule [6.5.4]

package struct DefaultRule<T>: Rule, AsyncAttribute, CustomStringConvertible where T: Defaultable {
    @WeakAttribute var weakValue: T.Value?

    package init() {}

    package static var initialValue: T.Value? { T.defaultValue }

    package var value: T.Value {
        weakValue ?? T.defaultValue
    }

    package var description: String {
        "∨ \(T.Value.self)"
    }

    package typealias Value = T.Value
}

extension Attribute {
    package func overrideDefaultValue<T>(
        _ value: Attribute<Value>?,
        type: T.Type
    ) where Value == T.Value, T: Defaultable {
        mutateBody(
            as: DefaultRule<T>.self,
            invalidating: true
        ) { defaultRule in
            defaultRule.$weakValue = value
        }
    }

    package func invalidateValueIfNeeded() -> Bool {
        _openSwiftUIUnimplementedFailure()
    }

    package func unsafeBitCast<T>(to _: T.Type) -> Attribute<T> {
        unsafeOffset(at: 0, as: T.self)
    }
}

package protocol RemovableAttribute: _AttributeBody {
    static func willRemove(attribute: AnyAttribute)
    static func didReinsert(attribute: AnyAttribute)
}

package protocol InvalidatableAttribute: _AttributeBody {
    static func willInvalidate(attribute: AnyAttribute)
}

extension AnyAttribute.Flags {
    package static var transactional: Subgraph.Flags {
        .init(rawValue: 1 << 0)
    }

    package static var removable: Subgraph.Flags {
        .init(rawValue: 1 << 1)
    }

    package static var invalidatable: Subgraph.Flags {
        .init(rawValue: 1 << 2)
    }

    package static var scrapeable: Subgraph.Flags {
        .init(rawValue: 1 << 3)
    }
}

extension Subgraph.ChildFlags {
    package static var secondary: Subgraph.ChildFlags {
        get { _openSwiftUIUnimplementedFailure() }
    }
}

extension Subgraph {
    package func addSecondaryChild(_ child: Subgraph) {
        _openSwiftUIUnimplementedFailure()
    }

    package func willRemove() {
        forEach(.removable) { attribute in
            let type = attribute._bodyType
            if let removableType = type as? RemovableAttribute.Type {
                removableType.willRemove(attribute: attribute)
            }
        }
    }

    package func didReinsert() {
        forEach(.removable) { attribute in
            let type = attribute._bodyType
            if let removableType = type as? RemovableAttribute.Type {
                removableType.didReinsert(attribute: attribute)
            }
        }
    }

    package func willInvalidate(isInserted: Bool) {
        forEach(isInserted ? [.removable, .invalidatable] : [.invalidatable]) { attribute in
            let type = attribute._bodyType
            if let invalidatableType = type as? InvalidatableAttribute.Type {
                invalidatableType.willInvalidate(attribute: attribute)
            } else if isInserted, let removableType = type as? RemovableAttribute.Type {
                removableType.willRemove(attribute: attribute)
            }
        }
    }
}

extension Attribute {
    package func syncMainIfReferences<T>(do body: (Value) -> T) -> T {
        let (value, flags) = valueAndFlags(options: [.inputOptionsSyncMainRef])
        if flags.contains(.requiresMainThread) {
            var result: T?
            Update.syncMain {
                result = body(value)
            }
            return result!
        } else {
            return body(value)
        }
    }

    package func allowsAsyncUpdate() -> Bool {
        _openSwiftUIUnimplementedFailure()
    }
}

extension WeakAttribute {
    package var uncheckedIdentifier: Attribute<Value> {
        get { _openSwiftUIUnimplementedFailure() }
    }

    package func allowsAsyncUpdate() -> Bool {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - TreeElementFlags [6.5.4]

package struct TreeElementFlags: OptionSet {
    package let rawValue: UInt32

    package init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    package static let viewList: TreeElementFlags = .init(rawValue: 1 << 0)
}

// MARK: - TreeValueFlags [6.5.4]

package struct TreeValueFlags: OptionSet {
    package let rawValue: UInt32

    package init(rawValue: UInt32) {
        _openSwiftUIUnimplementedFailure()
    }

    // FIXME?
    package static let stateSignal: TreeValueFlags = .init(rawValue: 1)
    package static let environmentObjectSignal: TreeValueFlags = .init(rawValue: 2)
    package static let observedObjectSignal: TreeValueFlags = .init(rawValue: 3)
    package static let appStorageSignal: TreeValueFlags = .init(rawValue: 4)
    package static let sceneStorageSignal: TreeValueFlags = .init(rawValue: 5)
}

// MARK: - Metadata Additions [6.5.4]

extension Metadata {
    package var isValueType: Bool {
        switch kind {
            case .struct, .enum, .optional, .tuple: true
            default: false
        }
    }

    // TODO: Optimize this implementation
    package func genericType(at index: Int) -> any Any.Type {
        UnsafeRawPointer(rawValue)
            .advanced(by: index &* 8)
            .advanced(by: 16)
            .assumingMemoryBound(to: Any.Type.self)
            .pointee
    }

    @inline(__always)
    package func projectEnum(
        at ptr: UnsafeRawPointer,
        tag: Int,
        _ body: (UnsafeRawPointer) -> Void
    ) {
        projectEnumData(UnsafeMutableRawPointer(mutating: ptr))
        body(ptr)
        injectEnumTag(tag: UInt32(tag), UnsafeMutableRawPointer(mutating: ptr))
    }
}

@inline(__always)
package func compareEnumTags<T>(_ v1: T, _ v2: T) -> Bool {
    func tag(of value: T) -> Int {
        withUnsafePointer(to: value) {
            Int(Metadata(T.self).enumTag($0))
        }
    }
    let tag1 = tag(of: v1)
    let tag2 = tag(of: v2)
    return tag1 == tag2
}

// MARK: - Attribute + toOptional [6.5.4]

extension Attribute {
    package var toOptional: Attribute<Value?> {
        Attribute<Value?>(ToOptional(data: self))
    }
}

private struct ToOptional<T>: Rule, AsyncAttribute {
    @Attribute var data: T

    typealias Value = T?

    var value: T? { data }
}

// MARK: - Graph Additions

extension Graph {
    @inline(__always)
    package static func cancelCurrentUpdateIfDeadlinePassed() -> Bool {
        _openSwiftUIUnimplementedFailure()
    }

    package static func startTracing(options: Graph.TraceOptions? = nil) {
        Graph.startTracing(nil, flags: options ?? ProcessEnvironment.tracingOptions)
    }

    package static func stopTracing() {
        Graph.stopTracing(nil)
    }
}
