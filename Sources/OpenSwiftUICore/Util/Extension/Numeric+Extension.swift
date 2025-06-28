//
//  Numeric+Extension.swift
//  OpenSwiftUICore
//
//  Status: Complete

// MARK: - Numeric Extension [6.5.4]

extension Numeric {
    package var isNaN: Bool {
        self != self
    }

    package var isFinite: Bool {
        (self - self) == 0
    }
}
