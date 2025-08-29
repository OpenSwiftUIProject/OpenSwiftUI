//
//  OptionalView.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package import OpenAttributeGraphShims

extension Optional: PrimitiveView where Wrapped: View {}

@available(OpenSwiftUI_v1_0, *)
extension Optional: View where Wrapped: View {
    public typealias Body = Never

    nonisolated public static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        if _SemanticFeature_v2.isEnabled {
            return makeImplicitRoot(view: view, inputs: inputs)
        } else {
            let metadata = makeConditionalMetadata(ViewDescriptor.self)
            return makeDynamicView(metadata: metadata, view: view, inputs: inputs)
        }
    }

    nonisolated public static func _makeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        let metadata = makeConditionalMetadata(ViewDescriptor.self)
        return makeDynamicViewList(metadata: metadata, view: view, inputs: inputs)
    }

    @available(OpenSwiftUI_v2_0, *)
    nonisolated public static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        Wrapped._viewListCount(inputs: inputs)
    }
}

extension Optional: DynamicView where Wrapped: View {
    package static var canTransition: Bool { true }

    package func childInfo(metadata: ConditionalMetadata<ViewDescriptor>) -> (any Any.Type, UniqueID?) {
        withUnsafePointer(to: self) { ptr in
            metadata.childInfo(ptr: ptr, emptyType: EmptyView.self)
        }
    }

    package func makeChildView(
        metadata: ConditionalMetadata<ViewDescriptor>,
        view: Attribute<Optional<Wrapped>>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        withUnsafePointer(to: self) { ptr in
            metadata.makeView(ptr: ptr, view: view, inputs: inputs)
        }
    }
    
    package func makeChildViewList(
        metadata: ConditionalMetadata<ViewDescriptor>,
        view: Attribute<Optional<Wrapped>>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        withUnsafePointer(to: self) { ptr in
            metadata.makeViewList(ptr: ptr, view: view, inputs: inputs)
        }
    }

    package typealias ID = UniqueID

    package typealias Metadata = ConditionalMetadata<ViewDescriptor>
}
