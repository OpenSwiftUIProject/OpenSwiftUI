//
//  Text+Accessibility.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

import Foundation
import OpenSwiftUICore

extension Text {
    enum Accessibility {
        static let comma = Text(
            "comma",
            tableName: "Localizable",
            bundle: .openSwiftUI
        )

        static let sidebar = Text(
            "sidebar",
            tableName: "Localizable",
            bundle: .openSwiftUI
        )
    }
}
