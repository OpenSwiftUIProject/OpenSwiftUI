//
//  ViewRespondersKey.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Empty

package struct ViewRespondersKey: PreferenceKey {
    package static var defaultValue: [ViewResponder] { [] }
    
    package static var _includesRemovedValues: Bool { true }
    
    package static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}

// TODO

@_spi(ForOpenSwiftUIOnly)
open class ViewResponder/*: ResponderNode, CustomStringConvertible, CustomRecursiveStringConvertible*/ {
}
