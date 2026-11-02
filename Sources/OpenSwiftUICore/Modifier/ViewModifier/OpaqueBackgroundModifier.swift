//
//  OpaqueBackgroundModifier.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 79BADF4A1DAAA1CD480AFBF6598504A8 (SwiftUICore)

#if os(visionOS)
// MARK: - EnvironmentValues + isBackgroundOpaque

extension EnvironmentValues {
    package var isBackgroundOpaque: Bool {
        get { !isVisionEnabled || self[OpaqueBackgroundKey.self] }
        set { self[OpaqueBackgroundKey.self] = newValue }
    }
}

private struct OpaqueBackgroundKey: EnvironmentKey {
    static let defaultValue: Bool = false
}
#endif
