//
//  Optional+Extension.swift
//  OpenSwiftUICore
//
//  Status: Complete

// MARK: - Optional + if-then

extension Optional {
    package init(if condition: Bool, then value: @autoclosure () -> Wrapped) {
        self = condition ? value() : nil
    }
}
