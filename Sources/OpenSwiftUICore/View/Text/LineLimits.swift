//
//  LineLimits.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 32CC33FA2019BEDFCE31FB4066945274 (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - View + Line Limits

@available(OpenSwiftUI_v1_0, *)
extension View {
    @inlinable
    nonisolated public func lineLimit(_ number: Int?) -> some View {
        environment(\.lineLimit, number)
    }

    @available(OpenSwiftUI_v4_0, *)
    nonisolated public func lineLimit(_ limit: PartialRangeFrom<Int>) -> some View {
        modifier(
            LineLimitModifier(
                lowerLimit: limit.lowerBound,
                upperLimit: nil
            )
        )
    }

    @available(OpenSwiftUI_v4_0, *)
    nonisolated public func lineLimit(_ limit: PartialRangeThrough<Int>) -> some View {
        modifier(
            LineLimitModifier(
                lowerLimit: nil,
                upperLimit: limit.upperBound
            )
        )
    }

    @available(OpenSwiftUI_v4_0, *)
    nonisolated public func lineLimit(_ limit: ClosedRange<Int>) -> some View {
        modifier(
            LineLimitModifier(
                lowerLimit: limit.lowerBound,
                upperLimit: limit.upperBound
            )
        )
    }

    @available(OpenSwiftUI_v4_0, *)
    nonisolated public func lineLimit(_ limit: Int, reservesSpace: Bool) -> some View {
        modifier(
            LineLimitModifier(
                lowerLimit: reservesSpace ? limit : nil,
                upperLimit: limit
            )
        )
    }
}

// MARK: - LineLimitModifier

struct LineLimitModifier: ViewModifier, PrimitiveViewModifier, EnvironmentModifier {
    var lowerLimit: Int?
    var upperLimit: Int?

    static func makeEnvironment(
        modifier: Attribute<LineLimitModifier>,
        environment: inout EnvironmentValues
    ) {
        environment.lineLimit = modifier.value.upperLimit
        environment.lowerLineLimit = modifier.value.lowerLimit
    }
}

// MARK: - EnvironmentValues + Line Limits

@available(OpenSwiftUI_v1_0, *)
extension EnvironmentValues {
    private struct LowerLineLimitKey: EnvironmentKey {
        static var defaultValue: Int? { nil }
    }

    private struct LineLimitKey: EnvironmentKey {
        static var defaultValue: Int? { nil }
    }

    public var lineLimit: Int? {
        get { self[LineLimitKey.self] }
        set { self[LineLimitKey.self] = newValue }
    }

    package var lowerLineLimit: Int? {
        get { self[LowerLineLimitKey.self] }
        set { self[LowerLineLimitKey.self] = newValue }
    }
}
