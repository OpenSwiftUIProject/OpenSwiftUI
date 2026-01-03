//
//  UIKitUpdateCycle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 61722010453917A59567A84BEBF44765 (SwiftUI)

#if os(iOS) || os(visionOS)
import COpenSwiftUI
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore


enum UIKitUpdateCycle {
    private static var observerActions: [() -> Void] = []

    private static var item: OpaquePointer?

    static var defaultUseSetNeedsLayout: Bool = {
        let key = "UseSetNeedsLayoutForUpdates"
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: key) != nil else {
            return false
        }
        return defaults.bool(forKey: key)
    }()

    static func addPreCommitObserver(_ action: @escaping () -> Void) {
        guard _UIUpdateCycleEnabled() else {
            return
        }
        if item == nil {
            item = OpaquePointer(
                _UIUpdateSequenceInsertItem(
                    _UIUpdateSequenceCATransactionCommitItem,
                    nil,
                    "OpenSwiftUIFlush",
                    0,
                    nil,
                ) { _, _, _ in
                    let actions = observerActions
                    guard !actions.isEmpty else { return }
                    observerActions = []
                    for action in actions {
                        Update.perform(action)
                    }
                },
            )

        }
        observerActions.append(action)
    }

    static func addPreCommitObserverOrAsyncMain(_ action: @escaping () -> Void) {
        if _UIUpdateCycleEnabled() {
            addPreCommitObserver(action)
        } else {
            DispatchQueue.main.async(execute: action)
        }
    }
}

#endif
