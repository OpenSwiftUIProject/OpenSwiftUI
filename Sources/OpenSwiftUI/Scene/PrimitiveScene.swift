//
//  PrimitiveScene.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/22.
//  Lastest Version: iOS 15.5
//  Status: Complete

protocol PrimitiveScene: Scene where Body == Never {}

extension PrimitiveScene {
    public var body: Never {
        sceneBodyError()
    }
}
