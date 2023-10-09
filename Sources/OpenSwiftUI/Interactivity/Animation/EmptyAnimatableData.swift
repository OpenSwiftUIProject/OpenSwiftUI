//
//  EmptyAnimatableData.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/9.
//  Lastest Version: iOS 15.5
//  Status: Complete

@frozen
public struct EmptyAnimatableData: VectorArithmetic {
    @inlinable
    public init() {}
    
    @inlinable
    public static var zero: EmptyAnimatableData { .init() }
    
    @inlinable
    public static func += (_: inout EmptyAnimatableData, _: EmptyAnimatableData) {}
    
    @inlinable
    public static func -= (_: inout EmptyAnimatableData, _: EmptyAnimatableData) {}
    
    @inlinable
    public static func + (_: EmptyAnimatableData, _: EmptyAnimatableData) -> EmptyAnimatableData { .zero }

    @inlinable
    public static func - (_: EmptyAnimatableData, _: EmptyAnimatableData) -> EmptyAnimatableData { .zero }

    @inlinable
    public mutating func scale(by _: Double) {}
    
    @inlinable
    public var magnitudeSquared: Double { 0 }

    public static func == (_: EmptyAnimatableData, _: EmptyAnimatableData) -> Bool { true }
}
