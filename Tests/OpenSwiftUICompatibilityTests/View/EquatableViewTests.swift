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
    // FIXME: 1. ?: Changing NumberView to non-POD types seems not working here
    // FIXME: 2. the count is not accurate on Unit Test target

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
        let expectedCount = 1 ... 3 // FIXME: Not expected, probably due to triggerLayout implementation. local 1 while CI is 3 :(
        #elseif os(macOS)
        let expectedCount = 1 ... 3 // FIXME: Not expected, local 3 while CI 1 or 2 :(
        #endif
        var vc: PlatformViewController!
        await confirmation(expectedCount: expectedCount) { @MainActor confirmation in
            await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
                vc = PlatformHostingController(
                    rootView: NonEquatableNumberViewWrapper(
                        confirmation: confirmation,
                        continuation: continuation
                    )
                )
                vc.triggerLayout()
            }
        }
        withExtendedLifetime(vc) {}
    }

    @Test
    func equatable() async throws {
        #if os(iOS)
        let expectedCount = 1 ... 3 // FIXME: Not expected, probably due to triggerLayout implementation. local 1 which CI is 1 or 2 :(
        #elseif os(macOS)
        let expectedCount = 1 ... 3 // FIXME: Not expected, local 2 while CI 1 or 2 :(
        #endif
        var vc: PlatformViewController!
        await confirmation(expectedCount: expectedCount) { @MainActor confirmation in
            await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
                vc = PlatformHostingController(
                    rootView: EquatableNumberViewWrapper(
                        confirmation: confirmation,
                        continuation: continuation
                    )
                )
                vc.triggerLayout()
            }
        }
        withExtendedLifetime(vc) {}
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
        var vc: PlatformViewController!
        await confirmation(expectedCount: 1) { @MainActor confirmation in
            await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
                vc = PlatformHostingController(
                    rootView: EquatableProxyNumberViewWrapper(
                        confirmation: confirmation,
                        continuation: continuation
                    )
                )
                vc.triggerLayout()
            }
        }
        withExtendedLifetime(vc) {}
    }
    #endif
}

extension Int {
    fileprivate var isEven: Bool { self % 2 == 0 }
}
#endif
