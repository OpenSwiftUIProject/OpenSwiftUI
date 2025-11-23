//
//  ScaledMetric.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 2255CA18CD70887CF5927CEB84AC06E7 (SwiftUICore)

public import Foundation

// MARK: - ScaledMetric

/// A dynamic property that scales a numeric value.
@available(OpenSwiftUI_v2_0, *)
@propertyWrapper
public struct ScaledMetric<Value>: DynamicProperty where Value: BinaryFloatingPoint {
    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    @Environment(\.pixelLength)
    private var pixelLength

    private var value: Value

    private var textStyle: Font.TextStyle

    /// Creates the scaled metric with an unscaled value and a text style to
    /// scale relative to.
    public init(wrappedValue: Value, relativeTo textStyle: Font.TextStyle) {
        self.value = wrappedValue
        self.textStyle = textStyle
    }

    /// Creates the scaled metric with an unscaled value using the default
    /// scaling.
    public init(wrappedValue: Value) {
        self.value = wrappedValue
        self.textStyle = .body
    }

    /// The value scaled based on the current environment.
    public var wrappedValue: Value {
        let scale = Value(Font.scaleFactor(textStyle: textStyle, in: dynamicTypeSize))
        return (value * scale).rounded(toMultipleOf: Value(pixelLength))
    }
}

@available(OpenSwiftUI_v2_0, *)
extension ScaledMetric: Sendable where Value: Sendable {}

// MARK: - ScaledValue

@available(OpenSwiftUI_v2_0, *)
@available(*, deprecated, message: "Use @ScaledMetric")
@propertyWrapper
public struct _ScaledValue: DynamicProperty {
    @ScaledMetric
    private var value: CGFloat

    public init(wrappedValue: CGFloat, textStyle: Font.TextStyle = .body) {
        _value = .init(wrappedValue: wrappedValue, relativeTo: textStyle)
    }

    public var wrappedValue: CGFloat {
        value
    }
}

@available(*, unavailable)
extension _ScaledValue: Sendable {}
