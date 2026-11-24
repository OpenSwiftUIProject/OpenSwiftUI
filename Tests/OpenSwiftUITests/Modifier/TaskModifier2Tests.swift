//
//  TaskModifier2Tests.swift
//  OpenSwiftUITests

import OpenSwiftUI
import Testing

@MainActor
@Suite
@available(OpenSwiftUI_v7_0, *)
struct TaskModifier2Tests {
    // ABI note: these must keep mangling to the symbols imported by
    // SwiftUI-linked apps (module renamed to SwiftUI). The `n` in `yyYaYAcn`
    // comes from `sending` (__owned in mangling); `YA` appears only because
    // inits are `nonisolated` (dropped under inherited @MainActor @preconcurrency).
    // Check built symbols with `nm`:
    //   $s7SwiftUI14_TaskModifier2V4name18executorPreference8priority6actionACSS_Sch_pSgScPyyYaYAcntcfC
    //     = _TaskModifier2.init(name: String, executorPreference: (any TaskExecutor)?,
    //                           priority: TaskPriority, action: sending @isolated(any) () async -> ())
    //   $s7SwiftUI19_TaskValueModifier2V2id4name18executorPreference8priority6actionACyxGx_SSSch_pSgScPyyYaYAcntcfC
    //     = _TaskValueModifier2<Value>.init(id: Value, name: ..., same trailing parameters)
    // plus metadata accessor (Ma), nominal descriptor (Mn) and ViewModifier
    // conformance descriptor (AA12ViewModifierAAMc) for both types.

    @Test
    func taskModifierStoresParameters() {
        let modifier = _TaskModifier2(
            name: "load",
            executorPreference: nil,
            priority: .utility,
            action: {}
        )
        #expect(modifier.name == "load")
        #expect(modifier.executorPreference == nil)
        #expect(modifier.priority == .utility)
    }

    @Test
    func taskValueModifierStoresParameters() {
        let modifier = _TaskValueModifier2(
            id: 3,
            name: "reload",
            executorPreference: nil,
            priority: .high,
            action: {}
        )
        #expect(modifier.value == 3)
        #expect(modifier.name == "reload")
        #expect(modifier.priority == .high)
    }

    @Test
    func conformsToViewModifier() {
        func isViewModifier<T>(_ type: T.Type) -> Bool { type is any ViewModifier.Type }
        #expect(isViewModifier(_TaskModifier2.self))
        #expect(isViewModifier(_TaskValueModifier2<Int>.self))
    }
}
