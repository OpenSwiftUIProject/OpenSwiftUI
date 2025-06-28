//
//  Integer+Extension.swift
//  OpenSwiftUICore
//
//  Status: Complete

// MARK: - unsafeIncrement [6.5.4]

extension UInt32 {
    package mutating func unsafeIncrement() {
        self = self &+ 1
    }
}

// MARK: - FixedWidthInteger + clamping [6.5.4]

extension FixedWidthInteger {
    package init<T>(clamping value: T) where T: BinaryFloatingPoint {
        self.init(value.clamp(min: T(Self.min), max: T(Self.max)))
    }
}
