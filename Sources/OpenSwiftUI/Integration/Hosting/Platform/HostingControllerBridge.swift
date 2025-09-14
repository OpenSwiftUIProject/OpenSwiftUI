//
//  HostingControllerBridge.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 58FE8AA2C5B9F31BD4583124328B217E (SwiftUI?)

import OpenAttributeGraphShims
import OpenSwiftUICore

//struct HostingControllerOverrides {
//    // var pushTarget: PushTarget?
//    weak var navigation: UINavigationController?
//    weak var split: UISplitViewController?
//    var hasBackItem: Bool?
//}

// MARK: - HostingControllerBridges

struct HostingControllerBridges: OptionSet {
    let rawValue: Int

    static var alwaysOnBridge: Self { .init(rawValue: 1 << 5) }
}

// MARK: - HostingControllerAllowedBehaviors

struct HostingControllerAllowedBehaviors: OptionSet {
    let rawValue: Int
}

// MARK: - EnvironmentValues.managedBridges

extension EnvironmentValues {
    private struct ManagedBridgesKey: EnvironmentKey {
        static var defaultValue: HostingControllerBridges { [] }
    }

    var managedBridges: HostingControllerBridges {
        get { self[ManagedBridgesKey.self] }
        set { self[ManagedBridgesKey.self] = newValue }
    }
}

// MARK: - EnvironmentValues.suppliedBridges

extension EnvironmentValues {
    private struct SuppliedBridgesKey: EnvironmentKey {
        static var defaultValue: HostingControllerBridges { [] }
    }

    var suppliedBridges: HostingControllerBridges {
        get { self[SuppliedBridgesKey.self] }
        set { self[SuppliedBridgesKey.self] = newValue }
    }
}


struct UpdateEnvironmentToAllowedBehaviors: EnvironmentModifier, PrimitiveViewModifier {
    static func makeEnvironment(modifier: Attribute<Self>, environment: inout EnvironmentValues) {
        // TODO
    }
}
