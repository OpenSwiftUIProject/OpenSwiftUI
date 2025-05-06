//
//  EnvironmentKey+Test.swift
//  OpenSwiftUITestsSupport

package import OpenSwiftUI

package struct StringEnvironmentKey: EnvironmentKey {
    package static var defaultValue: String { "" }
}

package struct IntEnvironmentKey: EnvironmentKey {
    package static var defaultValue: Int { 0 }
}

package struct BoolEnvironmentKey: EnvironmentKey {
    package static var defaultValue: Bool { false }
}

package struct DerivedStringEnvironmentKey: DerivedEnvironmentKey {
    package static func value(in environment: EnvironmentValues) -> String {
        "d:\(environment[StringEnvironmentKey.self])"
    }
}

package struct OptionalStringEnvironmentKey: EnvironmentKey {
    package static let defaultValue: String? = nil
}

package struct CustomStructEnvironmentKey: EnvironmentKey {
    package struct CustomStruct {
        package let value: Int
        
        package init(value: Int) {
            self.value = value
        }
    }
    
    package static let defaultValue = CustomStruct(value: 100)
}
