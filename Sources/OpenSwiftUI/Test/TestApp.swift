//
//  TestApp.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP
//  ID: A519B5B95CA8FF4E3445832668F0B2D2

public struct _TestApp {
    public init() {
        preconditionFailure("TODO")
    }
    public func run() -> Never {
        preconditionFailure("TODO")
    }
}

extension _TestApp {
    struct RootView: View {
        @State
        var state: StateType
        
        init() {
            preconditionFailure("TODO")
        }
        
        var body: some View {
            state.testView
            preconditionFailure("TODO")
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
