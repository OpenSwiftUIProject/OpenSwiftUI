//
//  ResponderCommandPreference.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 1D7D458D08B5AD38421D04B7C887FEF0 (SwiftUI)

#if canImport(ObjectiveC)
@_spi(Private)
public import OpenSwiftUICore

// MARK: - InteropResponder

class InteropResponder: NSObject {
    @objc func cut(_ sender: Any?) {
        _openSwiftUIEmptyStub()
    }

    @objc func copy(_ sender: Any?) {
        _openSwiftUIEmptyStub()
    }

    @objc func paste(_ sender: Any?) {
        _openSwiftUIEmptyStub()
    }

    @objc func delete(_ sender: Any?) {
        _openSwiftUIEmptyStub()
    }
}

// MARK: - CommandAction

protocol CommandAction {
    func perform()
    var isValid: Bool { get }
}

#if os(macOS)
// MARK: - StandardCommandAction

private struct StandardCommandAction: CommandAction {
    var action: (() -> Void)?

    func perform() {
        action?()
    }

    var isValid: Bool {
        action != nil
    }
}
#endif

// MARK: - ResponderCommandsKey

struct ResponderCommandsKey: HostPreferenceKey {
    static let defaultValue: [Selector: any CommandAction] = [:]

    static func reduce(value: inout [Selector: any CommandAction], nextValue: () -> [Selector: any CommandAction]) {
        value.merge(nextValue()) { first, _ in first }
    }
}

// MARK: - View + onCommand

@available(OpenSwiftUI_v1_0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension View {
    /// Adds an action to perform in response to the given selector.
    ///
    /// This view or one of the views it contains must be in focus in order
    /// for the action to trigger. Other actions for the same command
    /// on views *closer* to the view in focus take priority, potentially
    /// overriding this action.
    ///
    /// - Parameters:
    ///   - selector: The selector to register for `action`.
    ///   - action: The action to perform. If `action` is `nil`, `command`
    ///     keeps its association with this view but doesn't trigger.
    ///
    /// - Returns: A view that triggers `action` when the `command` occurs.
    nonisolated public func onCommand(_ selector: Selector, perform action: (() -> Void)?) -> some View {
        #if os(macOS)
        modifier(OnCommandModifier(command: selector, action: StandardCommandAction(action: action)))
        #else
        _openSwiftUIUnreachableCode()
        #endif
    }
}

// MARK: - OnCommandModifier

private struct OnCommandModifier: ViewModifier {
    var command: Selector
    var action: any CommandAction
    @FocusState private var isFocused: Bool

    func body(content: Content) -> some View {
        content
            .focused($isFocused)
            .transformPreference(ResponderCommandsKey.self) { commands in
                if isFocused, commands[command] == nil {
                    commands[command] = action
                }
            }
    }
}
#endif
