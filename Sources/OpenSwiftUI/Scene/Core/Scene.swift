//
//  Scene.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Empty

public protocol Scene {
    associatedtype Body: Scene

    @SceneBuilder
    var body: Self.Body { get }
//    static func _makeScene(scene: _GraphValue<Self>, inputs: _SceneInputs) -> _SceneOutputs
}
extension Never: Scene {}

extension Scene {
    func sceneBodyError() -> Never {
        fatalError("body() should not be called on \(Self.self)")
    }
}
