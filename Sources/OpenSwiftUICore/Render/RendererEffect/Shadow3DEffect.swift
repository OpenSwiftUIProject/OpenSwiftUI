//
//  Shadow3DEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: C9520BDE5A7C30CCB2E95C7B085D6CF4 (SwiftUICore)

#if os(visionOS)

package import OpenAttributeGraphShims

// MARK: - platterGroundingShadowVisibility

extension EnvironmentValues {
    package var platterGroundingShadowVisibility: Visibility {
        get { self[PlatterGroundingShadowVisibilityKey.self] }
        set { self[PlatterGroundingShadowVisibilityKey.self] = newValue }
    }

    private struct PlatterGroundingShadowVisibilityKey: EnvironmentKey {
        static let defaultValue = Visibility.automatic
    }
}

extension CachedEnvironment.ID {
    package static let platterGroundingShadowVisibility: CachedEnvironment.ID = .init()
}

extension _GraphInputs {
    package var platterGroundingShadowVisibility: Attribute<Visibility> {
        mapEnvironment(id: .platterGroundingShadowVisibility) {
            $0.platterGroundingShadowVisibility
        }
    }
}

#endif
