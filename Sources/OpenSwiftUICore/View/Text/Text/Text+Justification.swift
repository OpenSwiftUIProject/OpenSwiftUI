//
//  Text+Justification.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: F89CCC57FFF9CABCAC4F565338DE677C (SwiftUICore)

@_spi(Private)
@available(OpenSwiftUI_v5_0, *)
public struct TextJustification: Sendable, Equatable {
    struct Full: Equatable {
        var allLines: Bool
        var flexible: Bool
    }

    enum Storage: Equatable {
        case full(Full)
        case none
    }

    private var storage: Storage

    public static let none: TextJustification = .init(storage: .none)

    public static let full: TextJustification = .full()

    public static let stretched: TextJustification = .stretched(true)

    public static func stretched(_ flexible: Bool = true) -> TextJustification {
        .full(allLines: true, flexible: flexible)
    }

    public static func full(
        allLines: Bool = false,
        flexible: Bool = false
    ) -> TextJustification {
        .init(storage: .full(.init(allLines: allLines, flexible: flexible)))
    }
}

private struct TextJustificationKey: EnvironmentKey {
    static let defaultValue: TextJustification = .none
}

extension EnvironmentValues {
    var textJustification: TextJustification {
        get { self[TextJustificationKey.self] }
        set { self[TextJustificationKey.self] = newValue }
    }
}

@_spi(Private)
@available(OpenSwiftUI_v5_0, *)
extension View {

    @available(OpenSwiftUI_v5_0, *)
    nonisolated public func justification(_ justfication: TextJustification) -> some View {
        environment(\.textJustification, justfication)
    }
}
