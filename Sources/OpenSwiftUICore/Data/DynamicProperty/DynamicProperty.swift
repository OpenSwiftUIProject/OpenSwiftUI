//
//  DynamicProperty.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 49D2A32E637CD497C6DE29B8E060A506 (SwiftUI)
//  ID: A4C1D658B3717A3062FEFC91A812D6EB (SwiftUICore)

package import OpenAttributeGraphShims

// MARK: - DynamicProperty [6.5.4]

/// An interface for a stored variable that updates an external property of a
/// view.
///
/// The view gives values to these properties prior to recomputing the view's
/// ``View/body-swift.property``.
@available(OpenSwiftUI_v1_0, *)
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
    @available(OpenSwiftUI_v3_0, *)
    static var _propertyBehaviors: UInt32 { get }

    /// Updates the underlying value of the stored value.
    ///
    /// OpenSwiftUI calls this function before rendering a view's
    /// ``View/body-swift.property`` to ensure the view has the most recent
    /// value.
    mutating func update()
}

// MARK: - DynamicPropertyBehaviors [6.5.4]

package struct DynamicPropertyBehaviors: OptionSet {
    package let rawValue: UInt32

    package static let allowsAsync = DynamicPropertyBehaviors(rawValue: 1 << 0)

    package static let requiresMainThread  = DynamicPropertyBehaviors(rawValue: 1 << 1)

    package init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

// MARK: - DynamicPropertyBox [6.5.4]

package protocol DynamicPropertyBox<Property>: DynamicProperty {
    associatedtype Property: DynamicProperty

    mutating func destroy()

    mutating func reset()

    mutating func update(property: inout Property, phase: ViewPhase) -> Bool

    func getState<Value>(type: Value.Type) -> Binding<Value>?
}

// MARK: - Default implementation for DynamicPropertyBox [6.5.4]

extension DynamicPropertyBox {
    package func destroy() {
        _openSwiftUIEmptyStub()
    }

    package func reset() {
        _openSwiftUIEmptyStub()
    }

    package func getState<S>(type: S.Type = S.self) -> Binding<S>? {
        nil
    }
}

// MARK: - Default implementation for DynamicProperty [6.5.4]

private struct EmbeddedDynamicPropertyBox<Value: DynamicProperty>: DynamicPropertyBox {

    typealias Property = Value

    func update(property: inout Property, phase _: ViewPhase) -> Bool {
        property.update()
        return false
    }
}

@available(OpenSwiftUI_v1_0, *)
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
    
    public mutating func update() {
        _openSwiftUIEmptyStub()
    }

    @available(OpenSwiftUI_v3_0, *)
    public static var _propertyBehaviors: UInt32 { 0 }
}

// MARK: - DynamicPropertyCache [6.5.4]

package struct DynamicPropertyCache {
    package struct Fields {
        enum Layout {
            case product([Field])
            case sum(any Any.Type, [TaggedFields])
        }

        var layout: Layout

        package var behaviors: DynamicPropertyBehaviors
        
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

        package func name(at offset: Int) -> String? {
            _name(at: offset).flatMap { String(cString: $0, encoding: .utf8) }
        }

        package func _name(at offset: Int) -> UnsafePointer<Int8>? {
            guard case let .product(fields) = layout else {
                return nil
            }
            return fields.first(where: { $0.offset == offset })?.name
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
    
    package static func fields(of type: any Any.Type) -> Fields {
        let identifier = ObjectIdentifier(type)
        guard let fields = cache.wrappedValue[identifier] else {
            var fields: Fields
            let typeID = Metadata(type)
            switch typeID.kind {
            case .enum, .optional:
                var taggedFields: [TaggedFields] = []
                _ = typeID.forEachField(options: [.continueAfterUnknownField, .enumerateEnumCases]) { name, offset, fieldType in
                    var fields: [Field] = []
                    let tupleType = TupleType(fieldType)
                    for index in tupleType.indices {
                        guard let dynamicPropertyType = tupleType.type(at: index) as? DynamicProperty.Type else {
                            continue
                        }
                        let offset = tupleType.elementOffset(at: index)
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
                _ = typeID.forEachField(options: [.continueAfterUnknownField]) { name, offset, fieldType in
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
            if fields.behaviors.contains([.allowsAsync, .requiresMainThread]) {
                Log.runtimeIssues(
                    "%s is marked async, but contains properties that require the main thread.",
                    ["\(type)"]
                )
                fields.behaviors.subtract(.allowsAsync)
            }
            cache.wrappedValue[identifier] = fields
            return fields
        }
        return fields
    }
}

// MARK: - DynamicProperty + TreeValue [6.5.4]

extension DynamicProperty {
    @inline(__always)
    package static func addTreeValue<T>(
        _ value: Attribute<T>,
        at fieldOffset: Int,
        in container: any Any.Type,
        flags: TreeValueFlags = .init()
    ) {
        guard Subgraph.shouldRecordTree else {
            return
        }
        addTreeValueSlow(
            value.identifier,
            as: T.self,
            in: container,
            fieldOffset: fieldOffset,
            flags: flags
        )
    }

    @inline(__always)
    package static func addTreeValue<T, U>(
        _ value: Attribute<T>,
        as: U.Type,
        at fieldOffset: Int,
        in container: any Any.Type,
        flags: TreeValueFlags = .init()
    ) {
        guard Subgraph.shouldRecordTree else {
            return
        }
        addTreeValueSlow(
            value.identifier,
            as: U.self,
            in: container,
            fieldOffset: fieldOffset,
            flags: flags
        )
    }

    @inline(never)
    package static func addTreeValueSlow<T>(
        _ value: AnyAttribute,
        as type: T.Type,
        in container: any Any.Type,
        fieldOffset: Int,
        flags: TreeValueFlags = .init()
    ) {
        let containerFields = DynamicPropertyCache.fields(of: container)
        "<unknown>".withCString { unknownStringPtr in
            Subgraph.addTreeValue(
                Attribute<T>(identifier: value),
                forKey: containerFields._name(at: fieldOffset) ?? unknownStringPtr,
                flags: flags.rawValue
            )
        }
    }
}

// MARK: - BodyAccessor [6.5.4]

package protocol BodyAccessor<Container, Body> {
    associatedtype Container
    associatedtype Body
    func updateBody(of container: Container, changed: Bool)
}

extension BodyAccessor {
    package func makeBody(
        container: _GraphValue<Container>,
        inputs: inout _GraphInputs,
        fields: DynamicPropertyCache.Fields
    ) -> (_GraphValue<Body>, _DynamicPropertyBuffer?) {
        guard Body.self != Never.self else {
            preconditionFailure("\(Container.self) may not have Body == Never")
        }
        return withUnsafePointer(to: inputs) { pointer in
            func project<Flags>(flags _: Flags.Type) -> (_GraphValue<Body>, _DynamicPropertyBuffer?) where Flags: RuleThreadFlags {
                let buffer = _DynamicPropertyBuffer(
                    fields: fields,
                    container: container,
                    inputs: &inputs
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
                        phase: pointer.pointee.phase,
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
    }

    @inline(__always)
    package func setBody(_ body: () -> Body) {
        let value = traceRuleBody(Container.self) {
            Graph.withoutUpdate(body)
        }
        withUnsafePointer(to: value) { value in
            Graph.setOutputValue(value)
        }
    }
}

// MARK: - BodyAccessorRule [6.5.4]

package protocol BodyAccessorRule {
    static var container: Any.Type { get }
    static func value<T>(as: T.Type, attribute: AnyAttribute) -> T?
    static func buffer<T>(as: T.Type, attribute: AnyAttribute) -> _DynamicPropertyBuffer?
    static func metaProperties<T>(as: T.Type, attribute: AnyAttribute) -> [(String, AnyAttribute)]
}

// MARK: - RuleThreadFlags [6.5.4]

private protocol RuleThreadFlags {
    static var value: _AttributeType.Flags { get }
}

private struct AsyncThreadFlags: RuleThreadFlags {
    static var value: _AttributeType.Flags { .asyncThread }
}

private struct MainThreadFlags: RuleThreadFlags {
    static var value: _AttributeType.Flags { .mainThread }
}

// MARK: - StaticBody [6.5.4]

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
        withObservation {
            accessor.updateBody(of: container, changed: true)
        }
    }
    
    static var flags: Flags { ThreadFlags.value }
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

// MARK: - DynamicBody [6.5.4]

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
        var (container, changed) = $container.changedValue()
        withObservation {
            withUnsafeMutablePointer(to: &container) {
                if links.update(container: $0, phase: phase) {
                    changed = true
                }
            }
            accessor.updateBody(
                of: container,
                changed: changed || !hasValue || AnyAttribute.currentWasModified
            )
        }
    }

    static var flags: Flags { ThreadFlags.value }
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
