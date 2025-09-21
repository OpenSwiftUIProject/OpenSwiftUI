//
//  ToggleState.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package enum ToggleState: UInt {
    case on
    case off
    case mixed

    package init(_ isOn: Bool) {
        self = isOn ? .on : .off
    }

    package mutating func toggle() {
        self = self == .on ? .off : .on
    }

    package static func stateFor<T, C>(
        item: T,
        in collection: C
    ) -> ToggleState where T: Equatable, C: Collection, C.Element == Binding<T> {
        if collection.allSatisfy({ item == $0.wrappedValue }) {
            return .on
        } else if collection.allSatisfy({ item != $0.wrappedValue }) {
            return .off
        } else {
            return .mixed
        }
    }
}

extension ToggleState: Codable {}

extension ToggleState: CaseIterable {}

extension ToggleState: StronglyHashable {}

extension ToggleState: CustomDebugStringConvertible {
    package var debugDescription: String {
        switch self {
        case .on: "on"
        case .off: "off"
        case .mixed: "mixed"
        }
    }
}
