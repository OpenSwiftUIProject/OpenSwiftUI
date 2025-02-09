//
//  IDView.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: D4C7BC89F06A89A4754FA9F578FD2C57 (SwiftUI)
//  ID: ADF2FC9997986A8A2C672C0F3AA33367 (SwiftUICore)

package import OpenGraphShims

// MARK: - IDView

@usableFromInline
@frozen
package struct IDView<Content, ID>: View where Content: View, ID: Hashable {
    @usableFromInline
    var content: Content

    @usableFromInline
    var id: ID

    @inlinable
    package init(_ content: Content, id: ID) {
        self.content = content
        self.id = id
    }

    @usableFromInline
    package var body: Never {
        bodyError()
    }
}

@available(*, unavailable)
extension IDView : Sendable {}

// MARK: - IDView + View extension

extension View {
    /// Binds a view's identity to the given proxy value.
    ///
    /// When the proxy value specified by the `id` parameter changes, the
    /// identity of the view — for example, its state — is reset.
    @inlinable
    nonisolated public func id<ID>(_ id: ID) -> some View where ID: Hashable {
        return IDView(self, id: id)
    }
}

// MARK: - IDView + makeView implementation

extension IDView {
    @usableFromInline
    package static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        if _SemanticFeature_v2.isEnabled {
            return makeImplicitRoot(view: view, inputs: inputs)
        } else {
            let id = view.value[offset:{ .of(&$0.id) }]
            let phase = IDPhase(id: id, phase: inputs.viewPhase, lastID: nil, delta: 0)
            var inputs = inputs
            inputs.viewPhase = Attribute(phase)
            return Content.makeDebuggableView(view: view[offset: { .of(&$0.content)}], inputs: inputs)
        }
    }
}

// MARK: - IDPhase

private struct IDPhase<ID>: StatefulRule, AsyncAttribute where ID: Hashable {
    @Attribute var id: ID

    @Attribute var phase: _GraphInputs.Phase

    var lastID: ID?

    var delta: UInt32

    init(id: Attribute<ID>, phase: Attribute<_GraphInputs.Phase>, lastID: ID?, delta: UInt32) {
        self._id = id
        self._phase = phase
        self.lastID = lastID
        self.delta = delta
    }

    typealias Value = _GraphInputs.Phase

    mutating func updateValue() {
        if lastID != id{
            if lastID != nil {
                delta &+= 1
            }
            lastID = id
        }
        var phase = phase
        phase.resetSeed &+= delta
        value = phase
    }
}

// MARK: - IDView + makeViewList implementation

extension IDView {
    @usableFromInline
    package static func _makeViewList(view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
        makeDynamicViewList(metadata: (), view: view, inputs: inputs)
    }

    @usableFromInline
    package static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        Content._viewListCount(inputs: inputs)
    }
}

// MARK: - IDView + DynamicView

extension IDView: DynamicView {
    package static var canTransition: Bool { true }

    package static var traitKeysDependOnView: Bool { false }

    package static func makeID() -> ID { preconditionFailure("") }

    package func childInfo(metadata: ()) -> (any Any.Type, ID?) {
        (Content.self, id)
    }

    package func makeChildView(metadata: (), view: Attribute<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        preconditionFailure("")
    }

    package func makeChildViewList(metadata: (), view: Attribute<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
        var inputs = inputs
        inputs.base.pushStableID(id)
        let view = _GraphValue(CachedView(view: view, id: id))
        return Content.makeDebuggableViewList(view: view, inputs: inputs)
    }

    package typealias Metadata = ()
}

// MARK: - CachedView

private struct CachedView<Content, ID>: StatefulRule, AsyncAttribute where Content: View, ID: Hashable {
    @Attribute var view: IDView<Content, ID>
    let id: ID

    typealias Value = Content

    func updateValue() {
        if !hasValue || id == view.id {
            value = view.content
        }
    }
}
