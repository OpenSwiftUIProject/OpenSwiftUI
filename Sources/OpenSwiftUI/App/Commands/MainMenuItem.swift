//
//  MainMenuItem.swift
//  OpenSwiftUI

import Foundation

struct MainMenuItem {
    var name: String
    var id: Identifier
    var group: [CommandAccumulator.Result]

    enum Identifier {
        case app
        case file
        case edit
        case format
        case view
        case window
        case help
        case dock
        case invalid
        case root
        case custom(UUID)
    }
}
