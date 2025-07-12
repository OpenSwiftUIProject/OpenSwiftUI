//
//  EquatableViewTests.swift
//  OpenSwiftUITests

import Foundation
import OpenSwiftUITestsSupport
import Testing

// MARK: - EquatableViewTests

#if canImport(Darwin)

struct EquatableViewTests {
    // Inspired by https://swiftui-lab.com/equatableview/
    // NOTES:
    // 1. Even we implement Equatable and use EquatableView, the body will still call 2 times.
    // Explain: For 2nd call, the value is actually equal but the implementation is not called due to Layout is not ready
    // 2. If we implement Equatable but not use EquatableView, it still gets the same effect as EquatableView for POD types.
    // The difference of using EquatableView is only required for non-POD types. (Change the Rule's default comparison mode from .equatableUnlessPOD to .alwaysEquatable)
    // (?: Changing NumberView to non-POD types seems not working here)

    struct NonEquatableNumberView: View {
        var number: Int

        var confirmation: Confirmation

        var body: some View {
            confirmation()
            #if os(iOS)
            return Color(uiColor: number.isEven ? .red : .blue)
            #elseif os(macOS)
            return Color(nsColor: number.isEven ? .red : .blue)
            #endif
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
            #if os(iOS)
            return Color(uiColor: number.isEven ? .red : .blue)
            #elseif os(macOS)
            return Color(nsColor: number.isEven ? .red : .blue)
            #endif
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
        #if os(iOS)
        let expectedCount = 1 // FIXME: Not epected
        #elseif os(macOS)
        let expectedCount = 3
        #endif
        await confirmation(expectedCount: expectedCount) { @MainActor confirmation in
            await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
                let vc = PlatformHostingController(
                    rootView: NonEquatableNumberViewWrapper(
                        confirmation: confirmation,
                        continuation: continuation
                    )
                )
                vc.triggerLayout()
                workaroundIssue87(vc)
            }
        }
    }

    @Test
    func equatable() async throws {
        #if os(iOS)
        let expectedCount = 1 // FIXME: Not epected
        #elseif os(macOS)
        let expectedCount = 2
        #endif
        await confirmation(expectedCount: expectedCount) { @MainActor confirmation in
            await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
                let vc = PlatformHostingController(
                    rootView: EquatableNumberViewWrapper(
                        confirmation: confirmation,
                        continuation: continuation
                    )
                )
                vc.triggerLayout()
                workaroundIssue87(vc)
            }
        }
    }

    #if !OPENSWIFTUI_COMPATIBILITY_TEST
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
        await confirmation(expectedCount: 1) { @MainActor confirmation in
            await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
                let vc = PlatformHostingController(
                    rootView: EquatableProxyNumberViewWrapper(
                        confirmation: confirmation,
                        continuation: continuation
                    )
                )
                vc.triggerLayout()
                workaroundIssue87(vc)
            }
        }
    }
    #endif
}

extension Int {
    fileprivate var isEven: Bool { self % 2 == 0 }
}
#endif
