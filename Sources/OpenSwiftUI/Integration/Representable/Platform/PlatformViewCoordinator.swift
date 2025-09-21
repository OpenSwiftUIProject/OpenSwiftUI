//
//  PlatformViewCoordinator.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import Foundation
import OpenSwiftUICore

// MARK: - PlatformViewCoordinator

#if canImport(Darwin)
@objc
#endif
class PlatformViewCoordinator: NSObject {
    var weakDispatchUpdate: (() -> Void) -> Void {
        { [weak self] update in
            guard let self else {
                update()
                return
            }
            Update.dispatchImmediately { // FIXME: reason: nil
                update()
            }
        }
    }
}
