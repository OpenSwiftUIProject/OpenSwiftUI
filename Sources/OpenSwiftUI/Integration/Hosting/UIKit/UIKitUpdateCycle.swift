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

package enum UIKitUpdateCycle {
    private static var observerActions: [() -> Void] = []

    private static var item: OpaquePointer?

    package static var defaultUseSetNeedsLayout: Bool = {
        let key = "UseSetNeedsLayoutForUpdates"
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: key) != nil else {
            return false
        }
        return defaults.bool(forKey: key)
    }()

    package static func addPreCommitObserver(_ action: @escaping () -> Void) {
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

    package static func addPreCommitObserverOrAsyncMain(_ action: @escaping () -> Void) {
        if _UIUpdateCycleEnabled() {
            addPreCommitObserver(action)
        } else {
            DispatchQueue.main.async(execute: action)
        }
    }

    #if DEBUG
    private static func debugItem(_ item: UnsafePointer<_UIUpdateSequenceItem>) {
        let name = String(cString: item.pointee.name)
        _ = _UIUpdateSequenceInsertItem(
            item,
            nil,
            ("OpenSwiftUIDebug" + name),
            0,
            nil
        ) { _, _, _ in
            print("[UIKitUpdateCycle] \(name) phase")
        }
    }

    package static func setupDebug() {
        guard _UIUpdateCycleEnabled() else { return }
        debugItem(_UIUpdateSequenceScheduledItem)
        debugItem(_UIUpdateSequenceHIDEventsItem)
        debugItem(_UIUpdateSequenceCADisplayLinksItem)
        debugItem(_UIUpdateSequenceAnimationsItem)
        debugItem(_UIUpdateSequenceCATransactionCommitItem)
        debugItem(_UIUpdateSequenceLowLatencyHIDEventsItem)
        debugItem(_UIUpdateSequenceLowLatencyCATransactionCommitItem)
        debugItem(_UIUpdateSequenceDoneItem)
    }
    #endif
}

#if DEBUG
public func debugUIKitUpdateCycle() {
    UIKitUpdateCycle.setupDebug()
}
#endif

#endif
