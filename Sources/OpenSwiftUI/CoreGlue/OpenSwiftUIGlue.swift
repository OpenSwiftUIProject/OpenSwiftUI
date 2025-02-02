//
//  OpenSwiftUIGlue.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Empty

@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

#if canImport(Darwin)

@_cdecl("OpenSwiftUIGlueClass")
func OpenSwiftUIGlueClass() -> CoreGlue.Type {
    OpenSwiftUIGlue.self
}

final class OpenSwiftUIGlue: CoreGlue {
    override func makeDefaultLayoutComputer() -> MakeDefaultLayoutComputerResult {
        MakeDefaultLayoutComputerResult(value: ViewGraph.current.$defaultLayoutComputer)
    }
}

#endif
