//
//  AppIntentExecutingLocation.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 9B087A07A580587E3766900D1DEEA5E9 (SwiftUI)

public import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - Toggle + AppIntent

@_spi(AppIntent)
@available(OpenSwiftUI_v5_0, *)
extension Toggle {
    nonisolated public init(
        isOn: Bool,
        lnAction: NSObject,
        @ViewBuilder label: () -> Label
    ) {
        self.init(isOn: isOn, lnAction: lnAction, perform: {}, label: label)
    }

    nonisolated public init(
        isOn: Bool,
        lnAction: NSObject,
        perform: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        let action = AppIntentAction(lnAction: lnAction, defaultExecutor: perform)
        self.label = label()
        appIntentAction = action
        let location = LocationBox(AppIntentExecutingLocation(value: ToggleState(isOn), action: action))
        _toggleState = Binding(value: ToggleState(isOn), location: location)
    }
}

// MARK: - AppIntentExecutingLocation

/// A location that performs an app intent action instead of storing the
/// value that a control writes.
///
/// Controls that are driven by an app intent, such as a toggle created from
/// an LNAction object, keep a fixed value and forward every write to the
/// intent. The written value and the transaction are ignored.
private struct AppIntentExecutingLocation<Value>: Location {
    var value: Value
    var action: AppIntentAction

    var wasRead: Bool {
        get { false }
        nonmutating set {}
    }

    func get() -> Value {
        value
    }

    func set(_ value: Value, transaction: Transaction) {
        action.perform()
    }

    static func == (lhs: AppIntentExecutingLocation, rhs: AppIntentExecutingLocation) -> Bool {
        compareValues(lhs.value, rhs.value) && compareValues(lhs.action, rhs.action)
    }
}
