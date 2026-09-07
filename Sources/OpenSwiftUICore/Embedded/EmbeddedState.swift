//
//  EmbeddedState.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_LVGL && hasFeature(Embedded)
/// Mutable storage for content constructed and retained by an EmbeddedViewHost.
///
/// Declare state in the host's root view or its stored children. State in children
/// newly constructed by `body` needs structural identity and is not supported by
/// this profile. Construction outside the host builder fails explicitly.
/// Access must be serialized by the platform, including action closures.
@propertyWrapper
public struct State<Value> {
    private let storage: EmbeddedStateStorage<Value>

    public init(wrappedValue: Value) {
        guard let context = EmbeddedStateContext.constructing else {
            preconditionFailure("Create @State in retained content inside EmbeddedViewHost's builder")
        }
        storage = EmbeddedStateStorage(value: wrappedValue, context: context)
    }

    public var wrappedValue: Value {
        get { storage.value }
        nonmutating set {
            precondition(!storage.context.isRendering, "Do not mutate @State during rendering")
            storage.value = newValue
            storage.context.revision &+= 1
            storage.context.animation = EmbeddedAnimationTransaction.current
        }
    }
}

private final class EmbeddedStateStorage<Value> {
    var value: Value
    let context: EmbeddedStateContext
    init(value: Value, context: EmbeddedStateContext) {
        self.value = value
        self.context = context
    }
}

package final class EmbeddedStateContext {
    // Only set while a serialized host builder constructs retained content.
    nonisolated(unsafe) static var constructing: EmbeddedStateContext?
    var revision: UInt64 = 0
    var animation: Animation?
    var isRendering = false
}
#endif
