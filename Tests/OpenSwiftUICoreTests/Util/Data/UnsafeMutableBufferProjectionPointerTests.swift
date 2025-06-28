//
//  ObjectCacheTests.swift
//  OpenSwiftUICoreTests

import Testing
import OpenSwiftUICore

// MARK: - Test Types

private struct TestScene {
    var x: Int
    var y: Double
    var z: String
}

// MARK: - UnsafeMutableBufferProjectionPointerTests

struct UnsafeMutableBufferProjectionPointerTests {
    
    @Test
    func emptyInitialization() {
        let pointer: UnsafeMutableBufferProjectionPointer<TestScene, Int> = UnsafeMutableBufferProjectionPointer()
        
        #expect(pointer.startIndex == 0)
        #expect(pointer.endIndex == 0)
        #expect(pointer.isEmpty)
    }
    
    @Test
    func directPointerInitialization() {
        let buffer = UnsafeMutableBufferPointer<Int>.allocate(capacity: 3)
        defer { buffer.deallocate() }
        
        buffer[0] = 10
        buffer[1] = 20
        buffer[2] = 30
        
        let pointer = UnsafeMutableBufferProjectionPointer<TestScene, Int>(start: buffer.baseAddress!, count: 3)

        #expect(pointer.startIndex == 0)
        #expect(pointer.endIndex == 3)
        #expect(pointer.count == 3)
        #expect(pointer[0] == 10)
        #expect(pointer[1] == 20)
        #expect(pointer[2] == 30)
    }
    
    @Test
    func keyPathProjectionWithEmptyBuffer() {
        let buffer = UnsafeMutableBufferPointer<TestScene>.allocate(capacity: 0)
        defer { buffer.deallocate() }
        
        let pointer = UnsafeMutableBufferProjectionPointer(buffer, \TestScene.x)
        
        #expect(pointer.startIndex == 0)
        #expect(pointer.endIndex == 0)
        #expect(pointer.isEmpty)
    }

    @Test
    func mutableAccess() {
        let buffer = UnsafeMutableBufferPointer<TestScene>.allocate(capacity: 1)
        defer { buffer.deallocate() }
        
        buffer[0] = TestScene(x: 42, y: 3.14, z: "test")
        
        let xProjection = UnsafeMutableBufferProjectionPointer(buffer, \TestScene.x)
        
        xProjection[0] = 999
        
        #expect(buffer[0].x == 999)
        #expect(xProjection[0] == 999)

        let yProjection = UnsafeMutableBufferProjectionPointer(buffer, \TestScene.y)
        #expect(yProjection[0] == 3.14)

        let zProjection = UnsafeMutableBufferProjectionPointer(buffer, \TestScene.z)
        #expect(zProjection[0] == "test")
    }


    @Test
    func bufferProjection() {
        var scenes = [
            TestScene(x: 1, y: 1.0, z: "1"),
            TestScene(x: 2, y: 2.0, z: "2"),
        ]
        scenes.withUnsafeMutableBufferPointer { base in
            let xProjection = UnsafeMutableBufferProjectionPointer(base, \TestScene.x)
            #expect(xProjection[0] == 1)
            #expect(xProjection[1] == 2)

            let yProjection = UnsafeMutableBufferProjectionPointer(base, \TestScene.y)
            #expect(yProjection[0] == 1.0)
            #expect(yProjection[1] == 2.0)

            let zProjection = UnsafeMutableBufferProjectionPointer(base, \TestScene.z)
            #expect(zProjection[0] == "1")
            #expect(zProjection[1] == "2")

            xProjection[1] = 3
        }

        #expect(scenes[1].x == 3)
    }
}
