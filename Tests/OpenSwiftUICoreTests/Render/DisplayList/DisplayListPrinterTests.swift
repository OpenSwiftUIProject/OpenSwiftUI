//
//  DisplayListPrinterTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing

struct DisplayListPrinterTests {
    @Test
    func plain() {
        let emptyList = DisplayList()
        #expect(emptyList.description == "(display-list)")
        #expect(emptyList.minimalDescription == "(DL)")
    }
    
    @Test
    func emptyItem() {
        let item = DisplayList.Item(
            .empty,
            frame: .zero,
            identity: .init(decodedValue: 1),
            version: .init(decodedValue: 0)
        )
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
    
    func placeholderItem() {
        let item = DisplayList.Item(
            .content(.init(
                .placeholder(id: .init(decodedValue: 2)),
                seed: .init(decodedValue: 4)
            )),
            frame: .zero,
            identity: .init(decodedValue: 1),
            version: .init(decodedValue: 0)
        )
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

    @Test
    func colorItem() {
        let item = DisplayList.Item(
            .content(.init(
                .color(.white),
                seed: .init(decodedValue: 2))
            ),
            frame: .zero,
            identity: .init(decodedValue: 1),
            version: .init(decodedValue: 0)
        )
        #expect(DisplayList(item).description == """
        (display-list
          (item #:identity 1 #:version 0
            (frame (0.0 0.0; 0.0 0.0))
            (content-seed 2)
            (color #FFFFFFFF)))
        """)
        #expect(DisplayList(item).minimalDescription == """
        (DL(I:1 (c #FFFFFFFF)))
        """)
    }

    @Test
    func effectItem() {
        let colorItem = DisplayList.Item(
            .content(.init(
                .color(.white),
                seed: .init(decodedValue: 2))
            ),
            frame: .zero,
            identity: .init(decodedValue: 1),
            version: .init(decodedValue: 0)
        )
        let effectItem = DisplayList.Item(
            .effect(
                .opacity(1),
                .init(colorItem)
            ),
            frame: .zero,
            identity: .init(decodedValue: 4),
            version: .init(decodedValue: 3)
        )
        // FIXME: opacity value should be printed since it is not canonicalized here
        #expect(DisplayList(effectItem).description == """
        (display-list
          (item #:identity 4 #:version 3
            (frame (0.0 0.0; 0.0 0.0))
            (effect
              (item #:identity 1 #:version 0
                (frame (0.0 0.0; 0.0 0.0))
                (content-seed 2)
                (color #FFFFFFFF)))))
        """)
        #expect(DisplayList(effectItem).minimalDescription == """
        (DL(I:4(E(I:1 (c #FFFFFFFF)))))
        """)
    }
}
