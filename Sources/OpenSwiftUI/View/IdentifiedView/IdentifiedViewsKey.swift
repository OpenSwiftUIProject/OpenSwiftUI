//
//  IdentifiedViewsKey.swift
//  OpenSwiftUI
//
//  Status: Complete
//  ID: 972049776785601E5EF56C4D9DFD84DB (?)

@_spi(Private)
public import OpenSwiftUICore

// MARK: - _IdentifiedViewsKey [6.4.41]

@available(OpenSwiftUI_v1_0, *)
public struct _IdentifiedViewsKey {
    public typealias Value = _IdentifiedViewTree
    
    public static let defaultValue: _IdentifiedViewTree = .empty
    
    public static func reduce(value: inout _IdentifiedViewTree, nextValue: () -> _IdentifiedViewTree) {
        let newValue = nextValue()
        switch (value, newValue) {
            case (_, .empty):
                break
            case (.empty, _):
                value = newValue
            case let (.proxy(oldProxy), .proxy(newProxy)):
                value = .array([.proxy(oldProxy)] + [.proxy(newProxy)])
            case let (.array(oldArray), .proxy(newProxy)):
                value = .array(oldArray + [.proxy(newProxy)])
            case let (.proxy(oldProxy), .array(newArray)):
                value = .array([.proxy(oldProxy)] + newArray)
            case let (.array(oldArray), .array(newArray)):
                value = .array(oldArray + newArray)
        }
    }
}

@available(*, unavailable)
extension _IdentifiedViewsKey: Sendable {}

@_spi(Private)
@available(OpenSwiftUI_v1_0, *)
extension _IdentifiedViewsKey: HostPreferenceKey {}
