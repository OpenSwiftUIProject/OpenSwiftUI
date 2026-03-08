//
//  LimitedAvailabilityScene.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 1B9891F523EE168448E28D047E0F9B62 (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - LimitedAvailabilityScene

@available(OpenSwiftUI_v4_1, *)
@usableFromInline
@frozen
@MainActor
@preconcurrency
struct LimitedAvailabilityScene: PrimitiveScene, Scene, _LimitedAvailabilitySceneMarker {
    @usableFromInline
    var storage: LimitedAvailabilitySceneStorageBase

    @usableFromInline
    init<S>(_ scene: S) where S: Scene {
        storage = LimitedAvailabilitySceneStorage(scene)
    }

    @usableFromInline
    var body: Never {
        sceneBodyError()
    }

    nonisolated public static func _makeScenes(
        scene: _GraphValue<LimitedAvailabilityScene>,
        inputs: _SceneInputs
    ) -> _SceneOutputs {
        var outputs = _SceneOutputs()
        outputs.preferences = inputs.preferences.makeIndirectOutputs()
        let indirectOutputs = Attribute(
                IndirectOutputs(
                scene: scene.value,
                parentGraph: Subgraph.current!,
                inputs: inputs,
                outputs: outputs,
                childSubgraph: nil
            )
        )
        outputs.preferences.setIndirectDependency(indirectOutputs.identifier)
        return outputs
    }

    private struct IndirectOutputs: StatefulRule {
        @Attribute var scene: LimitedAvailabilityScene
        var parentGraph: Subgraph
        var inputs: _SceneInputs
        var outputs: _SceneOutputs
        var childSubgraph: Subgraph?

        typealias Value = Void

        mutating func updateValue() {
            guard childSubgraph == nil else { return }
            let graph = parentGraph.graph
            let child = Subgraph(graph: graph)
            childSubgraph = child
            parentGraph.addChild(child)
            child.apply {
                var inputs = inputs
                inputs.base.copyCaches()
                let childOutputs = scene.storage.makeScenes(
                    scene: .init($scene),
                    inputs: inputs
                )
                outputs.preferences.attachIndirectOutputs(to: childOutputs.preferences)
            }
        }
    }
}

@available(*, unavailable)
extension LimitedAvailabilityScene: Sendable {}

// MARK: - LimitedAvailabilitySceneStorageBase

@available(OpenSwiftUI_v4_1, *)
@usableFromInline
class LimitedAvailabilitySceneStorageBase {
    func makeScenes(
        scene: _GraphValue<LimitedAvailabilityScene>,
        inputs: _SceneInputs
    ) -> _SceneOutputs {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

@available(*, unavailable)
extension LimitedAvailabilitySceneStorageBase: Sendable {}

// MARK: - LimitedAvailabilitySceneStorage

@available(OpenSwiftUI_v4_1, *)
private final class LimitedAvailabilitySceneStorage<S>: LimitedAvailabilitySceneStorageBase where S: Scene {
    let scene: S

    init(_ scene: S) {
        self.scene = scene
    }

    override func makeScenes(
        scene: _GraphValue<LimitedAvailabilityScene>,
        inputs: _SceneInputs
    ) -> _SceneOutputs {
        S._makeScene(
            scene: .init(Attribute(Child(scene: scene.value))),
            inputs: inputs
        )
    }

    struct Child: Rule {
        @Attribute var scene: LimitedAvailabilityScene

        var value: S {
            (scene.storage as! LimitedAvailabilitySceneStorage<S>).scene
        }
    }
}
