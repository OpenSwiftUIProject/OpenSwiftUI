//
//  AnyEquatable.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 5FED8E8437E1C5DEB2554486604823AB (SwiftUICore)

// MARK: - AnyEquatable

package struct AnyEquatable: Equatable {
    private var box: AnyEquatableBox

    package init<T>(_ value: T) where T: Equatable {
        box = _AnyEquatableBox(value)
    }

    package init(hash: StrongHash) {
        box = HashEquatableBox(value: hash)
    }

    package var hash: StrongHash? {
        box.hash
    }

    package static func == (lhs: AnyEquatable, rhs: AnyEquatable) -> Bool {
        lhs.box === rhs.box || lhs.box.isEqual(to: rhs.box)
    }
}

// MARK: - AnyEquatableBox

private class AnyEquatableBox {
    func isEqual(to other: AnyEquatableBox) -> Bool {
        _openSwiftUIBaseClassAbstractMethod()
    }

    var hash: StrongHash? {
        nil
    }
}

private final class _AnyEquatableBox<Value>: AnyEquatableBox where Value: Equatable {
    let value: Value

    init(_ value: Value) {
        self.value = value
    }

    override func isEqual(to other: AnyEquatableBox) -> Bool {
        guard let other = other as? _AnyEquatableBox<Value> else {
            return false
        }
        return value == other.value
    }

    override var hash: StrongHash? {
        makeStableIDData(from: value)
    }
}

private final class HashEquatableBox: AnyEquatableBox {
    let value: StrongHash

    init(value: StrongHash) {
        self.value = value
    }

    override func isEqual(to other: AnyEquatableBox) -> Bool {
        guard let other = other as? HashEquatableBox else {
            return false
        }
        return value == other.value
    }

    override var hash: StrongHash? {
        value
    }
}
