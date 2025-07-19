//
//  ViewRendererHostProperties.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package struct ViewRendererHostProperties: OptionSet {
    package let rawValue: UInt16

    package init(rawValue: UInt16) {
        self.rawValue = rawValue
    }

    package static let rootView: ViewRendererHostProperties = .init(rawValue: 1 << 0)

    package static let environment: ViewRendererHostProperties = .init(rawValue: 1 << 1)

    package static let transform: ViewRendererHostProperties = .init(rawValue: 1 << 2)

    package static let size: ViewRendererHostProperties = .init(rawValue: 1 << 3)

    package static let safeArea: ViewRendererHostProperties = .init(rawValue: 1 << 4)

    package static let containerSize: ViewRendererHostProperties = .init(rawValue: 1 << 5)

    package static let focusStore: ViewRendererHostProperties = .init(rawValue: 1 << 6)

    package static let focusedItem: ViewRendererHostProperties = .init(rawValue: 1 << 7)

    package static let focusedValues: ViewRendererHostProperties = .init(rawValue: 1 << 8)

    package static let all: ViewRendererHostProperties = [
        .rootView, .environment, .transform,
        .size, .safeArea, .containerSize,
        .focusStore, .focusedItem, focusedValues,
    ]
}
