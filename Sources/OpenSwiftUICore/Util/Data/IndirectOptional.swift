//
//  IndirectOptional.swift
//  OpenSwiftUICore
//
//  Status: Complete

// MARK: - IndirectOptional [6.5.4]

@propertyWrapper
package enum IndirectOptional<Wrapped>: ExpressibleByNilLiteral {
    case none
    indirect case some(Wrapped)

    package init(_ value: Wrapped) {
        self = .some(value)
    }

    package init(nilLiteral: ()) {
        self = .none
    }

    package init(wrappedValue: Wrapped?) {
        if let value = wrappedValue {
            self = .some(value)
        } else {
            self = .none
        }
    }

    package var wrappedValue: Wrapped? {
        switch self {
        case .none: nil
        case let .some(wrapped): wrapped
        }
    }
}

extension IndirectOptional: Equatable where Wrapped: Equatable {}

extension IndirectOptional: Hashable where Wrapped: Hashable {}
