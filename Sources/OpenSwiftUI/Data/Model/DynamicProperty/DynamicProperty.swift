//
//  DynamicProperty.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
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
        #if canImport(Darwin)
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
        #else
        fatalError("See #39")
        #endif
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

#if canImport(Darwin)

// MARK: - StaticBody

private struct StaticBody<Accessor: BodyAccessor, ThreadFlags: RuleThreadFlags> {
    let accessor: Accessor
    @Attribute var container: Accessor.Container
    
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
    
    static var flags: OGAttributeTypeFlags { ThreadFlags.value }
}

extension StaticBody: BodyAccessorRule {
    static var container: Any.Type {
        Accessor.Container.self
    }
    
    static func value<Value>(as _: Value.Type, attribute: OGAttribute) -> Value? {
        guard container == Value.self else {
            return nil
        }
        return unsafeBitCast(attribute.info.body.assumingMemoryBound(to: Self.self).pointee.container, to: Value.self)
    }
    
    static func buffer<Value>(as _: Value.Type, attribute _: OGAttribute) -> _DynamicPropertyBuffer? {
        nil
    }
    
    static func metaProperties<Value>(as _: Value.Type, attribute: OGAttribute) -> [(String, OGAttribute)] {
        guard container == Value.self else {
            return []
        }
        return [("@self", attribute.info.body.assumingMemoryBound(to: Self.self).pointee._container.identifier)]
    }
}
extension StaticBody: CustomStringConvertible {
    var description: String { "\(Accessor.Body.self)" }
}

// MARK: - DynamicBody

private struct DynamicBody<Accessor: BodyAccessor, ThreadFlags: RuleThreadFlags> {
    let accessor: Accessor
    @Attribute var container: Accessor.Container
    @Attribute var phase: _GraphInputs.Phase
    var links: _DynamicPropertyBuffer
    var resetSeed: UInt32
    
    init(
        accessor: Accessor,
        container: Attribute<Accessor.Container>,
        phase: Attribute<_GraphInputs.Phase>,
        links: _DynamicPropertyBuffer,
        resetSeed: UInt32
    ) {
        self.accessor = accessor
        self._container = container
        self._phase = phase
        self.links = links
        self.resetSeed = resetSeed
    }
}

extension DynamicBody: StatefulRule {
    typealias Value = Accessor.Body

    mutating func updateValue() {
        if resetSeed != phase.seed {
            links.reset()
            resetSeed = phase.seed
        }
        var (container, containerChanged) = $container.changedValue()
        let linkChanged = withUnsafeMutablePointer(to: &container) {
            links.update(container: $0, phase: phase)
        }
        let changed = linkChanged || containerChanged || !hasValue
        accessor.updateBody(of: container, changed: changed)
    }
    
    static var flags: OGAttributeTypeFlags { ThreadFlags.value }
}

extension DynamicBody: ObservedAttribute {
    func destroy() { links.destroy() }
}

extension DynamicBody: BodyAccessorRule {
    static var container: Any.Type {
        Accessor.Container.self
    }
    
    static func value<Value>(as _: Value.Type, attribute: OGAttribute) -> Value? {
        guard container == Value.self else {
            return nil
        }
        return unsafeBitCast(attribute.info.body.assumingMemoryBound(to: Self.self).pointee.container, to: Value.self)
    }
    
    static func buffer<Value>(as _: Value.Type, attribute: OGAttribute) -> _DynamicPropertyBuffer? {
        guard container == Value.self else {
            return nil
        }
        return attribute.info.body.assumingMemoryBound(to: Self.self).pointee.links
    }
    
    static func metaProperties<Value>(as _: Value.Type, attribute: OGAttribute) -> [(String, OGAttribute)] {
        guard container == Value.self else {
            return []
        }
        return [
            ("@self", attribute.info.body.assumingMemoryBound(to: Self.self).pointee._container.identifier),
            ("@identity", attribute.info.body.assumingMemoryBound(to: Self.self).pointee._phase.identifier)
        ]
    }
}

extension DynamicBody: CustomStringConvertible {
    var description: String { "\(Accessor.Body.self)" }
}

#endif
