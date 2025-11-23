//
//  Text+Sizing.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 22747AAF70EE5063D02F299CE90A18BE (SwiftUICore)

// MARK: - Text + Sizing

@_spi(Private)
@available(OpenSwiftUI_v5_0, *)
extension Text {
    public struct Sizing: Sendable, Equatable {
        package enum Storage: UInt8, Equatable {
            case standard

            case uniformLineHeight

            case adjustsForOversizedCharacters
        }

        package var storage: Text.Sizing.Storage

        package init(_ storage: Text.Sizing.Storage) {
            _openSwiftUIUnimplementedFailure()
        }

        public static let standard: Text.Sizing = .init(.standard)

        public static let uniformLineHeight: Text.Sizing = .init(.uniformLineHeight)

        public static let adjustsForOversizedCharacters: Text.Sizing = .init(.adjustsForOversizedCharacters)
    }
}

private struct TextSizingKey: EnvironmentKey {
    static let defaultValue: Text.Sizing = .standard
}

extension EnvironmentValues {
    package var textSizing: Text.Sizing {
        get { self[TextSizingKey.self] }
        set { self[TextSizingKey.self] = newValue }
    }
}
