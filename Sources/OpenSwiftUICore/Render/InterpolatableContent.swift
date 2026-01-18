//
//  InterpolatableContent.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 7377A3587909D054D379011E12826F37 (SwiftUICore)

package import OpenAttributeGraphShims

package protocol InterpolatableContent {
    static var defaultTransition: ContentTransition { get }

    func requiresTransition(to other: Self) -> Bool

    var appliesTransitionsForSizeChanges: Bool { get }

    var addsDrawingGroup: Bool { get }

    func modifyTransition(state: inout ContentTransition.State, to other: Self)

    func defaultAnimation(to other: Self) -> Animation?
}

extension InterpolatableContent where Self: Equatable {
    package func requiresTransition(to other: Self) -> Bool {
        self != other
    }

    package var appliesTransitionsForSizeChanges: Bool {
        false
    }

    package var addsDrawingGroup: Bool {
        false
    }
}

extension InterpolatableContent {
    package static var defaultTransition: ContentTransition {
        .identity
    }

    package func modifyTransition(state: inout ContentTransition.State, to other: Self) {
        _openSwiftUIEmptyStub()
    }

    package func defaultAnimation(to other: Self) -> Animation? {
        nil
    }
}

extension _ViewOutputs {
    package mutating func applyInterpolatorGroup<T>(
        _ group: DisplayList.InterpolatorGroup,
        content: Attribute<T>,
        inputs: _ViewInputs,
        animatesSize: Bool,
        defersRender: Bool
    ) where T: InterpolatableContent {
        _openSwiftUIUnimplementedFailure()
    }
}

private struct InterpolatedDisplayList<Content> where Content: InterpolatableContent {

}
