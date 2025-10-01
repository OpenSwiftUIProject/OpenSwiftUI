//
//  AnyHashable2.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete
//  ID: 12EE2013F9611424839A13CDF1FE08D2 (SwiftUICore)

fileprivate class AnyHashableBox {
    func `as`<T>(type: T.Type) -> T? where T: Hashable { nil }
    var description: String { "" }
    var anyValue: any Hashable { _openSwiftUIBaseClassAbstractMethod() }
    func isEqual(to other: AnyHashableBox) -> Bool { false }
    func hash(into hasher: inout Hasher) {}
}

fileprivate class _AnyHashableBox<Value>: AnyHashableBox where Value: Hashable {
    let value: Value
    
    init(_ value: Value) {
        self.value = value
    }
    
    override func `as`<T>(type: T.Type) -> T? where T: Hashable {
        value as? T
    }
    
    override var description: String {
        String(describing: value)
    }
    
    override var anyValue: any Hashable {
        value
    }
    
    override func isEqual(to other: AnyHashableBox) -> Bool {
        guard let otherBox = other as? _AnyHashableBox<Value> else {
            return false
        }
        return value == otherBox.value
    }
    
    override func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(Value.self))
        hasher.combine(value)
    }
}

package struct AnyHashable2: Hashable, CustomStringConvertible {
    private var box: AnyHashableBox
    
    package init<T>(_ value: T) where T: Hashable {
        box = _AnyHashableBox(value)
    }
    
    package func `as`<T>(type: T.Type) -> T? where T: Hashable {
        box.as(type: type)
    }
    
    package var anyValue: any Hashable {
        box.anyValue
    }
    
    package var anyHashable: AnyHashable {
        AnyHashable(box.anyValue)
    }
    
    package var description: String {
        box.description
    }
    
    package static func == (lhs: AnyHashable2, rhs: AnyHashable2) -> Bool {
        guard lhs.box !== rhs.box else {
            return true
        }
        return lhs.box.isEqual(to: rhs.box)
    }
      
    package func hash(into hasher: inout Hasher) {
        box.hash(into: &hasher)
    }
}

extension AnyHashable2: _HasCustomAnyHashableRepresentation {
    package func _toCustomAnyHashable() -> AnyHashable? {
        anyHashable
    }
}
