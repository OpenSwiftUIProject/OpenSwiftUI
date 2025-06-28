//
//  GesturePhase.swift
//  OpenSwiftUICore
//
//  Status: Complete

// MARK: - GesturePhase [6.5.4]

@_spi(ForOnlySwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
public enum GesturePhase<Wrapped> {
    case possible(Wrapped?)
    case active(Wrapped)
    case ended(Wrapped)
    case failed
}

@_spi(ForOnlySwiftUIOnly)
@available(*, unavailable)
extension GesturePhase: Sendable {}

@_spi(ForOnlySwiftUIOnly)
extension GesturePhase: Equatable where Wrapped: Equatable {}

@_spi(ForOnlySwiftUIOnly)
extension GesturePhase {
    package var unwrapped: Wrapped? {
        switch self {
        case let .possible(value): value
        case let .active(value): value
        case let .ended(value): value
        case .failed: nil
        }
    }

    package func map<T>(_ body: (Wrapped) -> T) -> GesturePhase<T> {
        switch self {
        case let .possible(value): .possible(value.map(body))
        case let .active(value): .active(body(value))
        case let .ended(value): .ended(body(value))
        case .failed: .failed
        }
    }

    package func withValue<T>(_ value: @autoclosure () -> T) -> GesturePhase<T> {
        map { _ in value() }
    }

    package var isPossible: Bool {
        guard case .possible = self else {
            return false
        }
        return true
    }

    package var isActive: Bool {
        guard case .active = self else {
            return false
        }
        return true
    }

    package var isTerminal: Bool {
        switch self {
        case .possible, .active: false
        case .ended, .failed: true
        }
    }

    package var isEnded: Bool {
        guard case .ended = self else {
            return false
        }
        return true
    }

    package var isFailed: Bool {
        guard case .failed = self else {
            return false
        }
        return true
    }
}

// MARK: - GesturePhase + Defaultable [6.5.4]

@_spi(ForOnlySwiftUIOnly)
extension GesturePhase: Defaultable {
    package static var defaultValue: GesturePhase<Wrapped> { .failed }
}

// MARK: - GestureCategory + Defaultable [6.5.4]

@_spi(ForOnlySwiftUIOnly)
extension GestureCategory: Defaultable {
    package static var defaultValue: GestureCategory { .magnify }
}
