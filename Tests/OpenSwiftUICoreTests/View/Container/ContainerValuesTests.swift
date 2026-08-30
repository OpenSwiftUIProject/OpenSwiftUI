//
//  ContainerValuesTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import Testing

private struct TestContainerValueKey: ContainerValueKey {
    static var defaultValue: Int { 1 }
}

private extension ContainerValues {
    var testValue: Int {
        get { self[TestContainerValueKey.self] }
        set { self[TestContainerValueKey.self] = newValue }
    }
}

struct ContainerValuesTests {
    @Test
    func values() {
        var values = ContainerValues(base: ViewTraitCollection())
        #expect(values.testValue == 1)

        values.testValue = 2
        #expect(values.testValue == 2)
    }

    @Test
    func tags() {
        var traits = ViewTraitCollection()
        traits.setTag(for: Int.self, value: 3)
        let values = ContainerValues(base: traits)

        #expect(values.tag(for: Int.self) == 3)
        #expect(values.hasTag(3))
        #expect(!values.hasTag(4))
    }

    @Test
    @MainActor
    func modifier() {
        let modifier = _ContainerValueWritingModifier(
            keyPath: \.testValue,
            value: 4
        )

        #expect(modifier.keyPath == \.testValue)
        #expect(modifier.value == 4)
    }
}
