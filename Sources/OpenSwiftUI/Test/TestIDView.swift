//
//  TestIDView.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP

import OpenGraphShims
import OpenSwiftUICore

struct TestIDView<Content, ID>: PrimitiveView, UnaryView {
    var content: Content
    var id: ID
    
    init(content: Content, id: ID) {
        self.content = content
        self.id = id
    }
    
    static func _makeView(view: _GraphValue<TestIDView<Content, ID>>, inputs: _ViewInputs) -> _ViewOutputs {
        // Use IdentifiedView here
        fatalError("TODO")
    }
}

// TODO
extension TestIDView {
    struct IdentifiedView {
        @Attribute
        var view: TestIDView
        var id: ID?
    }
}

extension View {
    func testID<ID: Hashable>(_ id: ID) -> some View {
        TestIDView(content: self, id: id)
    }
}
