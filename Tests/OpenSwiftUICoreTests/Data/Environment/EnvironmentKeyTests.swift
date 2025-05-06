//
//  EnvironmentKeyTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

struct EnvironmentKeyTests {
    // MARK: - Default Value Tests
    
    @Test
    func defaultValues() {
        #expect(StringEnvironmentKey.defaultValue == "")
        #expect(IntEnvironmentKey.defaultValue == 0)
        #expect(OptionalStringEnvironmentKey.defaultValue == nil)
        #expect(CustomStructEnvironmentKey.defaultValue.value == 100)
    }
    
    // MARK: - Value Equality Tests
    
    @Test
    func equatableValuesComparison() {
        #expect(StringEnvironmentKey._valuesEqual("test", "test") == true)
        #expect(StringEnvironmentKey._valuesEqual("test", "different") == false)
        
        #expect(IntEnvironmentKey._valuesEqual(42, 42) == true)
        #expect(IntEnvironmentKey._valuesEqual(42, 43) == false)
        
        #expect(OptionalStringEnvironmentKey._valuesEqual(nil, nil) == true)
        #expect(OptionalStringEnvironmentKey._valuesEqual("test", "test") == true)
        #expect(OptionalStringEnvironmentKey._valuesEqual("test", nil) == false)
        #expect(OptionalStringEnvironmentKey._valuesEqual(nil, "test") == false)
    }
    
    @Test
    func nonEquatableValuesComparison() {
        let struct1 = CustomStructEnvironmentKey.CustomStruct(value: 100)
        let struct2 = CustomStructEnvironmentKey.CustomStruct(value: 100)
        let struct3 = CustomStructEnvironmentKey.CustomStruct(value: 200)
        
        #expect(CustomStructEnvironmentKey._valuesEqual(struct1, struct2) == true)
        #expect(CustomStructEnvironmentKey._valuesEqual(struct1, struct3) == false)
    }
    
    // MARK: - DerivedEnvironmentKey Tests
    
    @Test
    func derivedEnvironmentKey() {
        var environment = EnvironmentValues()
        environment[StringEnvironmentKey.self] = "test value"
        let derived = DerivedStringEnvironmentKey.value(in: environment)
        #expect(derived == "d:test value")
    }
}
