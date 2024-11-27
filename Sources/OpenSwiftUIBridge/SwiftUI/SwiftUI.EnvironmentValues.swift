//
//  SwiftUI.EnvironmentValues.swift
//  OpenSwiftUIBridge

#if canImport(SwiftUI)
public import SwiftUI
public import OpenSwiftUI

// MARK: EnvironmentValues + Bridgeable

extension SwiftUI.EnvironmentValues: Bridgeable {
    public typealias Counterpart = OpenSwiftUI.EnvironmentValues

    public init(_ counterpart: Counterpart) {
        // FIXME
        self.init()
    }
}

extension OpenSwiftUI.EnvironmentValues: Bridgeable {
    public typealias Counterpart = SwiftUI.EnvironmentValues
    
    public init(_ counterpart: Counterpart) {
        // FIXME
        self.init()
    }
}
#endif
