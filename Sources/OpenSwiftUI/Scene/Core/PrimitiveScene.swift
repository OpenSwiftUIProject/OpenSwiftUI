//
//  PrimitiveScene.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

protocol PrimitiveScene: Scene where Body == Never {}

extension PrimitiveScene {
    public var body: Never {
        sceneBodyError()
    }
}
