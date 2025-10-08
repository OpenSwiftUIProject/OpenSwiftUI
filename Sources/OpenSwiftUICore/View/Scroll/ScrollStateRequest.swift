//
//  ScrollStateRequest.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: TODO

// MARK: - ScrollStateRequest TODO
package protocol ScrollStateRequest {}

// TODO

// MARK: - UpdateScrollStateRequestKey

package struct UpdateScrollStateRequestKey: PreferenceKey {
    package typealias Value = [any ScrollStateRequest]

    package static let defaultValue: Value = []

    package static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}

extension PreferencesInputs {
    @inline(__always)
    package var requiresScrollStateRequest: Bool {
        get { contains(UpdateScrollStateRequestKey.self) }
        set {
            if newValue {
                add(UpdateScrollStateRequestKey.self)
            } else {
                remove(UpdateScrollStateRequestKey.self)
            }
        }
    }
}
