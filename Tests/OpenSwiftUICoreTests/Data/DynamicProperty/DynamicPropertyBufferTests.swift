//
//  DynamicPropertyBufferTests.swift
//  OpenSwiftUICoreTests
//
//  Status: Created by GitHub Copilot with Claude Sonnet 4.5

@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore
@testable import OpenSwiftUICore
import Testing

struct DynamicPropertyBufferTests {

    // MARK: - Test Helpers

    private struct TestProperty: DynamicProperty {
        var value: Int
    }

    private struct TestBox: DynamicPropertyBox {
        typealias Property = TestProperty
        var value: Int
        var updateCount: Int = 0

        mutating func destroy() {}

        mutating func reset() {
            updateCount = 0
        }

        mutating func update(property: inout TestProperty, phase: _GraphInputs.Phase) -> Bool {
            updateCount += 1
            let changed = property.value != value
            property.value = value
            return changed
        }

        func getState<T>(type: T.Type) -> Binding<T>? {
            nil
        }
    }

    private struct StateProperty: DynamicProperty {
        var text: String
    }

    private struct StateBox: DynamicPropertyBox {
        typealias Property = StateProperty
        var binding: Binding<String>

        mutating func destroy() {}
        mutating func reset() {}

        mutating func update(property: inout StateProperty, phase: _GraphInputs.Phase) -> Bool {
            false
        }

        func getState<T>(type: T.Type) -> Binding<T>? {
            if T.self == String.self {
                return binding as? Binding<T>
            }
            return nil
        }
    }

    private struct PhaseAwareBox: DynamicPropertyBox {
        typealias Property = TestProperty
        var insertedValue: Int
        var removedValue: Int

        mutating func destroy() {}
        mutating func reset() {}

        mutating func update(property: inout TestProperty, phase: _GraphInputs.Phase) -> Bool {
            let newValue = phase.isBeingRemoved ? removedValue : insertedValue
            let changed = property.value != newValue
            property.value = newValue
            return changed
        }

        func getState<T>(type: T.Type) -> Binding<T>? {
            nil
        }
    }

    // MARK: - Initialization Tests

    @Test
    func emptyBuffer() {
        let buffer = _DynamicPropertyBuffer()
        defer { buffer.destroy() }

        #expect(buffer.isEmpty == true)
    }

    // MARK: - Append Tests

    @Test
    func appendSingleBox() {
        var buffer = _DynamicPropertyBuffer()
        defer { buffer.destroy() }

        let box = TestBox(value: 42)
        buffer.append(box, fieldOffset: 0)

        #expect(buffer.isEmpty == false)
    }

    @Test
    func appendMultipleBoxes() {
        var buffer = _DynamicPropertyBuffer()
        defer { buffer.destroy() }

        buffer.append(TestBox(value: 1), fieldOffset: 0)
        buffer.append(TestBox(value: 2), fieldOffset: 8)
        buffer.append(TestBox(value: 3), fieldOffset: 16)

        #expect(buffer.isEmpty == false)
    }

    // MARK: - Update Tests

    @Test
    func updateWithNoChanges() {
        var buffer = _DynamicPropertyBuffer()
        defer { buffer.destroy() }

        buffer.append(TestBox(value: 42), fieldOffset: 0)

        var container = TestProperty(value: 42)
        let changed = withUnsafeMutablePointer(to: &container) { pointer in
            buffer.update(container: UnsafeMutableRawPointer(pointer), phase: .init())
        }

        #expect(changed == false)
    }

    @Test
    func updateWithChanges() {
        var buffer = _DynamicPropertyBuffer()
        defer { buffer.destroy() }

        buffer.append(TestBox(value: 100), fieldOffset: 0)

        var container = TestProperty(value: 42)
        let changed = withUnsafeMutablePointer(to: &container) { pointer in
            buffer.update(container: UnsafeMutableRawPointer(pointer), phase: .init())
        }

        #expect(changed == true)
        #expect(container.value == 100)
    }

    @Test
    func updateMultipleBoxes() {
        var buffer = _DynamicPropertyBuffer()
        defer { buffer.destroy() }

        struct TestContainer {
            var value1: TestProperty = TestProperty(value: 0)
            var value2: TestProperty = TestProperty(value: 0)
            var value3: TestProperty = TestProperty(value: 0)
        }

        buffer.append(TestBox(value: 10), fieldOffset: 0)
        buffer.append(TestBox(value: 20), fieldOffset: MemoryLayout<TestProperty>.size)
        buffer.append(TestBox(value: 30), fieldOffset: MemoryLayout<TestProperty>.size * 2)

        var container = TestContainer()
        let changed = withUnsafeMutablePointer(to: &container) { pointer in
            buffer.update(container: UnsafeMutableRawPointer(pointer), phase: .init())
        }

        #expect(changed == true)
        #expect(container.value1.value == 10)
        #expect(container.value2.value == 20)
        #expect(container.value3.value == 30)
    }

    @Test
    func updateWithDifferentPhases() {
        var buffer = _DynamicPropertyBuffer()
        defer { buffer.destroy() }

        buffer.append(PhaseAwareBox(insertedValue: 100, removedValue: 200), fieldOffset: 0)

        var container = TestProperty(value: 0)

        let insertedPhase = _GraphInputs.Phase()
        let changed1 = withUnsafeMutablePointer(to: &container) { pointer in
            buffer.update(container: UnsafeMutableRawPointer(pointer), phase: insertedPhase)
        }
        #expect(changed1 == true)
        #expect(container.value == 100)

        var removedPhase = _GraphInputs.Phase()
        removedPhase.isBeingRemoved = true
        let changed2 = withUnsafeMutablePointer(to: &container) { pointer in
            buffer.update(container: UnsafeMutableRawPointer(pointer), phase: removedPhase)
        }
        #expect(changed2 == true)
        #expect(container.value == 200)
    }

    // MARK: - Reset Tests

    @Test
    func resetBuffer() {
        var buffer = _DynamicPropertyBuffer()
        defer { buffer.destroy() }

        buffer.append(TestBox(value: 42, updateCount: 5), fieldOffset: 0)

        buffer.reset()

        #expect(buffer.isEmpty == false)
    }

    // MARK: - GetState Tests

    @Test
    func getStateNotFound() {
        var buffer = _DynamicPropertyBuffer()
        defer { buffer.destroy() }

        buffer.append(TestBox(value: 42), fieldOffset: 0)

        let state = buffer.getState(type: String.self)

        #expect(state == nil)
    }

    @Test
    func getStateFound() {
        var buffer = _DynamicPropertyBuffer()
        defer { buffer.destroy() }

        var testValue = "test"
        let binding = Binding(get: { testValue }, set: { testValue = $0 })

        buffer.append(StateBox(binding: binding), fieldOffset: 0)

        let state = buffer.getState(type: String.self)

        #expect(state != nil)
        #expect(state?.wrappedValue == "test")
    }

    @Test
    func getStateFromMultipleBoxes() {
        var buffer = _DynamicPropertyBuffer()
        defer { buffer.destroy() }

        buffer.append(TestBox(value: 42), fieldOffset: 0)

        var testValue = "found"
        let binding = Binding(get: { testValue }, set: { testValue = $0 })
        buffer.append(StateBox(binding: binding), fieldOffset: 8)

        let state = buffer.getState(type: String.self)

        #expect(state != nil)
        #expect(state?.wrappedValue == "found")
    }

    // MARK: - ApplyChanged Tests

    @Test
    func applyChangedWithNoChanges() {
        var buffer = _DynamicPropertyBuffer()
        defer { buffer.destroy() }

        buffer.append(TestBox(value: 42), fieldOffset: 0)

        var container = TestProperty(value: 42)
        _ = withUnsafeMutablePointer(to: &container) { pointer in
            buffer.update(container: UnsafeMutableRawPointer(pointer), phase: .init())
        }

        var calledOffsets: [Int] = []
        buffer.applyChanged { offset in
            calledOffsets.append(offset)
        }

        #expect(calledOffsets.isEmpty)
    }

    @Test
    func applyChangedWithChanges() {
        var buffer = _DynamicPropertyBuffer()
        defer { buffer.destroy() }

        struct TestContainer {
            var value1: TestProperty = TestProperty(value: 0)
            var value2: TestProperty = TestProperty(value: 20)
            var value3: TestProperty = TestProperty(value: 0)
        }

        buffer.append(TestBox(value: 10), fieldOffset: 0)
        buffer.append(TestBox(value: 20), fieldOffset: MemoryLayout<TestProperty>.size)
        buffer.append(TestBox(value: 30), fieldOffset: MemoryLayout<TestProperty>.size * 2)

        var container = TestContainer()
        _ = withUnsafeMutablePointer(to: &container) { pointer in
            buffer.update(container: UnsafeMutableRawPointer(pointer), phase: .init())
        }

        var calledOffsets: [Int] = []
        buffer.applyChanged { offset in
            calledOffsets.append(offset)
        }

        #expect(calledOffsets.count == 2)
        #expect(calledOffsets.contains(0))
        #expect(calledOffsets.contains(MemoryLayout<TestProperty>.size * 2))
    }

    // MARK: - Destroy Tests

    @Test
    func destroyEmptyBuffer() {
        let buffer = _DynamicPropertyBuffer()
        buffer.destroy()
    }

    @Test
    func destroyBufferWithBoxes() {
        var buffer = _DynamicPropertyBuffer()

        buffer.append(TestBox(value: 1), fieldOffset: 0)
        buffer.append(TestBox(value: 2), fieldOffset: 8)

        buffer.destroy()
    }

    @Test
    func destroyWithDeinitTracking() async throws {
        final class DeinitBox: DynamicPropertyBox {
            typealias Property = TestProperty
            let deinitBlock: () -> Void

            init(deinitBlock: @escaping () -> Void) {
                self.deinitBlock = deinitBlock
            }

            deinit {
                deinitBlock()
            }

            func destroy() {}
            func reset() {}
            func update(property: inout TestProperty, phase: _GraphInputs.Phase) -> Bool { false }
            func getState<T>(type: T.Type) -> Binding<T>? { nil }
        }

        await confirmation { confirm in
            var buffer = _DynamicPropertyBuffer()
            let box = DeinitBox { confirm() }
            buffer.append(box, fieldOffset: 0)
            buffer.destroy()
        }
    }
}
