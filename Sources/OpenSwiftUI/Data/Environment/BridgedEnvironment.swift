//
//  BridgedEnvironment.swift
//  OpenSwiftUI
//
//  Status: WIP
//  ID: 005A2BB2D44F4D559B7E508DC5B95FF (SwiftUI?)

#if os(iOS)

import UIKit

struct InheritedTraitCollectionKey: EnvironmentKey {
    static var defaultValue: UITraitCollection? { nil }
}

#endif
