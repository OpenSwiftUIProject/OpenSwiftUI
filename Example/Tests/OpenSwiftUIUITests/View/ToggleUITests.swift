//
//  ToggleUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct ToggleUITests {
    @Test
    func onAndOffWithDefaultStyle() {
        struct ContentView: View {
            var body: some View {
                VStack {
                    Toggle(isOn: .constant(true)) { Color.green }
                    Toggle(isOn: .constant(false)) { Color.red }
                }
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test(arguments: ToggleStyleCase.allCases)
    func onAndOffWithStyle(style: ToggleStyleCase) {
        struct ContentView: View {
            let style: ToggleStyleCase

            var body: some View {
                VStack {
                    Toggle(isOn: .constant(true)) { Color.green }
                    Toggle(isOn: .constant(false)) { Color.red }
                }
                .toggleStyleCase(style)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView(style: style), named: "\(style)")
    }

    @Test(
        .bug(
            "https://github.com/OpenSwiftUIProject/OpenSwiftUI/issues/518",
            id: 518,
            "UIViewRepresentable size issue"
        )
    )
    func emptyViewLabel() {
        struct ContentView: View {
            @State private var toggle = false

            var body: some View {
                VStack {
                    Toggle(isOn: $toggle) {
                        EmptyView()
                    }
                    Color.red
                }
                .padding()
                .background { Color.green }
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}

// MARK: - ToggleStyleCase

/// The public toggle styles that a snapshot test can select by value.
///
/// Swift Testing parameterized tests need one argument type, so the styles are
/// wrapped in an enum and applied through ``View/toggleStyle(_:)`` below.
enum ToggleStyleCase: String, CaseIterable, CustomStringConvertible {
    case automatic
    case button
    case `switch`
    #if os(macOS)
    case checkbox
    #endif

    var description: String { rawValue }
}

extension View {
    @ViewBuilder
    fileprivate func toggleStyleCase(_ style: ToggleStyleCase) -> some View {
        switch style {
        case .automatic: toggleStyle(.automatic)
        case .button: toggleStyle(.button)
        case .switch: toggleStyle(.switch)
        #if os(macOS)
        case .checkbox: toggleStyle(.checkbox)
        #endif
        }
    }
}
