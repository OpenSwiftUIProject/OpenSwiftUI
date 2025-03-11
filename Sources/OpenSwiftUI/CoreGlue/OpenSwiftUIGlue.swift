//
//  OpenSwiftUIGlue.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Empty

@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore
import COpenSwiftUI

#if canImport(Darwin)

import Foundation

@_spi(ForOpenSwiftUIOnly)
@_silgen_name("OpenSwiftUIGlueClass")
public func OpenSwiftUIGlueClass() -> CoreGlue.Type {
    OpenSwiftUIGlue.self
}

@_spi(ForOpenSwiftUIOnly)
@objc(OpenSwiftUIGlue)
final public class OpenSwiftUIGlue: CoreGlue {
    override final public var defaultImplicitRootType: DefaultImplicitRootTypeResult {
        DefaultImplicitRootTypeResult(_VStackLayout.self)
    }

    override final public func makeDefaultLayoutComputer() -> MakeDefaultLayoutComputerResult {
        MakeDefaultLayoutComputerResult(value: ViewGraph.current.$defaultLayoutComputer)
    }
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension OpenSwiftUIGlue: Sendable {}

@_spi(ForOpenSwiftUIOnly)
@_silgen_name("OpenSwiftUIGlue2Class")
public func OpenSwiftUIGlue2Class() -> CoreGlue2.Type {
    OpenSwiftUIGlue2.self
}

@_spi(ForOpenSwiftUIOnly)
@objc(OpenSwiftUIGlue2)
final public class OpenSwiftUIGlue2: CoreGlue2 {
    #if os(iOS)
    override public final func initializeTestApp() {
        _PerformTestingSwizzles()
    }
    #endif

    override public final func configureDefaultEnvironment(_: inout EnvironmentValues) {
    }
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension OpenSwiftUIGlue2: Sendable {}
#endif
