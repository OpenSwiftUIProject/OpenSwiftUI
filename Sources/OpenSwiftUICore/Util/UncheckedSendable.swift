//
//  UncheckedSendable.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package struct UncheckedSendable<Value>: @unchecked Sendable {
    package var value: Value

    package init(_ value: Value) {
        self.value = value
    }
}

extension UncheckedSendable: Equatable where Value: Equatable {}

extension UncheckedSendable: Hashable where Value: Hashable {}

package struct WeakUncheckedSendable<Value>: @unchecked Sendable where Value: AnyObject {
    package weak var value: Value?

    package init(_ value: Value) {
        self.value = value
    }
}
