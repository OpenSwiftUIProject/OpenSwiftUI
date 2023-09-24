//
//  ModifiedContent.swift
//
//
//  Created by Kyle on 2023/9/24.
//

import Foundation

@frozen
public struct ModifiedContent<Content, Modifier> {
    public typealias Body = Never
    public var content: Content
    public var modifier: Modifier
    @inlinable public init(content: Content, modifier: Modifier) {
        self.content = content
        self.modifier = modifier
    }
}

extension ModifiedContent: Equatable where Content: Equatable, Modifier: Equatable {
    public static func == (a: ModifiedContent<Content, Modifier>, b: ModifiedContent<Content, Modifier>) -> Bool {
        a.content == b.content && a.modifier == b.modifier
    }
}

// extension ModifiedContent : View where Content : View, Modifier : ViewModifier {
//  public static func _makeView(view: _GraphValue<ModifiedContent<Content, Modifier>>, inputs: _ViewInputs) -> _ViewOutputs
//  public static func _makeViewList(view: _GraphValue<ModifiedContent<Content, Modifier>>, inputs: _ViewListInputs) -> _ViewListOutputs
//  public static func _viewListCount(inputs: _ViewListCountInputs) -> Int?
//  @_Concurrency.MainActor(unsafe) public var body: ModifiedContent<Content, Modifier>.Body {
//    get
//  }
// }

// extension ModifiedContent : ViewModifier where Content : ViewModifier, Modifier : ViewModifier {
//    public static func _makeView(modifier: _GraphValue<ModifiedContent<Content, Modifier>>, inputs: _ViewInputs, body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs) -> _ViewOutputs {
//
//    }
//    public static func _makeViewList(modifier: _GraphValue<ModifiedContent<Content, Modifier>>, inputs: _ViewListInputs, body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs) -> _ViewListOutputs {
//
//    }
//    public static func _viewListCount(inputs: _ViewListCountInputs, body: (_ViewListCountInputs) -> Int?) -> Int? {
//
//    }
// }

extension ViewModifier {
    @inlinable
    public func concat<T>(_ modifier: T) -> ModifiedContent<Self, T> {
        .init(content: self, modifier: modifier)
    }
}
