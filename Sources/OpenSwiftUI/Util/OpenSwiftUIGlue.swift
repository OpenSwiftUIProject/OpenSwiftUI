//
//  OpenSwiftUIGlue.swift
//  OpenSwiftUI
//
//  Audited for 6.0.87
//  Status: WIP

public import Foundation
@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore
@_spiOnly
public import OpenAttributeGraphShims
import COpenSwiftUI
#if os(iOS) || os(visionOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - OpenSwiftUIGlue

@_spi(ForOpenSwiftUIOnly)
@_silgen_name("OpenSwiftUIGlueClass")
public func OpenSwiftUIGlueClass() -> CoreGlue.Type {
    OpenSwiftUIGlue.self
}

@_spi(ForOpenSwiftUIOnly)
#if canImport(ObjectiveC)
@objc(OpenSwiftUIGlue)
#endif
final public class OpenSwiftUIGlue: CoreGlue {
    override final public func maxVelocity(_ velocity: CGFloat) {
        ViewGraph.current.nextUpdate.views.maxVelocity(velocity)
    }

    override final public func nextUpdate(nextTime: Time, interval: Double, reason: UInt32?) {
        ViewGraph.current.nextUpdate.views.at(nextTime)
        ViewGraph.current.nextUpdate.views.interval(interval, reason: reason)
    }

    override final public func hasTestHost() -> Bool {
        _TestApp.host != nil
    }

    override final public func isInstantiated(graph: Graph) -> Bool {
        graph.viewGraph().isInstantiated
    }

    override final public var defaultImplicitRootType: DefaultImplicitRootTypeResult {
        DefaultImplicitRootTypeResult(_VStackLayout.self)
    }

    override final public var defaultSpacing: CGSize {
        CGSize(width: 8, height: 8)
    }

    override final public func makeDefaultLayoutComputer() -> MakeDefaultLayoutComputerResult {
        MakeDefaultLayoutComputerResult(value: ViewGraph.current.$defaultLayoutComputer)
    }

    override final public func makeDefaultLayoutComputer(graph: Graph) -> MakeDefaultLayoutComputerResult {
        MakeDefaultLayoutComputerResult(value: graph.viewGraph().$defaultLayoutComputer)
    }

    override final public func makeLayoutView<L>(
        root: _GraphValue<L>,
        inputs: _ViewInputs,
        body: (_Graph, _ViewInputs) -> _ViewListOutputs
    ) -> _ViewOutputs where L: Layout {
        L.makeLayoutView(root: root, inputs: inputs, body: body)
    }

    override final public func defaultOpenURLAction(
        env: EnvironmentValues
    ) -> OpenURLAction {
        OpenURLAction(isDefault: true) { url, completion in
            #if os(iOS) || os(visionOS)
            if let scene = env.sceneSession?.scene {
                scene.open(
                    url,
                    options: nil,
                    completionHandler: completion
                )
            } else {
                UIApplication.shared.open(
                    url,
                    options: [:],
                    completionHandler: completion
                )
            }
            #elseif os(tvOS)
            UIApplication.shared.open(
                url,
                options: [:],
                completionHandler: completion
            )
            #elseif os(macOS)
            // TBA
            NSWorkspace.shared.open(
                url,
                configuration: .init()
            ) { _, error in
                completion(error == nil)
            }
            #else
            _openSwiftUIPlatformUnimplementedWarning()
            completion(false)
            #endif
        }
    }

    override final public func defaultOpenSensitiveURLAction() -> OpenURLAction {
        OpenURLAction(isDefault: true) { url, completion in
            #if os(iOS) || os(visionOS)
            let configuration = _LSOpenConfiguration()
            configuration.isSensitive = true
            let selector = Selector(("_currentOpenApplicationEndpoint"))
            if let scene = UIApplication.shared.connectedScenes.first,
               scene.responds(to: selector),
               let endpoint = scene.perform(selector) {
                configuration.targetConnectionEndpoint = endpoint.takeUnretainedValue()
            }
            guard let workspace = LSApplicationWorkspace.default() else {
                return
            }
            workspace.open(
                url,
                configuration: configuration
            ) { _, error in
                if let error {
                    Log.internalWarning(
                        "Failed to open sensitive URL \(url). Error: \(error)"
                    )
                }
                completion(error == nil)
            }
            #else
            _openSwiftUIPlatformUnimplementedWarning()
            #endif
        }
    }

    // TODO
}

// MARK: - OpenSwiftUIGlue2

@_spi(ForOpenSwiftUIOnly)
@_silgen_name("OpenSwiftUIGlue2Class")
public func OpenSwiftUIGlue2Class() -> CoreGlue2.Type {
    OpenSwiftUIGlue2.self
}

@_spi(ForOpenSwiftUIOnly)
#if canImport(ObjectiveC)
@objc(OpenSwiftUIGlue2)
#endif
final public class OpenSwiftUIGlue2: CoreGlue2 {
    #if os(iOS) || os(visionOS)
    override public final func initializeTestApp() {
        _PerformTestingSwizzles()
    }
    #endif

    override public final func isStatusBarHidden() -> Bool? {
        #if os(iOS) || os(visionOS)
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
        #if os(iOS) || os(visionOS)
        #else
        // TODO
        #endif
    }

    override public func configureEmptyEnvironment(_ environment: inout EnvironmentValues) {
        environment.configureForPlatform(traitCollection: nil)
    }

    override public final func makeRootView(base: AnyView, rootFocusScope: Namespace.ID) -> AnyView {
        AnyView(base.safeAreaInsets(.zero, next: nil))
    }

    override public final var systemDefaultDynamicTypeSize: DynamicTypeSize {
        #if os(iOS) || os(visionOS)
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
        _openSwiftUIUnimplementedFailure()
    }

    public override func transformingEquivalentAttributes(_ attributedString: AttributedString) -> AttributedString {
        _openSwiftUIUnimplementedWarning()
        return attributedString
    }
}
