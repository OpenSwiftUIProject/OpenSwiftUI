//
//  TestApp.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2024/1/9.
//  Lastest Version: iOS 15.5
//  Status: WIP
//  ID: A519B5B95CA8FF4E3445832668F0B2D2

public struct _TestApp {
    public init() {
        fatalError("TODO")
    }
    public func run() -> Never {
        fatalError("TODO")
    }
}

extension _TestApp {
    struct RootView: View {
        @State
        var state: StateType
        
        init() {
            fatalError("TODO")
        }
        
        var body: some View {
            state.testView
            fatalError("TODO")
        }
    }
    
}

extension _TestApp.RootView {
    struct StateType {
        var id: Int
        var testView: AnyView
        
        mutating func setTestView<V: View>(_ view: V) {
            id += 1
            testView = AnyView(view.testID(id))
        }
    }
}
