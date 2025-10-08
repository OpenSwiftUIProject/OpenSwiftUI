//
//  ScrollPosition+Modifiers.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: TODO
//  ID: E7547C80DE3C7109A44F15E50A35C84F (SwiftUICore)

package import OpenAttributeGraphShims

package enum ScrollPositionStorage {
    case binding(Attribute<Binding<ScrollPosition>>)
    case value(Attribute<ScrollPosition>)
}

package enum ScrollStateInputKind {
    case scrollView
    case scrollContent
}

extension _GraphInputs {
    private struct ContentScrollPositionKey: GraphInput {
        static var defaultValue: ScrollPositionStorage? { nil }
    }

    private struct ScrollPositionKey: GraphInput {
        static var defaultValue: ScrollPositionStorage? { nil }
    }

    private struct ScrollPositionAnchorKey: GraphInput {
        static let defaultValue: OptionalAttribute<UnitPoint?> = .init()
    }

    private struct ContentScrollPositionAnchorKey: GraphInput {
        static let defaultValue: OptionalAttribute<UnitPoint?> = .init()
    }

    package mutating func setScrollPosition(
        storage: ScrollPositionStorage?,
        kind: ScrollStateInputKind
    ) {
        switch kind {
        case .scrollView: self[ScrollPositionKey.self] = storage
        case .scrollContent: self[ContentScrollPositionKey.self] = storage
        }
    }

    package mutating func setScrollPositionAnchor(
        _ anchor: OptionalAttribute<UnitPoint?>,
        kind: ScrollStateInputKind
    ) {
        switch kind {
        case .scrollView: self[ScrollPositionAnchorKey.self] = anchor
        case .scrollContent: self[ContentScrollPositionAnchorKey.self] = anchor
        }
    }
}
