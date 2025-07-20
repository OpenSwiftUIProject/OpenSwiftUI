//
//  ValueActionModifierCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

#if canImport(Darwin)
import Testing

import Foundation
import OpenSwiftUITestsSupport

@MainActor
struct ValueActionModifierCompatibilityTests {
    // MARK: - onChange (deprecated version with single parameter)

    @Test
    func onChangeDeprecatedSingleParameter() async throws {
        enum Helper {
            @MainActor
            static var results: [Int] = []
        }

        struct ContentView: View {
            @State private var value = 0
            let confirmation: Confirmation
            var continuation: UnsafeContinuation<Void, Never>

            var body: some View {
                Color.red
                    .onAppear {
                        value = 1
                        DispatchQueue.main.async {
                            value = 2
                            continuation.resume()
                        }
                    }
                    .onChange(of: value) { newValue in
                        Helper.results.append(newValue)
                        confirmation()
                    }
            }
        }

        await confirmation(expectedCount: 2) { @MainActor confirmation in
            await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
                let vc = PlatformHostingController(
                    rootView: ContentView(
                        confirmation: confirmation,
                        continuation: continuation
                    )
                )
                vc.triggerLayout()
                workaroundIssue87(vc)
            }
        }
        #expect(Helper.results == [1, 2])
    }

    // MARK: - onChange with two parameters (oldValue, newValue)

    @Test
    func onChangeTwoParameters() async throws {
        enum Helper {
            @MainActor
            static var oldValues: [Int] = []
            @MainActor
            static var newValues: [Int] = []
        }

        struct ContentView: View {
            @State private var value = 0
            let confirmation: Confirmation
            var continuation: UnsafeContinuation<Void, Never>

            var body: some View {
                Color.blue
                    .onAppear {
                        value = 1
                        DispatchQueue.main.async {
                            value = 2
                            continuation.resume()
                        }
                    }
                    .onChange(of: value) { oldValue, newValue in
                        Helper.oldValues.append(oldValue)
                        Helper.newValues.append(newValue)
                        confirmation()
                    }
            }
        }

        await confirmation(expectedCount: 2) { @MainActor confirmation in
            await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
                let vc = PlatformHostingController(
                    rootView: ContentView(
                        confirmation: confirmation,
                        continuation: continuation
                    )
                )
                vc.triggerLayout()
                workaroundIssue87(vc)
            }
        }
        #expect(Helper.oldValues == [0, 1])
        #expect(Helper.newValues == [1, 2])
    }

    // MARK: - onChange with zero parameters

    @Test
    func onChangeZeroParameters() async throws {
        struct ContentView: View {
            @State private var value = 0
            let confirmation: Confirmation
            var continuation: UnsafeContinuation<Void, Never>

            var body: some View {
                Color.green
                    .onAppear {
                        value = 1
                        DispatchQueue.main.async {
                            value = 2
                            continuation.resume()
                        }
                    }
                    .onChange(of: value) {
                        confirmation()
                    }
            }
        }

        await confirmation(expectedCount: 2) { @MainActor confirmation in
            await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
                let vc = PlatformHostingController(
                    rootView: ContentView(
                        confirmation: confirmation,
                        continuation: continuation
                    )
                )
                vc.triggerLayout()
                workaroundIssue87(vc)
            }
        }
    }

    // MARK: - onChange with initial parameter

    @Test
    func onChangeWithInitial() async throws {
        enum Helper {
            @MainActor
            static var oldValues: [Int] = []
            @MainActor
            static var newValues: [Int] = []
        }

        struct ContentView: View {
            @State private var value = 0
            let confirmation: Confirmation
            var continuation: UnsafeContinuation<Void, Never>

            var body: some View {
                Color.blue
                    .onAppear {
                        value = 1
                        DispatchQueue.main.async {
                            value = 2
                            continuation.resume()
                        }
                    }
                    .onChange(of: value, initial: true) { oldValue, newValue in
                        Helper.oldValues.append(oldValue)
                        Helper.newValues.append(newValue)
                        confirmation()
                    }
            }
        }

        await confirmation(expectedCount: 3) { @MainActor confirmation in
            await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
                let vc = PlatformHostingController(
                    rootView: ContentView(
                        confirmation: confirmation,
                        continuation: continuation
                    )
                )
                vc.triggerLayout()
                workaroundIssue87(vc)
            }
        }
        #expect(Helper.oldValues == [0, 0, 1])
        #expect(Helper.newValues == [0, 1, 2])
    }

    @Test
    func onChangeWithInitialZeroParameters() async throws {
        struct ContentView: View {
            @State private var value = 0
            let confirmation: Confirmation

            var body: some View {
                Color.orange
                    .onChange(of: value, initial: true) {
                        confirmation()
                    }
            }
        }

        await confirmation { @MainActor confirmation in
            let vc = PlatformHostingController(rootView: ContentView(confirmation: confirmation))
            vc.triggerLayout()
            workaroundIssue87(vc)
        }
    }

    // MARK: - equal value changes

    @Test
    func multipleValueChanges() async throws {
        enum Helper {
            @MainActor
            static var lastOldValue = 0
            @MainActor
            static var lastNewValue = 0
        }

        struct ContentView: View {
            @State private var value = 0
            let confirmation: Confirmation
            var continuation: UnsafeContinuation<Void, Never>

            var body: some View {
                Color.purple
                    .onAppear {
                        value = 1
                        DispatchQueue.main.async {
                            value = 2
                            DispatchQueue.main.async {
                                value = 2 // This should not trigger onChange
                                continuation.resume()
                            }
                        }
                    }
                    .onChange(of: value) { oldValue, newValue in
                        Helper.lastOldValue = oldValue
                        Helper.lastNewValue = newValue
                        confirmation()
                    }
            }
        }
        await confirmation(expectedCount: 2) { @MainActor confirmation in
            await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
                let vc = PlatformHostingController(
                    rootView: ContentView(
                        confirmation: confirmation,
                        continuation: continuation
                    )
                )
                vc.triggerLayout()
                workaroundIssue87(vc)
            }
        }
        #expect(Helper.lastOldValue == 1)
        #expect(Helper.lastNewValue == 2)
    }

    // MARK: - String value changes

    @Test
    func stringValueChanges() async throws {
        enum Helper {
            @MainActor
            static var lastValue = ""
        }

        struct ContentView: View {
            @State private var text = "initial"
            let confirmation: Confirmation
            var continuation: UnsafeContinuation<Void, Never>

            var body: some View {
                Color.cyan
                    .onAppear {
                        text = "changed"
                        DispatchQueue.main.async {
                            text = "final"
                            continuation.resume()
                        }
                    }
                    .onChange(of: text) { _, newValue in
                        Helper.lastValue = newValue
                        confirmation()
                    }
            }
        }
        await confirmation(expectedCount: 2) { @MainActor confirmation in
            await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
                let vc = PlatformHostingController(
                    rootView: ContentView(
                        confirmation: confirmation,
                        continuation: continuation
                    )
                )
                vc.triggerLayout()
                workaroundIssue87(vc)
            }
        }

        #expect(Helper.lastValue == "final")
    }

    // MARK: - Boolean value changes

    @Test
    func booleanValueChanges() async throws {
        enum Helper {
            @MainActor
            static var toggleCount = 0
        }

        struct ContentView: View {
            @State private var isOn = false
            let confirmation: Confirmation
            var continuation: UnsafeContinuation<Void, Never>

            var body: some View {
                Color.mint
                    .onAppear {
                        isOn = true
                        DispatchQueue.main.async {
                            isOn = false
                            DispatchQueue.main.async {
                                isOn = true
                                continuation.resume()
                            }
                        }
                    }
                    .onChange(of: isOn) {
                        Helper.toggleCount += 1
                        confirmation()
                    }
            }
        }
        await confirmation(expectedCount: 3) { @MainActor confirmation in
            await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
                let vc = PlatformHostingController(
                    rootView: ContentView(
                        confirmation: confirmation,
                        continuation: continuation
                    )
                )
                vc.triggerLayout()
                workaroundIssue87(vc)
            }
        }

        #expect(Helper.toggleCount == 3)
    }
}
#endif
