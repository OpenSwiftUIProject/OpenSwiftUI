//
//  FloatingPoint+Extension.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

extension FloatingPoint {
    package func isAlmostEqual(to other: Self, tolerance: Self) -> Bool {

    }

    package func isAlmostEqual(to other: Self) -> Bool {
        isAlmostEqual(to: other, tolerance: .ulpOfOne.squareRoot())
    }

    package func isAlmostZero(absoluteTolerance tolerance: Self) -> Bool {

    }

    package func isAlmostZero() -> Bool {

    }

    package func rescaledAlmostEqual(to other: Self, tolerance: Self) -> Bool {

    }
}
