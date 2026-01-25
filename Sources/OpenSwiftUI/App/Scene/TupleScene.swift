//
//  TupleScene.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - _TupleScene

/// An empty scene.
@available(OpenSwiftUI_v2_0, *)
@usableFromInline
struct _TupleScene<T>: PrimitiveScene, Scene {
    @usableFromInline
    var value: T

    @usableFromInline
    var body: Never {
        sceneBodyError()
    }

    @usableFromInline
    init(_ value: T) {
        self.value = value
    }

    @usableFromInline
    nonisolated static func _makeScene(
        scene: _GraphValue<Self>,
        inputs: _SceneInputs
    ) -> _SceneOutputs {
        let tupleType = TupleType(T.self)
        let description = SceneDescriptor.tupleDescription(tupleType)
        var makeList = MakeList(
            scene: scene,
            inputs: inputs,
            offset: 0,
            outputs: []
        )
        for (index, conformance) in description.contentTypes {
            makeList.offset = TupleType(T.self).elementOffset(at: index)
            conformance.visitType(visitor: &makeList)
        }
        var visitor = MultiPreferenceCombinerVisitor(
            outputs: makeList.outputs.map { $0.preferences },
            result: .init()
        )
        for key in inputs.preferences.keys {
            key.visitKey(&visitor)
        }
        return .init(preferences: visitor.result)
    }

    private struct MakeList: SceneTypeVisitor {
        var scene: _GraphValue<_TupleScene>
        var inputs: _SceneInputs
        var offset: Int
        var outputs: [_SceneOutputs]

        init(
            scene: _GraphValue<_TupleScene>,
            inputs: _SceneInputs,
            offset: Int,
            outputs: [_SceneOutputs]
        ) {
            self.scene = scene
            self.inputs = inputs
            self.offset = offset
            self.outputs = outputs
        }

        mutating func visit<S>(type: S.Type) where S: Scene {
            let output = S._makeScene(
                scene: .init(scene.value.unsafeOffset(at: offset, as: S.self)),
                inputs: inputs
            )
            outputs.append(output)
        }
    }
}

@available(*, unavailable)
extension _TupleScene: Sendable {}
