//
//  ViewGraphFeature.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 8A0FC0E1EA10CEEE185C2315B618A95C (SwiftUICore)

package protocol ViewGraphFeature {
    mutating func modifyViewInputs(inputs: inout _ViewInputs, graph: ViewGraph)
    mutating func modifyViewOutputs(outputs: inout _ViewOutputs, inputs: _ViewInputs, graph: ViewGraph)
    mutating func uninstantiate(graph: ViewGraph)
    mutating func isHiddenForReuseDidChange(graph: ViewGraph)
    mutating func allowsAsyncUpdate(graph: ViewGraph) -> Bool?
    mutating func needsUpdate(graph: ViewGraph) -> Bool
    mutating func update(graph: ViewGraph)
}

extension ViewGraphFeature {
    package mutating func modifyViewInputs(inputs: inout _ViewInputs, graph: ViewGraph) {}
    package mutating func modifyViewOutputs(outputs: inout _ViewOutputs, inputs: _ViewInputs, graph: ViewGraph) {}
    package mutating func uninstantiate(graph: ViewGraph) {}
    package mutating func isHiddenForReuseDidChange(graph: ViewGraph) {}
    package mutating func allowsAsyncUpdate(graph: ViewGraph) -> Bool? { true }
    package mutating func needsUpdate(graph: ViewGraph) -> Bool { false }
    package mutating func update(graph: ViewGraph) {}
}

struct ViewGraphFeatureBuffer: Collection {
    var contents: UnsafeHeterogeneousBuffer

    @discardableResult
    mutating func append<Feature>(_ feature: Feature) -> UnsafeHeterogeneousBuffer.Index where Feature: ViewGraphFeature {
        contents.append(feature, vtable: _VTable<Feature>.self)
    }

    subscript<Feature>(_ type: Feature.Type) -> UnsafeMutablePointer<Feature>? where Feature: ViewGraphFeature {
        guard !contents.isEmpty else { return nil }
        for element in contents {
            guard element.hasType(type) else {
                continue
            }
            return element.body(as: type)
        }
        return nil
    }

    typealias Index = UnsafeHeterogeneousBuffer.Index

    struct Element: ViewGraphFeature {
        var base: UnsafeHeterogeneousBuffer.Element

        private var vtable: VTable.Type {
            base.vtable(as: VTable.self)
        }

        func modifyViewInputs(inputs: inout _ViewInputs, graph: ViewGraph) {
            vtable.modifyViewInputs(elt: base, inputs: &inputs, graph: graph)
        }

        func modifyViewOutputs(outputs: inout _ViewOutputs, inputs: _ViewInputs, graph: ViewGraph) {
            vtable.modifyViewOutputs(elt: base, outputs: &outputs, inputs: inputs, graph: graph)
        }

        func uninstantiate(graph: ViewGraph) {
            vtable.uninstantiate(elt: base, graph: graph)
        }

        func isHiddenForReuseDidChange(graph: ViewGraph) {
            vtable.isHiddenForReuseDidChange(elt: base, graph: graph)
        }

        func allowsAsyncUpdate(graph: ViewGraph) -> Bool? {
            vtable.allowsAsyncUpdate(elt: base, graph: graph)
        }

        func needsUpdate(graph: ViewGraph) -> Bool {
            vtable.needsUpdate(elt: base, graph: graph)
        }

        func update(graph: ViewGraph) {
            vtable.update(elt: base, graph: graph)
        }

        var needsUpdate: Bool {
            get { base.flags.needsUpdate }
            nonmutating set { base.flags.needsUpdate = newValue }
        }

        var skipsAsyncUpdate: Bool {
            get { base.flags.skipsAsyncUpdate }
            nonmutating set { base.flags.skipsAsyncUpdate = newValue }
        }
    }

    var startIndex: UnsafeHeterogeneousBuffer.Index { contents.startIndex }

    var endIndex: UnsafeHeterogeneousBuffer.Index { contents.endIndex }

    var isEmpty: Bool { contents.isEmpty }

    subscript(position: UnsafeHeterogeneousBuffer.Index) -> Element {
        _read { yield Element(base: contents[position]) }
    }

    func index(after i: UnsafeHeterogeneousBuffer.Index) -> UnsafeHeterogeneousBuffer.Index {
        contents.index(after: i)
    }

    private class VTable: _UnsafeHeterogeneousBuffer_VTable {
        class func modifyViewInputs(elt: UnsafeHeterogeneousBuffer.Element, inputs: inout _ViewInputs, graph: ViewGraph) {}
        class func modifyViewOutputs(elt: UnsafeHeterogeneousBuffer.Element, outputs: inout _ViewOutputs, inputs: _ViewInputs, graph: ViewGraph) {}
        class func uninstantiate(elt: UnsafeHeterogeneousBuffer.Element, graph: ViewGraph) {}
        class func isHiddenForReuseDidChange(elt: UnsafeHeterogeneousBuffer.Element, graph: ViewGraph) {}
        class func allowsAsyncUpdate(elt: UnsafeHeterogeneousBuffer.Element, graph: ViewGraph) -> Bool? { nil }
        class func needsUpdate(elt: UnsafeHeterogeneousBuffer.Element, graph: ViewGraph) -> Bool { false }
        class func update(elt: UnsafeHeterogeneousBuffer.Element, graph: ViewGraph) {}
    }

    private final class _VTable<Feature>: VTable where Feature: ViewGraphFeature {
        override class func hasType<T>(_ type: T.Type) -> Bool {
            Feature.self == T.self
        }

        override class func moveInitialize(elt: UnsafeHeterogeneousBuffer.Element, from: _UnsafeHeterogeneousBuffer_Element) {
            let dest = elt.body(as: Feature.self)
            let source = from.body(as: Feature.self)
            dest.initialize(to: source.move())
        }

        override class func deinitialize(elt: UnsafeHeterogeneousBuffer.Element) {
            elt.body(as: Feature.self).deinitialize(count: 1)
        }

        override class func modifyViewInputs(elt: UnsafeHeterogeneousBuffer.Element, inputs: inout _ViewInputs, graph: ViewGraph) {
            elt.body(as: Feature.self).pointee.modifyViewInputs(inputs: &inputs, graph: graph)
        }

        override class func modifyViewOutputs(elt: UnsafeHeterogeneousBuffer.Element, outputs: inout _ViewOutputs, inputs: _ViewInputs, graph: ViewGraph) {
            elt.body(as: Feature.self).pointee.modifyViewOutputs(outputs: &outputs, inputs: inputs, graph: graph)
        }

        override class func uninstantiate(elt: UnsafeHeterogeneousBuffer.Element, graph: ViewGraph) {
            elt.body(as: Feature.self).pointee.uninstantiate(graph: graph)
        }

        override class func isHiddenForReuseDidChange(elt: UnsafeHeterogeneousBuffer.Element, graph: ViewGraph) {
            elt.body(as: Feature.self).pointee.isHiddenForReuseDidChange(graph: graph)
        }

        override class func allowsAsyncUpdate(elt: UnsafeHeterogeneousBuffer.Element, graph: ViewGraph) -> Bool? {
            elt.body(as: Feature.self).pointee.allowsAsyncUpdate(graph: graph)
        }

        override class func needsUpdate(elt: UnsafeHeterogeneousBuffer.Element, graph: ViewGraph) -> Bool {
            elt.body(as: Feature.self).pointee.needsUpdate(graph: graph)
        }

        override class func update(elt: UnsafeHeterogeneousBuffer.Element, graph: ViewGraph) {
            elt.body(as: Feature.self).pointee.update(graph: graph)
        }
    }
}

extension UInt32 {
    fileprivate var needsUpdate: Bool {
        get { self & 0x1 != 0 }
        set {
            if newValue {
                self = self | 0x1
            } else {
                self = self & ~0x1
            }
        }
    }

    fileprivate var skipsAsyncUpdate: Bool {
        get { self & 0x2 != 0 }
        set {
            if newValue {
                self = self | 0x2
            } else {
                self = self & ~0x2
            }
        }
    }
}
