//
//  ScrollablePreferenceKey.swift
//  OpenSwiftUICore
//
//  Status: WIP

// FIXME
struct ScrollablePreferenceKey: PreferenceKey {
    typealias Value = Void

    static var defaultValue: Void = ()

    static func reduce(value: inout Void, nextValue: () -> Void) {
        //
    }
}

extension PreferencesInputs {
    @inline(__always)
    package var requiresScrollable: Bool {
        get {
            contains(ScrollablePreferenceKey.self)
        }
        set {
            if newValue {
                add(ScrollablePreferenceKey.self)
            } else {
                remove(ScrollablePreferenceKey.self)
            }
        }
    }
}

enum ScrollTargetRole {
    // FIXME
    struct ContentKey: PreferenceKey {
        typealias Value = Void

        static var defaultValue: Void = ()

        static func reduce(value: inout Void, nextValue: () -> Void) {
            //
        }
    }
}

extension PreferencesInputs {
    @inline(__always)
    package var requiresScrollTargetRole: Bool {
        get {
            contains(ScrollTargetRole.ContentKey.self)
        }
        set {
            if newValue {
                add(ScrollTargetRole.ContentKey.self)
            } else {
                remove(ScrollTargetRole.ContentKey.self)
            }
        }
    }
}
