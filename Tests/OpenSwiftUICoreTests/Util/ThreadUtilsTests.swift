//
//  ThreadUtilsTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing

// MARK: - ThreadSpecificTests

struct ThreadSpecificTests {
    static let defaultValue: Int = 1
    static let box = ThreadSpecific(defaultValue)
    
    @Test
    func value() async throws {
        let box = ThreadSpecificTests.box
        #expect(box.value == ThreadSpecificTests.defaultValue)
        try await withThrowingTaskGroup(of: Int.self) { group in
            group.addTask {
                await Task.detached {
                    box.value = 3
                    #expect(box.value == 3)
                    return box.value
                }.value
            }
            group.addTask {
                await Task.detached {
                    box.value = 4
                    #expect(box.value == 4)
                    return box.value
                }.value
            }
            let result = try await group.reduce(0, +)
            #expect(result == 7)
            await MainActor.run {
                #expect(box.value == ThreadSpecificTests.defaultValue)
            }
        }
    }
}

// MARK: - AtomicBoxTests

struct AtomicBoxTests {
    @Test
    func expressibleByNilLiteral() {
        let box: AtomicBox<Int?> = AtomicBox()
        #expect(box.wrappedValue == nil)
        box.wrappedValue = 3
        #expect(box.wrappedValue == 3)
    }
    
    @Test
    func access() {
        @AtomicBox var box: Int = 3
        #expect($box.access { $0.description } == "3")
    }
}
