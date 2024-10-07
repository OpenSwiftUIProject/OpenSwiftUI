//
//  SafeAreaRegions.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

/// A set of symbolic safe area regions.
@frozen
public struct SafeAreaRegions: OptionSet {
    public let rawValue: UInt
    
    @inlinable
    public init(rawValue: UInt) { self.rawValue = rawValue }
    
    /// The safe area defined by the device and containers within the
    /// user interface, including elements such as top and bottom bars.
    public static let container = SafeAreaRegions(rawValue: 1 << 0)
    
    /// The safe area matching the current extent of any software
    /// keyboard displayed over the view content.
    public static let keyboard = SafeAreaRegions(rawValue: 1 << 1)
    
    /// All safe area regions.
    public static let all = SafeAreaRegions(rawValue: .max)
}

extension SafeAreaRegions: Sendable {}
