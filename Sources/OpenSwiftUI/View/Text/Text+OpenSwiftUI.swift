//
//  Text+OpenSwiftUI.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 7CAAF8CB17093C835B3EA3980BA79FD8 (SwiftUI)

import Foundation

private class OpenSwiftUIClass: NSObject {}

extension Bundle {
    static var openSwiftUI: Bundle {
        Bundle(for: OpenSwiftUIClass.self)
    }
}
