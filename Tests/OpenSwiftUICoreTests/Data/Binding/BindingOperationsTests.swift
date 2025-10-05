//
//  BindingOperationsTests.swift
//  OpenSwiftUITests
//
//  Author: Claude Code with Claude Sonnet 4.5

import Foundation
import Testing
@testable import OpenSwiftUICore

struct BindingOperationsTests {

    // MARK: - Binding.init(_:) to Optional

    struct ToOptionalTests {
        @Test
        func get() {
            var storage = 42
            let baseBinding = Binding {
                storage
            } set: { newValue in
                storage = newValue
            }

            let optionalBinding: Binding<Int?> = Binding(baseBinding)
            #expect(optionalBinding.wrappedValue == 42)
        }

        @Test
        func setWithNonNil() {
            var storage = 10
            let baseBinding = Binding {
                storage
            } set: { newValue in
                storage = newValue
            }

            let optionalBinding: Binding<Int?> = Binding(baseBinding)
            optionalBinding.wrappedValue = 20
            #expect(optionalBinding.wrappedValue == 10)

            storage = 20
            #expect(optionalBinding.wrappedValue == 20)
        }

        @Test
        func setWithNil() {
            var storage = 10
            let baseBinding = Binding {
                storage
            } set: { newValue in
                storage = newValue
            }

            let optionalBinding: Binding<Int?> = Binding(baseBinding)
            optionalBinding.wrappedValue = nil
            #expect(optionalBinding.wrappedValue == 10)
            #expect(storage == 10)
        }
    }

    // MARK: - Binding.init(_:) to AnyHashable

    struct ToAnyHashableTests {
        @Test
        func get() {
            var storage = 42
            let baseBinding = Binding {
                storage
            } set: { newValue in
                storage = newValue
            }

            let anyHashableBinding: Binding<AnyHashable> = Binding(baseBinding)
            #expect(anyHashableBinding.wrappedValue == AnyHashable(42))
        }

        @Test
        func set() {
            var storage = 10
            let baseBinding = Binding {
                storage
            } set: { newValue in
                storage = newValue
            }

            let anyHashableBinding: Binding<AnyHashable> = Binding(baseBinding)
            anyHashableBinding.wrappedValue = AnyHashable(20)
            #expect(anyHashableBinding.wrappedValue == AnyHashable(10))

            storage = 20
            #expect(anyHashableBinding.wrappedValue == AnyHashable(20))
        }

        @Test
        func withString() {
            var storage = "hello"
            let baseBinding = Binding {
                storage
            } set: { newValue in
                storage = newValue
            }

            let anyHashableBinding: Binding<AnyHashable> = Binding(baseBinding)
            #expect(anyHashableBinding.wrappedValue == AnyHashable("hello"))

            anyHashableBinding.wrappedValue = AnyHashable("world")
            #expect(anyHashableBinding.wrappedValue == AnyHashable("hello"))

            storage = "world"
            #expect(anyHashableBinding.wrappedValue == AnyHashable("world"))
        }
    }

    // MARK: - Binding.init?(_:) ForceUnwrapping

    struct ForceUnwrappingTests {
        @Test
        func getNonNil() {
            var storage: Int? = 42
            let baseBinding = Binding {
                storage
            } set: { newValue in
                storage = newValue
            }

            let unwrappedBinding = Binding(baseBinding)
            #expect(unwrappedBinding != nil)
            #expect(unwrappedBinding?.wrappedValue == 42)
        }

        @Test
        func getNil() {
            var storage: Int? = nil
            let baseBinding = Binding {
                storage
            } set: { newValue in
                storage = newValue
            }

            let unwrappedBinding = Binding(baseBinding)
            #expect(unwrappedBinding == nil)
        }

        @Test
        func set() {
            var storage: Int? = 10
            let baseBinding = Binding {
                storage
            } set: { newValue in
                storage = newValue
            }

            guard let unwrappedBinding = Binding(baseBinding) else {
                #expect(Bool(false))
                return
            }

            unwrappedBinding.wrappedValue = 20
            #expect(unwrappedBinding.wrappedValue == 10)

            storage = 20
            #expect(unwrappedBinding.wrappedValue == 20)
        }
    }

    // MARK: - Binding.subscript(keyPath:default:) (tests NilCoalescing)

    struct NilCoalescingTests {
        @Test
        func getWithValue() {
            struct Model {
                var value: Int?
            }

            var storage = Model(value: 42)
            let baseBinding = Binding {
                storage
            } set: { newValue in
                storage = newValue
            }

            let nilCoalescingBinding = baseBinding[\.value, default: 100]
            #expect(nilCoalescingBinding.wrappedValue == 42)
        }

        @Test
        func getWithNil() {
            struct Model {
                var value: Int?
            }

            var storage = Model(value: nil)
            let baseBinding = Binding {
                storage
            } set: { newValue in
                storage = newValue
            }

            let nilCoalescingBinding = baseBinding[\.value, default: 100]
            #expect(nilCoalescingBinding.wrappedValue == 100)
        }

        @Test
        func set() {
            struct Model {
                var value: Int?
            }

            var storage = Model(value: nil)
            let baseBinding = Binding {
                storage
            } set: { newValue in
                storage = newValue
            }

            let nilCoalescingBinding = baseBinding[\.value, default: 100]
            #expect(nilCoalescingBinding.wrappedValue == 100)

            nilCoalescingBinding.wrappedValue = 50
            #expect(nilCoalescingBinding.wrappedValue == 100)

            storage.value = 50
            #expect(nilCoalescingBinding.wrappedValue == 50)
        }

        @Test
        func setBackToNil() {
            struct Model {
                var value: Int?
            }

            var storage = Model(value: 42)
            let baseBinding = Binding {
                storage
            } set: { newValue in
                storage = newValue
            }

            let nilCoalescingBinding = baseBinding[\.value, default: 100]
            #expect(nilCoalescingBinding.wrappedValue == 42)

            storage.value = nil
            #expect(nilCoalescingBinding.wrappedValue == 100)
        }
    }

    // MARK: - Binding.init(_:) to Double from BinaryFloatingPoint

    struct ToDoubleTests {
        @Test
        func getFromFloat() {
            var storage: Float = 3.14
            let baseBinding = Binding {
                storage
            } set: { newValue in
                storage = newValue
            }

            let doubleBinding: Binding<Double> = Binding(baseBinding)
            #expect(doubleBinding.wrappedValue.isApproximatelyEqual(to: 3.14, absoluteTolerance: 0.001))
        }

        @Test
        func setFromFloat() {
            var storage: Float = 1.0
            let baseBinding = Binding {
                storage
            } set: { newValue in
                storage = newValue
            }

            let doubleBinding: Binding<Double> = Binding(baseBinding)
            doubleBinding.wrappedValue = 2.5
            #expect(doubleBinding.wrappedValue.isApproximatelyEqual(to: 1.0, absoluteTolerance: 0.001))

            storage = 2.5
            #expect(doubleBinding.wrappedValue.isApproximatelyEqual(to: 2.5, absoluteTolerance: 0.001))
        }

        @Test
        func getFromCGFloat() {
            var storage: CGFloat = 3.14159
            let baseBinding = Binding {
                storage
            } set: { newValue in
                storage = newValue
            }

            let doubleBinding: Binding<Double> = Binding(baseBinding)
            #expect(doubleBinding.wrappedValue.isApproximatelyEqual(to: 3.14159))
        }

        @Test
        func setFromCGFloat() {
            var storage: CGFloat = 1.0
            let baseBinding = Binding {
                storage
            } set: { newValue in
                storage = newValue
            }

            let doubleBinding: Binding<Double> = Binding(baseBinding)
            doubleBinding.wrappedValue = 2.71828
            #expect(doubleBinding.wrappedValue.isApproximatelyEqual(to: 1.0))

            storage = 2.71828
            #expect(doubleBinding.wrappedValue.isApproximatelyEqual(to: 2.71828))
        }
    }

    // MARK: - Binding.init(_:) to Double from BinaryInteger

    struct ToDoubleFromIntegerTests {
        @Test
        func get() {
            var storage = 42
            let baseBinding = Binding {
                storage
            } set: { newValue in
                storage = newValue
            }

            let doubleBinding: Binding<Double> = Binding(baseBinding)
            #expect(doubleBinding.wrappedValue == 42.0)
        }

        @Test
        func set() {
            var storage = 10
            let baseBinding = Binding {
                storage
            } set: { newValue in
                storage = newValue
            }

            let doubleBinding: Binding<Double> = Binding(baseBinding)
            doubleBinding.wrappedValue = 25.7
            #expect(doubleBinding.wrappedValue == 10.0)

            storage = 25
            #expect(doubleBinding.wrappedValue == 25.0)
        }

        @Test
        func withUInt() {
            var storage: UInt = 100
            let baseBinding = Binding {
                storage
            } set: { newValue in
                storage = newValue
            }

            let doubleBinding: Binding<Double> = Binding(baseBinding)
            #expect(doubleBinding.wrappedValue == 100.0)

            doubleBinding.wrappedValue = 200.5
            #expect(doubleBinding.wrappedValue == 100.0)

            storage = 200
            #expect(doubleBinding.wrappedValue == 200.0)
        }
    }

    // MARK: - Binding.== operator (tests Equals projection)

    struct EqualsTests {
        @Test
        func getWhenEqual() {
            var storage = 42
            let binding = Binding {
                storage
            } set: { newValue in
                storage = newValue
            }

            let resultBinding = binding == 42
            #expect(resultBinding.wrappedValue == true)
        }

        @Test
        func getWhenNotEqual() {
            var storage = 10
            let binding = Binding {
                storage
            } set: { newValue in
                storage = newValue
            }

            let resultBinding = binding == 42
            #expect(resultBinding.wrappedValue == false)
        }

        @Test
        func setWhenTrue() {
            var storage = 10
            let binding = Binding {
                storage
            } set: { newValue in
                storage = newValue
            }

            let resultBinding = binding == 42
            #expect(resultBinding.wrappedValue == false)

            resultBinding.wrappedValue = true
            #expect(resultBinding.wrappedValue == false)

            storage = 42
            #expect(resultBinding.wrappedValue == true)
        }

        @Test
        func setWhenFalse() {
            var storage = 42
            let binding = Binding {
                storage
            } set: { newValue in
                storage = newValue
            }

            let resultBinding = binding == 42
            #expect(resultBinding.wrappedValue == true)

            resultBinding.wrappedValue = false
            #expect(resultBinding.wrappedValue == true)
            #expect(storage == 42)
        }

        @Test
        func withString() {
            var storage = "hello"
            let binding = Binding {
                storage
            } set: { newValue in
                storage = newValue
            }

            let resultBinding1 = binding == "hello"
            #expect(resultBinding1.wrappedValue == true)

            let resultBinding2 = binding == "world"
            #expect(resultBinding2.wrappedValue == false)

            resultBinding2.wrappedValue = true
            #expect(resultBinding2.wrappedValue == false)

            storage = "world"
            #expect(resultBinding2.wrappedValue == true)

            resultBinding2.wrappedValue = false
            #expect(resultBinding2.wrappedValue == true)
        }
    }

    // MARK: - Binding.false

    struct BindingFalseTests {
        @Test
        func constantFalse() {
            let falseBinding = Binding<Bool>.false
            #expect(falseBinding.wrappedValue == false)

            falseBinding.wrappedValue = true
            #expect(falseBinding.wrappedValue == false)
        }
    }
}
