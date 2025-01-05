//
//  ViewTransformTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing

struct ViewTransformTests {
    @Test
    func conversion() {
        #expect(MemoryLayout<CoordinateSpace>.size == 0x29)
        #expect(MemoryLayout<ViewTransform.Conversion>.size == 0x5A)
        
        let space = CoordinateSpace.named("test")
        
        do {
            let globalToSpace = ViewTransform.Conversion.globalToSpace(space)
            
            guard case let .spaceToSpace(global, space) = globalToSpace else {
                Issue.record("Expected .spaceToSpace, got \(globalToSpace)")
                return
            }
            guard case let .named(name) = space, let name = name as? String else {
                Issue.record("Expected .named, got \(space)")
                return
            }
            #expect(name == "test")
            #expect(global == .global)
        }
        
        do {
            let spaceToGlobal = ViewTransform.Conversion.spaceToGlobal(space)
            
            guard case let .spaceToSpace(space, global) = spaceToGlobal else {
                Issue.record("Expected .spaceToSpace, got \(spaceToGlobal)")
                return
            }
            guard case let .named(name) = space, let name = name as? String else {
                Issue.record("Expected .named, got \(space)")
                return
            }
            #expect(name == "test")
            #expect(global == .global)
        }
    }
}
