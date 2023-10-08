//
//  App.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/22.
//  Lastest Version: iOS 15.5
//  Status: Complete

public protocol App {
    associatedtype Body: Scene
    @SceneBuilder var body: Self.Body { get }
    init()
}

extension App {
    public static func main() {
        let app = Self()
        runApp(app)
    }
}
