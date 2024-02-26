//
//  TestIDView.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

internal import OpenGraphShims

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
