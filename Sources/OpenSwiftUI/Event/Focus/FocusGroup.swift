//
//  FocusGroup.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 843E2CF8C2FABDEAA3F932BB96663C44 (SwiftUI)

import OpenSwiftUICore

enum FocusGroupIdentifier {
    case explicit(ID)
    case inferred

    struct ID: Hashable {
        var base: Int
    }
}

extension EnvironmentValues {
    var focusGroupID: FocusGroupIdentifier? {
        get { self[FocusGroupIDKey.self] }
        set { self[FocusGroupIDKey.self] = newValue }
    }
}

private struct FocusGroupIDKey: EnvironmentKey {
    static var defaultValue: FocusGroupIdentifier?  {
        nil
    }
}
