//
//  FocusNavigator.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

#if os(macOS)
import OpenSwiftUICore

struct FocusNavigator {
    weak var bridge: FocusBridge?

    // MARK: - Navigation [TBA]

    func defaultFocusItem(for responder: any BaseFocusResponder) -> FocusItem? {
        _openSwiftUIUnimplementedFailure()
    }
}
#endif
