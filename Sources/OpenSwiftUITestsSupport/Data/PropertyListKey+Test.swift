//
//  PropertyListKey+Test.swift
//  OpenSwiftUITestsSupport

#if OPENSWIFTUI
package import OpenSwiftUI

package struct BoolKey: PropertyKey {
    package static let defaultValue = false
}

package struct IntKey: PropertyKey {
    package static let defaultValue = 0
}

package struct StringKey: PropertyKey {
    package static var defaultValue: String { "" }
}

package struct DerivedIntPlus2Key: DerivedPropertyKey {
    package static func value(in plist: PropertyList) -> Int {
        plist[IntKey.self] + 2
    }
}

package struct DerivedStringKey: DerivedPropertyKey {
    package static func value(in plist: PropertyList) -> String {
        "d:" + plist[StringKey.self]
    }
}

package struct StringFromIntLookup: PropertyKeyLookup {
    package struct Primary: PropertyKey {
        package static var defaultValue: String { "" }
    }

    package struct Secondary: PropertyKey {
        package static var defaultValue: Int { 0 }
    }

    package static func lookup(in value: Int) -> String? {
        value == Secondary.defaultValue ? nil : "\(value)"
    }
}
#endif
