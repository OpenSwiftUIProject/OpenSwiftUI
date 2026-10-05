//
//  NavigationAuthority.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

import OpenAttributeGraphShims
import OpenSwiftUICore

// MARK: - NavigationAuthority [TBA]

struct NavigationAuthority {}

// MARK: - NavigationAuthority.DepthKey

extension NavigationAuthority {
    struct DepthKey: ViewInput {
        static var defaultValue: Attribute<Int> {
            Attribute(value: -1)
        }
    }
}
