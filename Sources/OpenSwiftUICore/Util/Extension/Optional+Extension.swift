//
//  Optional+Extension.swift
//  OpenSwiftUICore
//
//  Status: Complete

@inlinable
@inline(__always)
func asOptional<Value>(_ value: Value) -> Value? {
    func unwrap<T>() -> T { value as! T }
    let optionalValue: Value? = unwrap()
    return optionalValue
}
