//
//  ViewBuilder.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/22.
//  Lastest Version: iOS 17.0
//  Status: Blocked

@resultBuilder
public enum SceneBuilder {
    @_alwaysEmitIntoClient
    public static func buildExpression<Content>(_ content: Content) -> Content where Content: Scene {
        content
    }

    public static func buildBlock<Content>(_ content: Content) -> Content where Content: Scene {
        content
    }

    //    @_disfavoredOverload
    //    @_alwaysEmitIntoClient
    //    public static func buildBlock<each Content>(_ content: repeat each Content) -> _TupleScene<repeat each Content> where repeat each Content: View {
    //        _TupleScene(repeat each content)
    //    }
}

@available(*, unavailable)
extension SceneBuilder: Swift.Sendable {}

extension SceneBuilder {
//    @_alwaysEmitIntoClient
//    public static func buildOptional(_ scene: (any Scene & _LimitedAvailabilitySceneMarker)?) -> some Scene {
//        if #available(iOS 16.1, macOS 13.0, watchOS 9.1, tvOS 16.1, *) {
//            return scene as! LimitedAvailabilityScene
//        } else {
//            return _EmptyScene()
//        }
//    }

    @available(*, unavailable, message: "if statements in a SceneBuilder can only be used with #available clauses")
    public static func buildOptional(_: (some Scene)?) {}

//    @_alwaysEmitIntoClient
//    public static func buildLimitedAvailability(_ scene: some Scene) -> any Scene & _LimitedAvailabilitySceneMarker {
//        if #available(iOS 16.1, macOS 13.0, watchOS 9.1, tvOS 16.1, *) {
//            return LimitedAvailabilityScene(scene)
//        } else {
//            fatalError("Unavailable")
//        }
//    }
}

@_marker
public protocol _LimitedAvailabilitySceneMarker {}
