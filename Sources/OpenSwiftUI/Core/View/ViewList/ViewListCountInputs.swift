//
//  ViewListCountInputs.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

/// Input values to `View._viewListCount()`.
public struct _ViewListCountInputs {
    var customInputs : PropertyList
    var options : _ViewListInputs.Options
    var baseOptions : _GraphInputs.Options
    
    subscript<Input: GraphInput>(_ type: Input.Type) -> Input.Value {
        get { customInputs[type] }
        set { customInputs[type] = newValue }
    }
    
    mutating func append<Input: GraphInput, Value>(_ value: Value, to type: Input.Type) where Input.Value == [Value]  {
        var values = self[type]
        values.append(value)
        self[type] = values
    }
    
    mutating func popLast<Input: GraphInput, Value>(_ type: Input.Type) -> Value? where Input.Value == [Value]  {
        var values = self[type]
        guard let value = values.popLast() else {
            return nil
        }
        self[type] = values
        return value
    }
}
