//
//  TaskModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 293A0AF83C78DECE53AFAAF3EDCBA9D4 (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

@available(OpenSwiftUI_v3_0, *)
extension View {
    /// Adds an asynchronous task to perform before this view appears.
    ///
    /// Use this modifier to perform an asynchronous task with a lifetime that
    /// matches that of the modified view. If the task doesn't finish
    /// before OpenSwiftUI removes the view or the view changes identity, OpenSwiftUI
    /// cancels the task.
    ///
    /// Use the `await` keyword inside the task to
    /// wait for an asynchronous call to complete, or to wait on the values of
    /// an [AsyncSequence](https://developer.apple.com/documentation/swift/asyncsequence)
    /// instance. For example, you can modify a ``Text`` view to start a task
    /// that loads content from a remote resource:
    ///
    ///     let url = URL(string: "https://example.com")!
    ///     @State private var message = "Loading..."
    ///
    ///     var body: some View {
    ///         Text(message)
    ///             .task {
    ///                 do {
    ///                     var receivedLines = [String]()
    ///                     for try await line in url.lines {
    ///                         receivedLines.append(line)
    ///                         message = "Received \(receivedLines.count) lines"
    ///                     }
    ///                 } catch {
    ///                     message = "Failed to load"
    ///                 }
    ///             }
    ///     }
    ///
    /// This example uses the
    /// [lines](https://developer.apple.com/documentation/foundation/url/3767315-lines)
    /// method to get the content stored at the specified
    /// [URL](https://developer.apple.com/documentation/foundation/url) as an
    /// asynchronous sequence of strings. When each new line arrives, the body
    /// of the `for`-`await`-`in` loop stores the line in an array of strings
    /// and updates the content of the text view to report the latest line
    /// count.
    ///
    /// - Parameters:
    ///   - priority: The task priority to use when creating the asynchronous
    ///     task. The default priority is
    ///     [userInitiated](https://developer.apple.com/documentation/swift/taskpriority/userinitiated),
    ///   - action: A closure that OpenSwiftUI calls as an asynchronous task
    ///     before the view appears. OpenSwiftUI will automatically cancel the task
    ///     at some point after the view disappears before the action completes.
    ///
    ///
    /// - Returns: A view that runs the specified action asynchronously before
    ///   the view appears.
    @inlinable
    nonisolated public func task(
        priority: TaskPriority = .userInitiated,
        @_inheritActorContext _ action: @escaping @Sendable () async -> Void
    ) -> some View {
        modifier(_TaskModifier(priority: priority, action: action))
    }

    /// Adds a task to perform before this view appears or when a specified
    /// value changes.
    ///
    /// This method behaves like ``View/task(priority:_:)``, except that it also
    /// cancels and recreates the task when a specified value changes. To detect
    /// a change, the modifier tests whether a new value for the `id` parameter
    /// equals the previous value. For this to work,
    /// the value's type must conform to the
    /// [Equatable](https://developer.apple.com/documentation/swift/equatable) protocol.
    ///
    /// For example, if you define an equatable `Server` type that posts custom
    /// notifications whenever its state changes --- for example, from _signed
    /// out_ to _signed in_ --- you can use the task modifier to update
    /// the contents of a ``Text`` view to reflect the state of the
    /// currently selected server:
    ///
    ///     Text(status ?? "Signed Out")
    ///         .task(id: server) {
    ///             let sequence = NotificationCenter.default.notifications(
    ///                 named: .didUpdateStatus,
    ///                 object: server
    ///             ).compactMap {
    ///                 $0.userInfo?["status"] as? String
    ///             }
    ///             for await value in sequence {
    ///                 status = value
    ///             }
    ///         }
    ///
    /// This example uses the
    /// [notifications(named:object:)](https://developer.apple.com/documentation/foundation/notificationcenter/3813137-notifications)
    /// method to create an asynchronous sequence of notifications, given by an
    /// [AsyncSequence](https://developer.apple.com/documentation/swift/asyncsequence)
    /// instance. The example then maps the notification sequence to a sequence
    /// of strings that correspond to values stored with each notification.
    ///
    /// Elsewhere, the server defines a custom `didUpdateStatus` notification:
    ///
    ///     extension NSNotification.Name {
    ///         static var didUpdateStatus: NSNotification.Name {
    ///             NSNotification.Name("didUpdateStatus")
    ///         }
    ///     }
    ///
    /// Whenever the server status changes, like after the user signs in, the
    /// server posts a notification of this custom type:
    ///
    ///     let notification = Notification(
    ///         name: .didUpdateStatus,
    ///         object: self,
    ///         userInfo: ["status": "Signed In"])
    ///     NotificationCenter.default.post(notification)
    ///
    /// The task attached to the ``Text`` view gets and displays the status
    /// value from the notification's user information dictionary. When the user
    /// chooses a different server, OpenSwiftUI cancels the task and creates a new
    /// one, which then waits for notifications from the new server.
    ///
    /// - Parameters:
    ///   - id: The value to observe for changes. The value must conform
    ///     to the [Equatable](https://developer.apple.com/documentation/swift/equatable)
    ///     protocol.
    ///   - priority: The task priority to use when creating the asynchronous
    ///     task. The default priority is
    ///     [userInitiated](https://developer.apple.com/documentation/swift/taskpriority/userinitiated).
    ///   - action: A closure that OpenSwiftUI calls as an asynchronous task
    ///     before the view appears. OpenSwiftUI can automatically cancel the task
    ///     after the view disappears before the action completes. If the
    ///     `id` value changes, OpenSwiftUI cancels and restarts the task.
    ///
    /// - Returns: A view that runs the specified action asynchronously before
    ///   the view appears, or restarts the task when the `id` value changes.
    @inlinable
    nonisolated public func task<T>(
        id value: T,
        priority: TaskPriority = .userInitiated,
        @_inheritActorContext _ action: @escaping @Sendable () async -> Void
    ) -> some View where T: Equatable {
        modifier(_TaskValueModifier(
            value: value, priority: priority, action: action
        ))
    }
}

@available(OpenSwiftUI_v3_0, *)
@frozen
public struct _TaskModifier: ViewModifier {
    nonisolated(unsafe) public var action: @Sendable () async -> Void

    public var priority: TaskPriority

    @inlinable
    public init(priority: TaskPriority, action: @escaping @Sendable () async -> Void) {
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
        var modifier: _TaskModifier

        var value: InnerModifier {
            InnerModifier(base: modifier)
        }
    }

    private struct InnerModifier: ViewModifier {
        var base: _TaskModifier

        @State
        private var task: Task<Void, Never>?

        func body(content: Content) -> some View {
            content.modifier(_AppearanceActionModifier(
                appear: {
                    guard task == nil else { return }
                    let action = base.action
                    task = Task.detached(priority: base.priority) {
                        await action()
                    }
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

@available(OpenSwiftUI_v3_0, *)
@frozen
public struct _TaskValueModifier<Value>: ViewModifier where Value: Equatable {
    nonisolated(unsafe) public var action: @Sendable () async -> Void

    public var priority: TaskPriority

    public var value: Value

    @inlinable
    public init(
        value: Value,
        priority: TaskPriority,
        action: @escaping @Sendable () async -> Void
    ) {
        self.action = action
        self.priority = priority
        self.value = value
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
        var modifier: _TaskValueModifier<Value>

        var value: InnerModifier {
            InnerModifier(base: modifier)
        }
    }

    private struct InnerModifier: ViewModifier {
        var base: _TaskValueModifier<Value>

        struct TaskState {
            var task: Task<Void, Never>
            var value: Value
        }

        @State
        private var taskState: TaskState?

        func body(content: Content) -> some View {
            content.modifier(_AppearanceActionModifier(
                appear: {
                    guard taskState == nil else { return }
                    let action = base.action
                    taskState = TaskState(
                        task: .detached(priority: base.priority) {
                            await action()
                        },
                        value: base.value
                    )
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
                let action = base.action
                self.taskState = TaskState(
                    task: .detached(priority: base.priority) {
                        await action()
                    },
                    value: base.value
                )
            }
        }
    }
}

@available(*, unavailable)
extension _TaskValueModifier: Sendable {}
