//
//  StackTests.swift
//  OpenSwiftUICore

@testable import OpenSwiftUICore
import Testing

struct StackTests {
    @Test
    func basicOperations() {
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

    @Test
    func topProperty() {
        var stack: Stack<Int> = Stack()
        #expect(stack.top == nil)

        stack.push(1)
        #expect(stack.top == 1)

        stack.push(2)
        #expect(stack.top == 2)

        _ = stack.pop()
        #expect(stack.top == 1)

        _ = stack.pop()
        #expect(stack.top == nil)
    }

    @Test
    func sequenceIteration() {
        var stack: Stack<Int> = Stack()
        stack.push(1)
        stack.push(2)
        stack.push(3)

        var values: [Int] = []
        for value in stack {
            values.append(value)
        }

        #expect(values.count == 3)
        #expect(values[0] == 3)
        #expect(values[1] == 2)
        #expect(values[2] == 1)
    }

    @Test
    func equatable() {
        var stack1: Stack<Int> = Stack()
        var stack2: Stack<Int> = Stack()

        #expect(stack1 == stack2)

        stack1.push(1)
        #expect(stack1 != stack2)

        stack2.push(1)
        #expect(stack1 == stack2)

        stack1.push(2)
        stack2.push(2)
        #expect(stack1 == stack2)

        _ = stack1.pop()
        #expect(stack1 != stack2)
    }
}

struct Stack3Tests {
    @Test
    func basic() {
        var stack: Stack3<Int> = Stack3()
        stack.push(1)
        #expect(stack.contains(1))
        stack.push(2)
        stack.push(3)
        stack.push(4)
        #expect(!stack.contains(1))
        #expect(stack.pop() == 4)
        #expect(stack.pop() == 3)
        #expect(stack.pop() == 2)
        #expect(stack.pop() == nil)
    }
}
