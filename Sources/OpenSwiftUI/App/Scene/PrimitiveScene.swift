//
//  PrimitiveScene.swift
//  OpenSwiftUI
//
//  Audited for 3.5.2
//  Status: Complete

protocol PrimitiveScene: Scene where Body == Never {}

extension PrimitiveScene {
    public var body: Never {
        sceneBodyError()
    }
}
