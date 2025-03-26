//
//  PlatformViewRepresentable.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: A513612C07DFA438E70B9FA90719B40D (SwiftUI)

#if canImport(AppKit)
import AppKit
typealias PlatformView = NSView
typealias PlatformViewController = NSViewController
#elseif canImport(UIKit)
import UIKit
typealias PlatformView = UIView
typealias PlatformViewController = UIViewController
#else
import Foundation
typealias PlatformView = Void
typealias PlatformViewController = Void
#endif
import OpenSwiftUICore
import OpenGraphShims

// MARK: - PlatformViewRepresentable

protocol PlatformViewRepresentable: View {
    static var dynamicProperties: DynamicPropertyCache.Fields { get }

    associatedtype PlatformViewProvider

    associatedtype Coordinator

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
        preconditionFailure("TODO")
    }

    var body: Never {
        bodyError()
    }
}

extension PlatformViewRepresentable where PlatformViewProvider: PlatformView {
    static func platformView(for provider: PlatformViewProvider) -> PlatformView {
        provider
    }

    static var isViewController: Bool { false }
}

extension PlatformViewRepresentable where PlatformViewProvider: PlatformViewController {
    #if canImport(UIKit) || canImport(AppKit)
    static func platformView(for provider: PlatformViewProvider) -> PlatformView {
        provider.view
    }
    #endif

    static var isViewController: Bool { true }
}

// MARK: - RepresentableContextValues

struct RepresentableContextValues {
    static var current: RepresentableContextValues?

    var preferenceBridge: PreferenceBridge?

    var transaction: Transaction

    var environmentStorage: EnvironmentStorage

    enum EnvironmentStorage {
        case eager(EnvironmentValues)
        case lazy(Attribute<EnvironmentValues>, AnyRuleContext)
    }

    func asCurrent<V>(do: () -> V) -> V {
        let old = Self.current
        Self.current = self
        defer { Self.current = old }
        return `do`()
    }
}

// MARK: - PlatformViewRepresentableContext

struct PlatformViewRepresentableContext<Representable: PlatformViewRepresentable> {
    var values: RepresentableContextValues
    let coordinator: Representable.Coordinator

    init(
        coordinator: Representable.Coordinator,
        preferenceBridge: PreferenceBridge?,
        transaction: Transaction,
        environmentStorage: RepresentableContextValues.EnvironmentStorage
    ) {
        self.values = .init(preferenceBridge: preferenceBridge, transaction: transaction, environmentStorage: environmentStorage)
        self.coordinator = coordinator
    }
}

// MARK: - PlatformViewCoordinator

class PlatformViewCoordinator: NSObject {}
