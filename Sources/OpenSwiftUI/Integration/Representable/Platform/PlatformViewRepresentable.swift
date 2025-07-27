//
//  PlatformViewRepresentable.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: A513612C07DFA438E70B9FA90719B40D (SwiftUI)

#if canImport(AppKit)
import AppKit
typealias PlatformView = NSView
typealias PlatformViewController = NSViewController
typealias PlatformHostingController = NSHostingController
typealias PlatformViewResponder = NSViewResponder
#elseif canImport(UIKit)
import UIKit
typealias PlatformView = UIView
typealias PlatformViewController = UIViewController
typealias PlatformHostingController = UIHostingController
typealias PlatformViewResponder = UIViewResponder
#else
import Foundation
typealias PlatformView = NSObject
typealias PlatformViewController = NSObject
typealias PlatformHostingController = NSObject
typealias PlatformViewResponder = NSObject
#endif
import OpenSwiftUICore
import OpenGraphShims

// MARK: - PlatformViewRepresentable

protocol PlatformViewRepresentable: View {
    associatedtype PlatformViewProvider

    associatedtype Coordinator

    static var dynamicProperties: DynamicPropertyCache.Fields { get }

    func makeViewProvider(context: Context) -> PlatformViewProvider

    func updateViewProvider(_ provider: PlatformViewProvider, context: Context)

    func resetViewProvider(_ provider: PlatformViewProvider, coordinator: Coordinator, destroy: () -> Void)

    static func dismantleViewProvider(_ provider: PlatformViewProvider, coordinator: Coordinator)

    static func platformView(for provider: PlatformViewProvider) -> PlatformView

    func makeCoordinator() -> Coordinator

    func _identifiedViewTree(in provider: PlatformViewProvider) -> _IdentifiedViewTree

    func sizeThatFits(_ proposal: ProposedViewSize, provider: PlatformViewProvider, context: PlatformViewRepresentableContext<Self>) -> CGSize?

    func overrideSizeThatFits(_ size: inout CGSize, in proposedSize: _ProposedSize, platformView: PlatformViewProvider)

    func overrideLayoutTraits(_ traits: inout _LayoutTraits, for provider: PlatformViewProvider)

    static func modifyBridgedViewInputs(_ inputs: inout _ViewInputs)

    static var isViewController: Bool { get }

    static func shouldEagerlyUpdateSafeArea(_ provider: PlatformViewProvider) -> Bool

    static func layoutOptions(_ provider: PlatformViewProvider) -> LayoutOptions

    typealias Context = PlatformViewRepresentableContext<Self>

    typealias LayoutOptions = _PlatformViewRepresentableLayoutOptions
}

// MARK: - PlatformViewRepresentable + Extension [WIP]

extension PlatformViewRepresentable {
    static var dynamicProperties: DynamicPropertyCache.Fields {
        DynamicPropertyCache.fields(of: Self.self)
    }

    nonisolated static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        // TODO
        _openSwiftUIUnimplementedFailure()
    }

    var body: Never {
        bodyError()
    }
}

#if canImport(UIKit) || canImport(AppKit)

extension PlatformViewRepresentable where PlatformViewProvider: PlatformView {
    static func platformView(for provider: PlatformViewProvider) -> PlatformView {
        provider
    }

    static var isViewController: Bool { false }
}

extension PlatformViewRepresentable where PlatformViewProvider: PlatformViewController {
    static func platformView(for provider: PlatformViewProvider) -> PlatformView {
        provider.view
    }

    static var isViewController: Bool { true }
}

#endif
