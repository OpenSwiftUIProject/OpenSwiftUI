//
//  PrimitiveScene.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

protocol PrimitiveScene: Scene where Body == Never {}

extension PrimitiveScene {
    public var body: Never {
        sceneBodyError()
    }
}
