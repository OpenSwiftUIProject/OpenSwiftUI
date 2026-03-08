//
//  NavigationTitle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

@_spi(Private)
package import OpenSwiftUICore

// MARK: - NavigationTitleKey

package struct NavigationTitleKey: HostPreferenceKey {
    package static func reduce(value: inout NavigationTitleStorage?, nextValue: () -> NavigationTitleStorage?) {
        guard value != nil else {
            value = nextValue()
            return
        }
        value!.reduce(onto: nextValue())
    }
}

// MARK: - NavigationSubtitleKey

package struct NavigationSubtitleKey: HostPreferenceKey {
    package static var defaultValue: String? { nil }

    package static func reduce(value: inout Text?, nextValue: () -> Text?) {
        value = value ?? nextValue()
    }
}

// MARK: - NavigationTitleStorage

package struct NavigationTitleStorage: Equatable {
    package var title: Text?
    package var transaction: Transaction?
    package var titleMode: ToolbarTitleDisplayMode?
    package var iconView: AnyView?
    package var titleVisibility: Visibility?

    package mutating func reduce(onto: @autoclosure () -> NavigationTitleStorage?) {
        guard title == nil || titleMode == nil || iconView == nil else {
            return
        }
        guard let other = onto() else {
            return
        }
        title = title ?? other.title
        titleMode = titleMode ?? other.titleMode
        iconView = iconView ?? other.iconView
        titleVisibility = titleVisibility ?? other.titleVisibility
    }

    package static func ==(lhs: NavigationTitleStorage, rhs: NavigationTitleStorage) -> Bool {
        lhs.title == rhs.title && lhs.titleMode == rhs.titleMode
    }
}
