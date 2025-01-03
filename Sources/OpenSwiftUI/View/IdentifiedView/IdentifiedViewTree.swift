//
//  IdentifiedViewTree.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Complete

public enum _IdentifiedViewTree {
    case empty
    case proxy(_IdentifiedViewProxy)
    case array([_IdentifiedViewTree])
    
    public func forEach(_ body: (_IdentifiedViewProxy) -> Void) {
        switch self {
            case .empty:
                break
            case let .proxy(proxy):
                body(proxy)
            case let .array(array):
                for treeElement in array {
                    treeElement.forEach(body)
                }
        }
    }
}

@available(*, unavailable)
extension _IdentifiedViewTree: Sendable {}
