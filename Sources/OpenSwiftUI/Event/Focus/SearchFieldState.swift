//
//  SearchFieldState.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Empty

import Foundation
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

struct SearchFieldState {
    var searchState: SearchState
    var suggestionPlacement: SearchSuggestionsPlacement.Role
    var hasSuggestions: Bool?
    var hasCustomAccessory: Bool?
    var selection: ViewIdentity?
    var text: AttributedString
    var isFocused: Bool
    var focusUpdate: SearchFocusUpdate
}

enum SearchState {
    case searching(Bool)
    case notSearching
}

struct SearchSuggestionsPlacement {
    var role: Role

    enum Role {
        case menu
        case content
    }
}

struct SearchFocusUpdate: Equatable {
    var seed: VersionSeed
    var value: Bool

    private static var nextSeed: UInt32 = 0
    static var empty: SearchFocusUpdate = .init(seed: .empty, value: false)

    init(value: Bool) {
        self.seed = VersionSeed(value: Self.nextSeed)
        self.value = value
        Self.nextSeed &+= 1
    }

    private init(seed: VersionSeed, value: Bool) {
        self.seed = seed
        self.value = value
    }

    static func == (lhs: SearchFocusUpdate, rhs: SearchFocusUpdate) -> Bool {
        lhs.seed.matches(rhs.seed)
    }
}
