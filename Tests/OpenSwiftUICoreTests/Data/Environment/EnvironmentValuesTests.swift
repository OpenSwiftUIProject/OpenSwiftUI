//
//  EnvironmentValuesTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

// MARK: - Environment Values Extension

extension EnvironmentValues {
    var testString: String {
        get { self[StringEnvironmentKey.self] }
        set { self[StringEnvironmentKey.self] = newValue }
    }
    
    var testInt: Int {
        get { self[IntEnvironmentKey.self] }
        set { self[IntEnvironmentKey.self] = newValue }
    }
    
    var testBool: Bool {
        get { self[BoolEnvironmentKey.self] }
        set { self[BoolEnvironmentKey.self] = newValue }
    }
    
    var derivedString: String {
        self[DerivedStringEnvironmentKey.self]
    }
}

struct EnvironmentValuesTests {
    // MARK: - Init Tests
    
    @Test
    func defaultInit() {
        let environment = EnvironmentValues()
        
        #expect(environment[StringEnvironmentKey.self] == "")
        #expect(environment[IntEnvironmentKey.self] == 0)
        #expect(environment[BoolEnvironmentKey.self] == false)
    }
    
    // MARK: - Value Setting and Retrieval Tests
    
    @Test
    func setAndGetValues() {
        var environment = EnvironmentValues()
        
        #expect(environment.testString == "")
        #expect(environment.testInt == 0)
        #expect(environment.testBool == false)
        
        environment[StringEnvironmentKey.self] = "custom string"
        environment[IntEnvironmentKey.self] = 100
        environment[BoolEnvironmentKey.self] = true
        
        #expect(environment[StringEnvironmentKey.self] == "custom string")
        #expect(environment[IntEnvironmentKey.self] == 100)
        #expect(environment[BoolEnvironmentKey.self] == true)
        
        environment.testString = "another string"
        environment.testInt = 200
        environment.testBool = false
        
        #expect(environment.testString == "another string")
        #expect(environment.testInt == 200)
        #expect(environment.testBool == false)
    }
    
    // MARK: - DerivedEnvironmentKey Tests
    
    @Test
    func derivedEnvironmentValues() {
        var environment = EnvironmentValues()
        
        #expect(environment.derivedString == "d:")
        
        environment.testString = "custom value"
        #expect(environment.derivedString == "d:custom value")
    }
    
    // MARK: - Description Test
    
    @Test
    func description() {
        var environment = EnvironmentValues()
        environment.testString = "test description"
        #expect(environment.description.contains("test description"))
    }
    
    // MARK: - PropertyList Tests
    
    @Test
    func propertyListConsistency() {
        var environment = EnvironmentValues()
        environment.testString = "property list test"
        environment.testInt = 300
        let plist = environment.plist
        let newEnvironment = EnvironmentValues(plist)
        #expect(newEnvironment[StringEnvironmentKey.self] == "property list test")
        #expect(newEnvironment[IntEnvironmentKey.self] == 300)
    }
}
