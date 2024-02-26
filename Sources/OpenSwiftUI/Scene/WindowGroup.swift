//
//  WindowGroup.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

@frozen
public struct LocalizedStringKey {}

public struct WindowGroup<Content>: Scene where Content: View {
    public init(id: String, @ViewBuilder content: () -> Content) {
//        self.id = id
//        self.content = content
    }

    @_disfavoredOverload
    public init(_ title: Text, id: String, @ViewBuilder content: () -> Content) {

    }
    public init(_ titleKey: LocalizedStringKey, id: String, @ViewBuilder content: () -> Content) {

    }

    @_disfavoredOverload
    public init<S>(_ title: S, id: String, @ViewBuilder content: () -> Content) where S : StringProtocol {

    }

    public init(@ViewBuilder content: () -> Content) {

    }

    @_disfavoredOverload
    public init(_ title: Text, @ViewBuilder content: () -> Content) {

    }

    public init(_ titleKey: LocalizedStringKey, @ViewBuilder content: () -> Content) {

    }

    @_disfavoredOverload
    public init<S>(_ title: S, @ViewBuilder content: () -> Content) where S : StringProtocol {

    }

    // FIXME
    public var body: some Scene {
        fatalError()
    }

    var title: Text?

//    var content: Content

    var id: String?
}
