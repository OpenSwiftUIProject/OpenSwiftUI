//
//  AnyView.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/1.
//  Lastest Version: iOS 15.5
//  Status: WIP
//  ID: A96961F3546506F21D8995C6092F15B5

@frozen
public struct AnyView : PrimitiveView {
    var storage: AnyViewStorageBase
    // WIP
    public init<V>(_ view: V) where V : View {
        storage = .init(id: nil)
    }

    @_alwaysEmitIntoClient
    public init<V>(erasing view: V) where V : View {
        self.init(view)
    }

    // WIP
    public init?(_fromValue value: Any) {
        return nil
    }
//  public static func _makeView(view: _GraphValue<SwiftUI.AnyView>, inputs: _ViewInputs) -> _ViewOutputs
//  public static func _makeViewList(view: _GraphValue<AnyView>, inputs: _ViewListInputs) -> _ViewListOutputs

    // WIP
    init<V: View>(_ view: V, id: UniqueID?) {
        storage = .init(id: nil)
    }
}

@usableFromInline
class AnyViewStorageBase {
    /*@objc*/
    @usableFromInline
    deinit {

    }

    let id : UniqueID?

    init(id: UniqueID?) {
        self.id = id
    }
}
