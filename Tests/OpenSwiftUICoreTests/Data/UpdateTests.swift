//
//  UpdateTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing

#if canImport(Darwin)
struct UpdateTests {
    @Test
    @MainActor
    func example() async {
        await confirmation(expectedCount: 4) { confirmation in
            Update.locked {
                confirmation()
                #expect(!Update.isActive)
                #expect(!Update.threadIsUpdating)
                #expect(Update.isOwner)
                Update.dispatchImmediately {
                    confirmation()
                    #expect(Update.isActive)
                    #expect(!Update.threadIsUpdating)
                }
                var result = 0
                Update.enqueueAction {
                    confirmation()
                    result += 2
                    #expect(result == 2)
                }
                Update.enqueueAction {
                    confirmation()
                    result += 3
                    #expect(result == 5)
                }
                Update.dispatchActions()
                #expect(result == 5)
            }
        }
    }
}
#endif
