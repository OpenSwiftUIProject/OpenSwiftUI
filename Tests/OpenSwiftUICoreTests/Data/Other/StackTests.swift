//
//  StackTests.swift
//  OpenSwiftUICore

@testable import OpenSwiftUICore
import Testing

struct StackTests {
    @Test
    func exmpla() {
        var stack: Stack<Int> = Stack()
        #expect(stack.isEmpty)
        
        stack.push(1)
        stack.push(2)
        #expect(stack.count == 2)
        #expect(!stack.isEmpty)

        #expect(stack.pop() == 2)
        #expect(stack.count == 1)
        #expect(!stack.isEmpty)

        #expect(stack.pop() == 1)
        #expect(stack.count == 0)
        #expect(stack.isEmpty)

        stack.push(3)
        stack.push(4)
        stack.popAll()
        #expect(stack.count == 0)
        #expect(stack.isEmpty)
        
        stack.push(5)
        stack.push(6)
        var newStack = stack.map { $0 * 2 }
        
        #expect(newStack.pop() == 12)
        #expect(newStack.count == 1)
        #expect(!newStack.isEmpty)

        #expect(newStack.pop() == 10)
        #expect(newStack.count == 0)
        #expect(newStack.isEmpty)
    }

}
