//
//  View.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/21.
//  Lastest Version: iOS 15.5
//  Status: WIP

import Foundation

@_typeEraser(AnyView)
public protocol View {
    static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs
    static func _makeViewList(view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs
    static func _viewListCount(inputs: _ViewListCountInputs) -> Int?
    associatedtype Body: View
    
    @ViewBuilder
    var body: Self.Body { get }
}

// FIXME
extension View {
    public static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        .init()
    }
    public static func _makeViewList(view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
        .init()
    }
    public static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        nil
    }
}

extension Never: View {
    public var body: Never {
        // FIXME: should be "brk #1"
        fatalError()
    }
}

extension View {
    func bodyError() -> Never {
        fatalError("body() should not be called on \(Self.self)")
    }
}
