//
//  ThreadUtilsTest.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing

struct ThreadUtilsTest {
    static let defaultValue: Int = 1
    static let box = ThreadSpecific(defaultValue)
    
    @Test
    func value() async throws {
        let box = ThreadUtilsTest.box
        #expect(box.value == ThreadUtilsTest.defaultValue)
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
            #expect(box.value == ThreadUtilsTest.defaultValue)
        }
    }
}
