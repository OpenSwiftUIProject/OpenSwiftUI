//
//  PlatformViewRepresentable.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

#if os(macOS)
import AppKit
typealias PlatformView = NSView
#elseif os(iOS)
import UIKit
typealias PlatformView = UIView
#else
import Foundation
typealias PlatformView = Void
#endif

import OpenSwiftUICore

protocol PlatformViewRepresentable: View {
    associatedtype PlatformViewProvider
    associatedtype Coordinator
    
    static var dynamicProperties: DynamicPropertyCache.Fields { get }
    func makeViewProvider(context: PlatformViewRepresentableContext<Self>) -> PlatformViewProvider
    func updateViewProvider(_ provider: PlatformViewProvider, context: PlatformViewRepresentableContext<Self>)
    func resetViewProvider(_ provider: PlatformViewProvider, coordinator: Coordinator, destroy: () -> Void)
    static func dismantleViewProvider(_: PlatformViewProvider, coordinator: Coordinator)
    static func platformView(for: PlatformViewProvider) -> PlatformView
    func makeCoordinator() -> Coordinator
    // func _identifiedViewTree(in: PlatformViewProvider) -> _IdentifiedViewTree
    func overrideSizeThatFits(_ size: inout CGSize, in: _ProposedSize, platformView: PlatformViewProvider)
    // func overrideLayoutTraits(_ traits: inout _LayoutTraits, for provider: PlatformViewProvider)
    
    static func modifyBridgedViewInputs(_ inputs: inout _ViewInputs)
    static var isViewController: Bool { get }
    // static var safeAreaMode: _PlatformViewRepresentable_SafeAreaMode { get }
}

// MARK: - PlatformViewRepresentableValues

struct PlatformViewRepresentableValues {
    var preferenceBridge: PreferenceBridge
    var transaction: Transaction
    var environment: EnvironmentValues
    
    static var current: PlatformViewRepresentableValues?
    
    func asCurrent<V>(do: () -> V) -> V {
        let old = PlatformViewRepresentableValues.current
        PlatformViewRepresentableValues.current = self
        defer { PlatformViewRepresentableValues.current = old }
        return `do`()
    }
}

struct PlatformViewRepresentableContext<RepresentableType: PlatformViewRepresentable> {
    var values: PlatformViewRepresentableValues
    let coordinator: RepresentableType.Coordinator
}


// TODO
class PlatformViewCoordinator: NSObject {
//    var weakDispatchUpdate: (()->Void) -> Void
    
    override init() {
        super.init()
    }
}
