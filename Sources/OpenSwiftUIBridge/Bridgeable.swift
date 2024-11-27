//
//  Bridgeable.swift
//  OpenSwiftUIBridge

import OpenSwiftUI

/// A type that can be converted to and from its counterpart.
public protocol Bridgeable<Counterpart> {
    associatedtype Counterpart where Counterpart: Bridgeable, Counterpart.Counterpart == Self
    
    init(_ counterpart: Counterpart)
}

extension Bridgeable {
    public var counterpart: Self.Counterpart { .init(self) }
}
