//
//  ResponderNode.swift
//  OpenSwiftUICore
//
//  Status: Complete

// MARK: - ResponderNode [6.5.4]

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
open class ResponderNode {
    public init() {}

    open var nextResponder: ResponderNode? {
        preconditionFailure("")
    }

    open func bindEvent(_ event: any EventType) -> ResponderNode? {
        nil
    }

    @discardableResult
    open func visit(applying visitor: (ResponderNode) -> ResponderVisitorResult) -> ResponderVisitorResult {
        visitor(self)
    }

    open func makeGesture(inputs: _GestureInputs) -> _GestureOutputs<Void> {
        _GestureOutputs(phase: inputs.intern(.failed, id: .failedValue))
    }

    open func resetGesture() {}

    final package var sequence: some Sequence<ResponderNode> {
        Swift.sequence(first: self) { $0.nextResponder }
    }

    final package func isDescendant(of responder: ResponderNode) -> Bool {
        var current: ResponderNode? = self
        while let currentResponder = current {
            guard currentResponder !== responder else {
                return true
            }
            current = currentResponder.nextResponder
        }
        return false
    }

    final package func firstAncestor<T>(ofType type: T.Type = T.self) -> T? {
        Swift.sequence(first: self) { $0.nextResponder }
            .first(ofType: type)
    }
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension ResponderNode: Sendable {}

// MARK: - ResponderVisitorResult [6.5.4] [WIP]

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
public enum ResponderVisitorResult: Equatable {
    case next

    case skipToNextSibling

    case cancel
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension ResponderVisitorResult: Sendable {}
