//
//  Text+Sizing.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
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
            self.storage = storage
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

// MARK: - PreferTextLayoutManagerInput

private struct PreferTextLayoutManagerInputModifier: ViewInputsModifier {
    static func _makeViewInputs(
        modifier: _GraphValue<Self>,
        inputs: inout _ViewInputs
    ) {
        inputs[PreferTextLayoutManagerInput.self] = true
    }
}

package struct PreferTextLayoutManagerInput: ViewInput {
    package static var defaultValue: Bool { false }
}
