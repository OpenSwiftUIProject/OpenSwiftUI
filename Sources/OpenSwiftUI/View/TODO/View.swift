//
//  View.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/21.
//  Lastest Version: iOS 15.5
//  Status: WIP

import Foundation

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
//@_typeEraser(AnyView)
public protocol View {
    //  static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs
    //  static func _makeViewList(view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs
    //  @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
    //  static func _viewListCount(inputs: _ViewListCountInputs) -> Int?
    associatedtype Body: View
    
    // @ViewBuilder
    var body: Self.Body { get }
}

extension Never: View {
    public var body: Never {
        fatalError()
    }
    
    public typealias Body = Never
}

extension View {
    func bodyError() -> Never {
        fatalError("body() should not be called on \(Self.self)")
    }
}
