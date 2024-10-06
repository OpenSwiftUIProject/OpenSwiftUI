//
//  DynamicProperty.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2024
//  Status: Complete
//  ID: 49D2A32E637CD497C6DE29B8E060A506 (RELEASE_2021)
//  ID: A4C1D658B3717A3062FEFC91A812D6EB (RELEASE_2024)

internal import OpenGraphShims

// MARK: - DynamicProperty

/// An interface for a stored variable that updates an external property of a
/// view.
///
/// The view gives values to these properties prior to recomputing the view's
/// ``View/body-swift.property``.
public protocol DynamicProperty {
    /// Creates an instance of the dynamic `View` property
    /// represented by `self`.
    static func _makeProperty<Value>(
        in buffer: inout _DynamicPropertyBuffer,
        container: _GraphValue<Value>,
        fieldOffset: Int,
        inputs: inout _GraphInputs
    )
    
    /// Describes the static behaviors of the property type. Returns
    ///  a raw integer value from DynamicPropertyBehaviors.
    static var _propertyBehaviors: UInt32 { get }
    
    /// Updates the underlying value of the stored value.
    ///
    /// OpenSwiftUI calls this function before rendering a view's
    /// ``View/body-swift.property`` to ensure the view has the most recent
    /// value.
    mutating func update()
}

// MARK: - DynamicPropertyBehaviors

package struct DynamicPropertyBehaviors: OptionSet {
    package let rawValue: UInt32
    package static let allowsAsync = DynamicPropertyBehaviors(rawValue: 1 << 0)
    package static let requiresMainThread  = DynamicPropertyBehaviors(rawValue: 1 << 1)
    
    package init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

// MARK: - DynamicPropertyBox

package protocol DynamicPropertyBox<Property>: DynamicProperty {
    associatedtype Property: DynamicProperty
    mutating func destroy()
    mutating func reset()
    mutating func update(property: inout Property, phase: ViewPhase) -> Bool
    func getState<Value>(type: Value.Type) -> Binding<Value>?
}

// MARK: - Default implementation for DynamicPropertyBox

extension DynamicPropertyBox {
    package func destroy() {}
    package func reset() {}
    package func getState<S>(type: S.Type = S.self) -> Binding<S>? { nil }
}

// MARK: - Default implementation for DynamicProperty

private struct EmbeddedDynamicPropertyBox<Value: DynamicProperty>: DynamicPropertyBox {
    typealias Property = Value
    func update(property: inout Property, phase _: ViewPhase) -> Bool {
        property.update()
        return false
    }
}

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
    
    public mutating func update() {}
    
    public static var _propertyBehaviors: UInt32 { 0 }
}

// MARK: - DynamicPropertyCache [2021]

package struct DynamicPropertyCache {
    package struct Fields {
        var layout: Layout
        package var behaviors: DynamicPropertyBehaviors

        enum Layout {
            case product([Field])
            case sum(Any.Type, [TaggedFields])
        }
        
        init(layout: Layout) {
            var behaviors: UInt32 = 0
            switch layout {
            case let .product(fields):
                for field in fields {
                    behaviors |= field.type._propertyBehaviors
                }
            case let .sum(_, taggedFields):
                for taggedField in taggedFields {
                    for field in taggedField.fields {
                        behaviors |= field.type._propertyBehaviors
                    }
                }
            }
            self.layout = layout
            self.behaviors = .init(rawValue: behaviors)
        }
    }
    
    struct Field {
        var type: DynamicProperty.Type
        var offset: Int
        var name: UnsafePointer<Int8>?
    }
    
    struct TaggedFields {
        var tag: Int
        var fields: [Field]
    }
    
    private static var cache = MutableBox([ObjectIdentifier: Fields]())
    
    package static func fields(of type: Any.Type) -> Fields {
        if let fields = cache.wrappedValue[ObjectIdentifier(type)] {
            return fields
        }
        let fields: Fields
        let typeID = OGTypeID(type)
        switch typeID.kind {
        case .enum, .optional:
            var taggedFields: [TaggedFields] = []
            _ = typeID.forEachField(options: [._2, ._4]) { name, offset, fieldType in
                var fields: [Field] = []
                let tupleType = OGTupleType(fieldType)
                for index in tupleType.indices {
                    guard let dynamicPropertyType = tupleType.type(at: index) as? DynamicProperty.Type else {
                        break
                    }
                    let offset = tupleType.offset(at: index)
                    let field = Field(type: dynamicPropertyType, offset: offset, name: name)
                    fields.append(field)
                }
                if !fields.isEmpty {
                    let taggedField = TaggedFields(tag: offset, fields: fields)
                    taggedFields.append(taggedField)
                }
                return true
            }
            fields = Fields(layout: .sum(type, taggedFields))
        case .struct, .tuple:
            var fieldArray: [Field] = []
            _ = typeID.forEachField(options: [._2]) { name, offset, fieldType in
                guard let dynamicPropertyType = fieldType as? DynamicProperty.Type else {
                    return true
                }
                let field = Field(type: dynamicPropertyType, offset: offset, name: name)
                fieldArray.append(field)
                return true
            }
            fields = Fields(layout: .product(fieldArray))
        default:
            fields = Fields(layout: .product([]))
        }
        if fields.behaviors.contains(.init(rawValue: 3)) {
            Log.runtimeIssues("%s is marked async, but contains properties that require the main thread.", ["\(type)"])
        }
        cache.wrappedValue[ObjectIdentifier(type)] = fields
        return fields
    }
}

// TO BE AUDITED

extension BodyAccessor {
    package func makeBody(
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
            if fields.behaviors.contains(.allowsAsync) {
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
    
    static func value<Value>(as _: Value.Type, attribute: AnyAttribute) -> Value? {
        guard container == Value.self else {
            return nil
        }
        return unsafeBitCast(attribute.info.body.assumingMemoryBound(to: Self.self).pointee.container, to: Value.self)
    }
    
    static func buffer<Value>(as _: Value.Type, attribute _: AnyAttribute) -> _DynamicPropertyBuffer? {
        nil
    }
    
    static func metaProperties<Value>(as _: Value.Type, attribute: AnyAttribute) -> [(String, AnyAttribute)] {
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
        if resetSeed != phase.resetSeed {
            links.reset()
            resetSeed = phase.resetSeed
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
    
    static func value<Value>(as _: Value.Type, attribute: AnyAttribute) -> Value? {
        guard container == Value.self else {
            return nil
        }
        return unsafeBitCast(attribute.info.body.assumingMemoryBound(to: Self.self).pointee.container, to: Value.self)
    }
    
    static func buffer<Value>(as _: Value.Type, attribute: AnyAttribute) -> _DynamicPropertyBuffer? {
        guard container == Value.self else {
            return nil
        }
        return attribute.info.body.assumingMemoryBound(to: Self.self).pointee.links
    }
    
    static func metaProperties<Value>(as _: Value.Type, attribute: AnyAttribute) -> [(String, AnyAttribute)] {
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
