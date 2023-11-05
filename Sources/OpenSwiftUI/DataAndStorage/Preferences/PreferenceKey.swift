//
//  PreferenceKey.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/11.
//  Lastest Version: iOS 15.5
//  Status: Complete

/// A named value produced by a view.
///
/// A view with multiple children automatically combines its values for a given
/// preference into a single value visible to its ancestors.
public protocol PreferenceKey {
    /// The type of value produced by this preference.
    associatedtype Value

    /// The default value of the preference.
    ///
    /// Views that have no explicit value for the key produce this default
    /// value. Combining child views may remove an implicit value produced by
    /// using the default. This means that `reduce(value: &x, nextValue:
    /// {defaultValue})` shouldn't change the meaning of `x`.
    static var defaultValue: Value { get }

    /// Combines a sequence of values by modifying the previously-accumulated
    /// value with the result of a closure that provides the next value.
    ///
    /// This method receives its values in view-tree order. Conceptually, this
    /// combines the preference value from one tree with that of its next
    /// sibling.
    ///
    /// - Parameters:
    ///   - value: The value accumulated through previous calls to this method.
    ///     The implementation should modify this value.
    ///   - nextValue: A closure that returns the next value in the sequence.
    static func reduce(value: inout Value, nextValue: () -> Value)

    static var _includesRemovedValues: Bool { get }

    static var _isReadableByHost: Bool { get }
}

extension PreferenceKey where Value: ExpressibleByNilLiteral {
    public static var defaultValue: Value { Value(nilLiteral: ()) }
}

extension PreferenceKey {
    public static var _includesRemovedValues: Bool { false }

    public static var _isReadableByHost: Bool { false }
}
