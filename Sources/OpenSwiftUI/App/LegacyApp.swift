//
//  LegacyApp.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: F8F4CFB3FB453F4ECC15C05B76BCD1E4 (SwiftUI)

public enum __App {}

@available(*, unavailable)
extension __App: Sendable {}

extension __App {
    public static func run(_ rootView: some View) -> Never {
        runApp(ShoeboxAdaptor(rootView: rootView))
    }
}

extension __App {
    private struct ShoeboxAdaptor<V: View>: App {
        var rootView: V
        
        init() {
            preconditionFailure("Not a standalone App.")
        }
        
        init(rootView: V) {
            self.rootView = rootView
        }
        
        var body: some Scene {
            WindowGroup { rootView }
        }
    }
}
