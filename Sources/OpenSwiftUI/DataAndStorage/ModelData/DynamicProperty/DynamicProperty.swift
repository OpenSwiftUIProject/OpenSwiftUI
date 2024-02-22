//
//  DynamicProperty.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/11/2.
//  Lastest Version: iOS 15.5
//  Status: Complete

/// An interface for a stored variable that updates an external property of a
/// view.
///
/// The view gives values to these properties prior to recomputing the view's
/// ``View/body-swift.property``.
public protocol DynamicProperty {
    static func _makeProperty<Value>(
        in buffer: inout _DynamicPropertyBuffer,
        container: _GraphValue<Value>,
        fieldOffset: Int,
        inputs: inout _GraphInputs
    )
    
    static var _propertyBehaviors: UInt32 { get }
    
    /// Updates the underlying value of the stored value.
    ///
    /// OpenSwiftUI calls this function before rendering a view's
    /// ``View/body-swift.property`` to ensure the view has the most recent
    /// value.
    mutating func update()
}

// MARK: Default implementation for DynamicProperty

extension DynamicProperty {
    public static func _makeProperty<Value>(
        in buffer: inout _DynamicPropertyBuffer,
        container: _GraphValue<Value>,
        fieldOffset: Int,
        inputs: inout _GraphInputs
    ) {
        makeEmbeddedProperties(
            in: &buffer,
            container: container,
            fieldOffset: fieldOffset,
            inputs: &inputs
        )
        buffer.append(
            EmbeddedDynamicPropertyBox<Self>(),
            fieldOffset: fieldOffset
        )
    }
    
    public static var _propertyBehaviors: UInt32 { 0 }
    
    public mutating func update() {}
}

// MARK: - EmbeddedDynamicPropertyBox

private struct EmbeddedDynamicPropertyBox<Value: DynamicProperty>: DynamicPropertyBox {
    typealias Property = Value
    func destroy() {}
    func reset() {}
    func update(property: inout Property, phase _: _GraphInputs.Phase) -> Bool {
        property.update()
        return false
    }
}

extension DynamicProperty {
    static func makeEmbeddedProperties<Value>(
        in buffer: inout _DynamicPropertyBuffer,
        container: _GraphValue<Value>,
        fieldOffset: Int,
        inputs: inout _GraphInputs
    ) -> () {
        let fields = DynamicPropertyCache.fields(of: self)
        buffer.addFields(
            fields,
            container: container,
            inputs: &inputs,
            baseOffset: fieldOffset
        )
    }
}

extension BodyAccessor {
    func makeBody(container: _GraphValue<Container>, inputs: inout _GraphInputs, fields: DynamicPropertyCache.Fields) -> (_GraphValue<Body>, _DynamicPropertyBuffer?) {
        guard Body.self != Never.self else {
            fatalError("\(Body.self) may not have Body == Never")
        }
        withUnsafeMutablePointer(to: &inputs) { inputs in
            // TODO
        }
        fatalError("TODO")
    }
}
