//
//  ParagraphTypesetting.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: D39DBD719189F2769C15C168465CE407 (SwiftUICore)

@_spi(Private)
@available(OpenSwiftUI_v5_0, *)
public struct ParagraphTypesetting: Equatable {
    package enum Storage: Hashable {
        case automatic

        case balanced
    }

    package var storage: ParagraphTypesetting.Storage

    public static let automatic: ParagraphTypesetting = .init(storage: .automatic)

    public static let balanced: ParagraphTypesetting = .init(storage: .balanced)
}

private struct ParagraphTypesettingKey: EnvironmentKey {
    static let defaultValue: ParagraphTypesetting = .automatic
}

extension EnvironmentValues {
    package var paragraphTypesetting: ParagraphTypesetting {
        get { self[ParagraphTypesettingKey.self] }
        set { self[ParagraphTypesettingKey.self] = newValue }
    }
}

@available(OpenSwiftUI_v1_0, *)
extension View {
    @_spi(Private)
    @available(OpenSwiftUI_v5_0, *)
    nonisolated public func paragraphTypesetting(
        _ typesetting: ParagraphTypesetting,
        isEnabled: Bool = true
    ) -> some View {
        transformEnvironment(\.paragraphTypesetting) {
            if isEnabled {
                $0 = typesetting
            }
        }
    }
}
