//
//  LegacyApp.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete
//  ID: F8F4CFB3FB453F4ECC15C05B76BCD1E4

public enum __App {}

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
