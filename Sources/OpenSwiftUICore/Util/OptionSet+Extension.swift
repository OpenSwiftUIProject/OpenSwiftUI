//
//  OptionSet+Extension.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

extension OptionSet {
    @inlinable
    package mutating func setValue(_ value: Bool, for set: Self) {
        if value {
            formUnion(set)
        } else {
            subtract(set)
        }
    }
}
