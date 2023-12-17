//
//  DynamicProperty.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/11/2.
//  Lastest Version: iOS 15.5
//  Status: WIP

/// An interface for a stored variable that updates an external property of a
/// view.
///
/// The view gives values to these properties prior to recomputing the view's
/// ``View/body-swift.property``.
public protocol DynamicProperty {
    static func _makeProperty<V>(in buffer: inout _DynamicPropertyBuffer, container: _GraphValue<V>, fieldOffset: Int, inputs: inout _GraphInputs)
    static var _propertyBehaviors: UInt32 { get }
    /// Updates the underlying value of the stored value.
    ///
    /// OpenSwiftUI calls this function before rendering a view's
    /// ``View/body-swift.property`` to ensure the view has the most recent
    /// value.
    mutating func update()
}

extension DynamicProperty {
    public static func _makeProperty<V>(in buffer: inout _DynamicPropertyBuffer, container: _GraphValue<V>, fieldOffset: Int, inputs: inout _GraphInputs) {
        makeEmbeddedProperties(in: &buffer, container: container, fieldOffset: fieldOffset, inputs: &inputs)
        // TODO
        buffer.append(EmbeddedDynamicPropertyBox<Self>(), fieldOffset: fieldOffset)
    }

    static func makeEmbeddedProperties<V>(in buffer: inout _DynamicPropertyBuffer, container: _GraphValue<V>, fieldOffset: Int, inputs: inout _GraphInputs) -> () {
        let fields = DynamicPropertyCache.fields(of: self)
        // TODO
        buffer.addFields(fields, container: container, inputs: &inputs, baseOffset: fieldOffset)
    }

    public mutating func update() {}
    public static var _propertyBehaviors: UInt32 { 0 }
}

private struct EmbeddedDynamicPropertyBox<Value: DynamicProperty>: DynamicPropertyBox {
    typealias Property = Value
    func destroy() {}
    func reset() {}
    func update(property: inout Value, phase _: _GraphInputs.Phase) -> Bool {
        property.update()
        return false
    }
}
