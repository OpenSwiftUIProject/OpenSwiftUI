//
//  DocumentKey.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 0F42DDF44729C152DA9EC9F6F4D00118 (SwiftUI?)

#if os(iOS) || os(visionOS)
import OpenSwiftUICore

extension EnvironmentValues {
    private struct DocumentCommandsKey: EnvironmentKey {
        static var defaultValue: PlatformItemList { .init(items: []) }
    }

    var documentCommands: PlatformItemList {
        get { self[DocumentCommandsKey.self] }
        set { self[DocumentCommandsKey.self] = newValue }
    }
}
#endif
