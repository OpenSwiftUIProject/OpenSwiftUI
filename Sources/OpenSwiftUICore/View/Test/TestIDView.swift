//
//  TestIDView.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: CC151E1A36B4405FF56CDABA5D46BF1E

import OpenGraphShims

// MARK: - TestIDView + View extension

@_spi(Testing)
extension View {
    nonisolated public func testID<ID>(_ id: ID) -> TestIDView<Self, ID> where ID: Hashable {
        TestIDView(content: self, id: id)
    }
}

// MARK: - TestIDView

@_spi(Testing)
public struct TestIDView<Content, ID>: PrimitiveView, UnaryView where Content: View, ID: Hashable {
    public var content: Content
    public var id: ID
    
    nonisolated public static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        let view = _GraphValue(IdentifiedView(view: view.value, id: nil))
        return Content.makeDebuggableView(view: view, inputs: inputs)
    }
    
    public typealias Body = Never
    
    private struct IdentifiedView: StatefulRule, AsyncAttribute, IdentifierProvider, CustomStringConvertible {
        @Attribute var view: TestIDView
        var id: ID?
        
        init(view: Attribute<TestIDView>, id: ID?) {
            self._view = view
            self.id = id
        }
        
        typealias Value = Content

        mutating func updateValue() {
            id = view.id
            value = view.content
        }
        
        func matchesIdentifier<I>(_ identifier: I) -> Bool where I: Hashable {
            (id as? I).map { $0 == identifier } == true
        }
        
        var description: String {
            if let id {
                "ID: \(id)"
            } else {
                "ID"
            }
        }
    }
}

@_spi(Testing)
@available(*, unavailable)
extension TestIDView: Sendable {}
