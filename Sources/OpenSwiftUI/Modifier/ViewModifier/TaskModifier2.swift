//
//  TaskModifier2.swift
//  OpenSwiftUI
//
//  Implemented from the public documentation of
//  View.task(name:executorPreference:priority:_:). Unlike _TaskModifier it
//  also carries a task name and a TaskExecutor preference, and the action is
//  @isolated(any).
//
//  The initialiser labels and parameter types follow the symbol names that
//  SwiftUI-linked apps import; Tests/OpenSwiftUITests/Modifier/TaskModifier2Tests.swift
//  lists the mangled names this must keep matching.

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

@available(OpenSwiftUI_v7_0, *)
@frozen
public struct _TaskModifier2: ViewModifier {
    public var name: String

    public var executorPreference: (any TaskExecutor)?

    public var priority: TaskPriority

    nonisolated(unsafe) public var action: @isolated(any) () async -> Void

    // nonisolated: inheriting ViewModifier's @preconcurrency @MainActor
    // isolation drops `YA` (@isolated(any)) from the init's mangled name.
    @inlinable
    nonisolated public init(
        name: String,
        executorPreference: (any TaskExecutor)?,
        priority: TaskPriority,
        action: sending @escaping @isolated(any) () async -> Void
    ) {
        self.name = name
        self.executorPreference = executorPreference
        self.priority = priority
        self.action = action
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        Child.Value._makeView(
            modifier: _GraphValue(Child(modifier: modifier.value)),
            inputs: inputs,
            body: body
        )
    }

    nonisolated public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        Child.Value._makeViewList(
            modifier: _GraphValue(Child(modifier: modifier.value)),
            inputs: inputs,
            body: body
        )
    }

    nonisolated public static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        Child.Value._viewListCount(
            inputs: inputs,
            body: body
        )
    }

    private struct Child: Rule, AsyncAttribute {
        @Attribute
        var modifier: _TaskModifier2

        var value: InnerModifier {
            InnerModifier(base: modifier)
        }
    }

    private struct InnerModifier: ViewModifier {
        var base: _TaskModifier2

        @State
        private var task: Task<Void, Never>?

        private func start() -> Task<Void, Never> {
            Task.detached(
                name: base.name,
                executorPreference: base.executorPreference,
                priority: base.priority,
                operation: base.action
            )
        }

        func body(content: Content) -> some View {
            content.modifier(_AppearanceActionModifier(
                appear: {
                    guard task == nil else { return }
                    task = start()
                },
                disappear: {
                    if let task {
                        task.cancel()
                        self.task = nil
                    }
                }
            ))
        }
    }
}

@available(OpenSwiftUI_v7_0, *)
@frozen
public struct _TaskValueModifier2<Value>: ViewModifier where Value: Equatable {
    nonisolated(unsafe) public var value: Value

    public var name: String

    public var executorPreference: (any TaskExecutor)?

    public var priority: TaskPriority

    nonisolated(unsafe) public var action: @isolated(any) () async -> Void

    // nonisolated: inheriting ViewModifier's @preconcurrency @MainActor
    // isolation drops `YA` (@isolated(any)) from the init's mangled name.
    @inlinable
    nonisolated public init(
        id value: Value,
        name: String,
        executorPreference: (any TaskExecutor)?,
        priority: TaskPriority,
        action: sending @escaping @isolated(any) () async -> Void
    ) {
        self.value = value
        self.name = name
        self.executorPreference = executorPreference
        self.priority = priority
        self.action = action
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        Child.Value._makeView(
            modifier: _GraphValue(Child(modifier: modifier.value)),
            inputs: inputs,
            body: body
        )
    }

    nonisolated public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        Child.Value._makeViewList(
            modifier: _GraphValue(Child(modifier: modifier.value)),
            inputs: inputs,
            body: body
        )
    }

    nonisolated public static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        Child.Value._viewListCount(
            inputs: inputs,
            body: body
        )
    }

    private struct Child: Rule, AsyncAttribute {
        @Attribute
        var modifier: _TaskValueModifier2<Value>

        var value: InnerModifier {
            InnerModifier(base: modifier)
        }
    }

    private struct InnerModifier: ViewModifier {
        var base: _TaskValueModifier2<Value>

        struct TaskState {
            var task: Task<Void, Never>
            var value: Value
        }

        @State
        private var taskState: TaskState?

        private func start() -> TaskState {
            TaskState(
                task: Task.detached(
                    name: base.name,
                    executorPreference: base.executorPreference,
                    priority: base.priority,
                    operation: base.action
                ),
                value: base.value
            )
        }

        func body(content: Content) -> some View {
            content.modifier(_AppearanceActionModifier(
                appear: {
                    guard taskState == nil else { return }
                    taskState = start()
                },
                disappear: {
                    if let taskState {
                        taskState.task.cancel()
                        self.taskState = nil
                    }
                }
            ))
            .onChange(of: base.value) {
                guard let taskState,
                      taskState.value != base.value
                else { return }
                taskState.task.cancel()
                self.taskState = start()
            }
        }
    }
}

@available(*, unavailable)
extension _TaskValueModifier2: Sendable {}
