//
//  Sequence+Extension.swift
//  OpenSwiftUICore
//
//  Status: Complete

// MARK: - Sequence Extension [6.5.4]

extension Sequence {
    package func first<T>(ofType: T.Type) -> T? {
        first { $0 is T } as? T
    }
}
