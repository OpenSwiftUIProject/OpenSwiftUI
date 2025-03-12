//
//  OpenSwiftUIGlue.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: WIP

@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore
import COpenSwiftUI

#if canImport(Darwin)

public import Foundation

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

    override public final func isStatusBarHidden() -> Bool? {
        #if os(iOS)
        guard let scene = UIApplication.shared.connectedScenes.first,
              let windowScene = scene as? UIWindowScene
        else {
            return nil
        }
        return windowScene.statusBarManager?.isStatusBarHidden ?? false
        #else
        nil
        #endif
    }

    override public final func configureDefaultEnvironment(_: inout EnvironmentValues) {
    }

    override public final func makeRootView(base: AnyView, rootFocusScope: Namespace.ID) -> AnyView {
        AnyView(base.safeAreaInsets(.zero, next: nil))
    }

    override public final var systemDefaultDynamicTypeSize: DynamicTypeSize {
        #if os(iOS)
        let size = _UIApplicationDefaultContentSizeCategory()
        let dynamicSize = DynamicTypeSize(size)
        return dynamicSize ?? .large
        #else
        // TODO: macOS
        return .large
        #endif
    }

    override public final var codableAttachmentCellType: CodableAttachmentCellTypeResult {
        CodableAttachmentCellTypeResult(nil)
    }

    override public final func linkURL(_ parameters: LinkURLParameters) -> URL? {
        preconditionFailure("TODO")
    }
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension OpenSwiftUIGlue2: Sendable {}
#endif
