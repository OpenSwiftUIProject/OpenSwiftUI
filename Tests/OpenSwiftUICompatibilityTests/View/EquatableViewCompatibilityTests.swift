//
//  EquatableViewCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

import Foundation
import OpenSwiftUITestsSupport
import Testing

// MARK: - EquatableViewCompatibilityTests

struct EquatableViewCompatibilityTests {
    // Inspired by https://swiftui-lab.com/equatableview/
    // NOTES:
    // 1. Even we implement Equatable and use EquatableView, the body will still call 2 times.
    // Explain: For 2nd call, the value is actually equal but the implementation is not called due to Layout is not ready
    // 2. If we implement Equatable but not use EquatableView, it still gets the same effect as EquatableView for POD types.
    // The difference of using EquatableView is only required for non-POD types. (Change the Rule's default comparison mode from .equatableUnlessPOD to .alwaysEquatable)
    // FIXME: 1. ?: Changing NumberView to non-POD types seems not working here
    // FIXME: 2. the count is not accurate on Unit Test target

    struct NonEquatableNumberView: View {
        var number: Int

        var confirmation: Confirmation

        var body: some View {
            confirmation()
            return Color(platformColor: number.isEven ? .red : .blue)
        }
    }

    struct NonEquatableNumberViewWrapper: View {
        @State private var count = 0

        var confirmation: Confirmation
        var continuation: UnsafeContinuation<Void, Never>

        var body: some View {
            NonEquatableNumberView(number: count, confirmation: confirmation)
                .onAppear {
                    DispatchQueue.main.async {
                        count += 2
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            count += 2
                            continuation.resume()
                        }
                    }
                }
        }
    }

    struct EquatableNumberView: View, Equatable {
        var number: Int

        var confirmation: Confirmation

        var body: some View {
            confirmation()
            return Color(platformColor: number.isEven ? .red : .blue)
        }

        nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.number.isEven == rhs.number.isEven
        }
    }

    struct EquatableNumberViewWrapper: View {
        @State private var count = 0

        var confirmation: Confirmation
        var continuation: UnsafeContinuation<Void, Never>

        var body: some View {
            EquatableNumberView(number: count, confirmation: confirmation)
                .equatable()
                .onAppear {
                    DispatchQueue.main.async {
                        count += 2
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            count += 2
                            continuation.resume()
                        }
                    }
                }
        }
    }

    @Test
    func nonEquatable() async throws {
        try await triggerLayoutWithWindow(expectedCount: 3) { confirmation, continuation in
            PlatformHostingController(
                rootView: NonEquatableNumberViewWrapper(
                    confirmation: confirmation,
                    continuation: continuation
                )
            )
        }
    }

    @Test
    func equatable() async throws {
        // FIXME: CI sometimes to be 3. Can't reproduce it locally
        let expectedCount = 2 ... 3
        try await triggerLayoutWithWindow(expectedCount: expectedCount) { confirmation, continuation in
            PlatformHostingController(
                rootView: EquatableNumberViewWrapper(
                    confirmation: confirmation,
                    continuation: continuation
                )
            )
        }
    }

    #if OPENSWIFTUI
    struct Number: Equatable {
        var value: Int

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.value.isEven == rhs.value.isEven
        }
    }

    struct EquatableProxyNumberViewWrapper: View {
        @State private var count = 0

        var confirmation: Confirmation
        var continuation: UnsafeContinuation<Void, Never>

        var body: some View {
            NonEquatableNumberView(number: count, confirmation: confirmation)
                .equatableProxy(Number(value: count))
                .onAppear {
                    DispatchQueue.main.async {
                        count += 2
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            count += 2
                            continuation.resume()
                        }
                    }
                }
        }
    }

    @Test
    func equatableProxy() async throws {
        try await triggerLayoutWithWindow { confirmation, continuation in
            PlatformHostingController(
                rootView: EquatableProxyNumberViewWrapper(
                    confirmation: confirmation,
                    continuation: continuation
                )
            )
        }
    }
    #endif
}

extension Int {
    fileprivate var isEven: Bool { self % 2 == 0 }
}
