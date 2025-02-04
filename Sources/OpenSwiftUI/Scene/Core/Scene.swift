//
//  Scene.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
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
        preconditionFailure("body() should not be called on \(Self.self).")
    }
}
