//
//  OpenSwiftUIGlue.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Empty

@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

#if canImport(Darwin)

@_spi(ForOpenSwiftUIOnly)
@_silgen_name("OpenSwiftUIGlueClass")
public func OpenSwiftUIGlueClass() -> CoreGlue.Type {
    OpenSwiftUIGlue.self
}

final class OpenSwiftUIGlue: CoreGlue {
    override var defaultImplicitRootType: DefaultImplicitRootTypeResult {
        DefaultImplicitRootTypeResult(_VStackLayout.self)
    }

    override func makeDefaultLayoutComputer() -> MakeDefaultLayoutComputerResult {
        MakeDefaultLayoutComputerResult(value: ViewGraph.current.$defaultLayoutComputer)
    }
}

#endif
