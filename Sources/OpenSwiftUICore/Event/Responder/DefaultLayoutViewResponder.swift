//
//  DefaultLayoutViewResponder.swift
//  OpenSwiftUICore
//
//  Status: WIP

package import OpenGraphShims

package struct DefaultLayoutResponderFilter: StatefulRule {
//    @Attribute
//    @_projectedValueProperty($children)
//    package var children: [ViewResponder] {
//        get { preconditionFailure("TODO") }
//        nonmutating set { preconditionFailure("TODO") }
//        nonmutating _modify { preconditionFailure("TODO") }
//    }
//
//    package var $children: Attribute<[ViewResponder]> {
//        get { preconditionFailure("TODO") }
//        set { preconditionFailure("TODO") }
//    }
//
//    package let responder: MultiViewResponder
//
//    package init(
//        children: Attribute<[ViewResponder]>,
//        responder: MultiViewResponder
//    ) {
//        preconditionFailure("TODO")
//    }
//
    package typealias Value = [ViewResponder]

    package mutating func updateValue() {
        preconditionFailure("TODO")
    }
}

@_spi(ForOpenSwiftUIOnly)
open class DefaultLayoutViewResponder: MultiViewResponder {
    final package let inputs: _ViewInputs

    final package let viewSubgraph: Subgraph

    package init(inputs: _ViewInputs) {
        preconditionFailure("TODO")
    }
//
//    package init(inputs: _ViewInputs, viewSubgraph: Subgraph) {
//        preconditionFailure("TODO")
//    }
//
//    override open func makeGesture(inputs: _GestureInputs) -> _GestureOutputs<Void> {
//        preconditionFailure("TODO")
//    }
//
//    override open func childrenDidChange() {
//        preconditionFailure("TODO")
//    }
//
//    override open func resetGesture() {
//        preconditionFailure("TODO")
//    }
//
//    @objc deinit {
//        preconditionFailure("TODO")
//    }
}

@available(*, unavailable)
extension DefaultLayoutViewResponder: Sendable {}
