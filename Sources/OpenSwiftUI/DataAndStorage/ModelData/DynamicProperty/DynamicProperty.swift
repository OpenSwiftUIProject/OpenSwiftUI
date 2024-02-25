//
//  DynamicProperty.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/11/2.
//  Lastest Version: iOS 15.5
//  Status: Complete
//  ID: 49D2A32E637CD497C6DE29B8E060A506

internal import OpenGraphShims

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
    ) {
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
    func makeBody(
        container: _GraphValue<Container>,
        inputs: inout _GraphInputs,
        fields: DynamicPropertyCache.Fields
    ) -> (_GraphValue<Body>, _DynamicPropertyBuffer?) {
        guard Body.self != Never.self else {
            fatalError("\(Body.self) may not have Body == Never")
        }
        return withUnsafeMutablePointer(to: &inputs) { inputsPointer in
            func project<Flags: RuleThreadFlags>(flags _: Flags.Type) -> (_GraphValue<Body>, _DynamicPropertyBuffer?) {
                let buffer = _DynamicPropertyBuffer(
                    fields: fields,
                    container: container,
                    inputs: &inputsPointer.pointee
                )
                if buffer._count == 0 {
                    buffer.destroy()
                    let body = StaticBody<Self, Flags>(
                        accessor: self,
                        container: container.value
                    )
                    return (_GraphValue(body), nil)
                } else {
                    let body = DynamicBody<Self, Flags>(
                        accessor: self,
                        container: container.value,
                        phase: inputsPointer.pointee.phase,
                        links: buffer,
                        resetSeed: 0
                    )
                    return (_GraphValue(body), buffer)
                }
            }
            if fields.behaviors.contains(.asyncThread) {
                return project(flags: AsyncThreadFlags.self)
            } else {
                return project(flags: MainThreadFlags.self)
            }
        }
    }
}

// MARK: - RuleThreadFlags

private protocol RuleThreadFlags {
    static var value: OGAttributeTypeFlags { get }
}

private struct AsyncThreadFlags: RuleThreadFlags {
    static var value: OGAttributeTypeFlags { .asyncThread }
}

private struct MainThreadFlags: RuleThreadFlags {
    static var value: OGAttributeTypeFlags { .mainThread }
}

// MARK: - StaticBody

private struct StaticBody<Accessor: BodyAccessor, ThreadFlags: RuleThreadFlags> {
    let accessor: Accessor
    @Attribute
    var container: Accessor.Container
    
    init(accessor: Accessor, container: Attribute<Accessor.Container>) {
        self.accessor = accessor
        self._container = container
    }
}

extension StaticBody: StatefulRule {
    typealias Value = Accessor.Body

    func updateValue() {
        accessor.updateBody(of: container, changed: true)
    }
}

extension StaticBody: _AttributeBody {
    static var flags: OGAttributeTypeFlags {
        ThreadFlags.value
    }
}

extension StaticBody: BodyAccessorRule {
    static var container: Any.Type {
        Accessor.Container.self
    }
    
    static func buffer<Value>(as type: Value.Type, attribute: OGAttribute) -> _DynamicPropertyBuffer? {
        nil
    }
    
    static func value<Value>(as type: Value.Type, attribute: OGAttribute) -> Value? {
        guard container == type else {
            return nil
        }
        return (attribute.info.body.assumingMemoryBound(to: Self.self).pointee.container as! Value)
    }
    
    static func metaProperties<Value>(as type: Value.Type, attribute: OGAttribute) -> [(String, OGAttribute)] {
        guard container == type else {
            return []
        }
        return [("@self", attribute.info.body.assumingMemoryBound(to: Self.self).pointee._container.identifier)]
    }
}

extension StaticBody: CustomStringConvertible {
    var description: String { "\(Accessor.Body.self)" }
}

// MARK: - DynamicBody

// TODO
private struct DynamicBody<Accessor: BodyAccessor, ThreadFlags: RuleThreadFlags> {
    let accessor: Accessor
    @Attribute
    var container: Accessor.Container
    @Attribute
    var phase: _GraphInputs.Phase
    var links: _DynamicPropertyBuffer
    var resetSeed: UInt32
    
    init(
        accessor: Accessor,
        container: Attribute<Accessor.Container>,
        phase: Attribute<_GraphInputs.Phase>,
        links: _DynamicPropertyBuffer,
        resetSeed: UInt32
    ) {
        fatalError("TODO")
//        self.accessor = accessor
//        self._container = container
//        self._phase = phase
//        self.links = links
//        self.resetSeed = resetSeed
    }
}

extension DynamicBody: StatefulRule {
    typealias Value = Accessor.Body

    func updateValue() {
        // TODO
    }
}
