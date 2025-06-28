//
//  ContentPathObserver.swift
//  OpenSwiftUICore
//
//  Status: Complete

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
public struct ContentPathChanges: OptionSet {
    public var rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    package static let data: ContentPathChanges = .init(rawValue: 1 << 0)

    package static let size: ContentPathChanges = .init(rawValue: 1 << 1)

    package static let transform: ContentPathChanges = .init(rawValue: 1 << 2)
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension ContentPathChanges: Sendable {}

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
public protocol ContentPathObserver: AnyObject {
    func respondersDidChange(
        for parent: ViewResponder
    )

    func contentPathDidChange(
        for parent: ViewResponder,
        changes: ContentPathChanges,
        transform: (old: ViewTransform, new: ViewTransform),
        finished: inout Bool
    )
}

package protocol TrivialContentPathObserver: ContentPathObserver {
    func contentPathDidChange(for parent: ViewResponder)
}

extension TrivialContentPathObserver {
    package func contentPathDidChange(
        for parent: ViewResponder,
        changes: ContentPathChanges,
        transform: (old: ViewTransform, new: ViewTransform),
        finished: inout Bool
    ) {
        contentPathDidChange(for: parent)
        finished = true
    }

    package func respondersDidChange(for parent: ViewResponder) {
        contentPathDidChange(for: parent)
    }
}
