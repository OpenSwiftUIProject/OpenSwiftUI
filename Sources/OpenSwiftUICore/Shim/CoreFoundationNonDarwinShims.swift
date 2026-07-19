//
//  CoreFoundationNonDarwinShims.swift
//  OpenSwiftUICore

#if canImport(CoreFoundation) && !canImport(ObjectiveC)
public import CoreFoundation

extension CFDictionary: @retroactive Swift.Hashable {
    public static func == (lhs: CFDictionary, rhs: CFDictionary) -> Bool {
        CFEqual(lhs, rhs)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(CFHash(self))
    }
}
#endif
