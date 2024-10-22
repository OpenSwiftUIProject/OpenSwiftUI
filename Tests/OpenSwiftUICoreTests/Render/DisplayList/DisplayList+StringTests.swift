//
//  DisplayList+StringTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing

struct DisplayList_StringTests {
    @Test
    func plain() {
        let emptyList = DisplayList()
        #expect(emptyList.description == "(display-list)")
        #expect(emptyList.minimalDescription == "(DL)")
    }
    
    @Test
    func emptyItem() {
        let item = DisplayList.Item(.empty, frame: .zero, identity: .init(decodedValue: 1), version: .init(decodedValue: 0))
        let d = item.description
        print(d)
        
        #expect(item.description == """
        (display-list-item
          (item #:identity 1 #:version 0
            (frame (0.0 0.0; 0.0 0.0))))
        """)
        
        let list = DisplayList(item)
        #expect(list.description == "(display-list)")
        #expect(list.minimalDescription == "(DL)")
        
        let list2 = DisplayList([item])
        #expect(list2.description == """
        (display-list
          (item #:identity 1 #:version 0
            (frame (0.0 0.0; 0.0 0.0))))
        """)
        #expect(list2.minimalDescription == "(DL(I:1))")
    }
    
    func placeholdItem() {
        let item = DisplayList.Item(.content(.init(.placeholder(id: .init(decodedValue: 2)), seed: .init(decodedValue: 4))), frame: .zero, identity: .init(decodedValue: 1), version: .init(decodedValue: 0))
        let expectedDescription = """
        (display-list
          (item #:identity 1 #:version 0 #:views true
            (frame (0.0 0.0; 0.0 0.0))
            (content-seed 4)
            (placeholder #2)))
        """
        
        let expectedMinimalDescription = """
        (DL(I:1 @#2))
        """
        
        
        let list = DisplayList(item)
        #expect(list.description == expectedDescription)
        #expect(list.minimalDescription == expectedMinimalDescription)
        
        let list2 = DisplayList([item])
        #expect(list2.description == expectedDescription)
        #expect(list2.minimalDescription == expectedMinimalDescription)
    }
    
}
