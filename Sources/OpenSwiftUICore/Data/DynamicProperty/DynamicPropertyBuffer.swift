//
//  DynamicPropertyBuffer.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 68550FF604D39F05971FE35A26EE75B0 (SwiftUI)
//  ID: F3A89CF4357225EF49A7DD673FDFEE02 (SwiftUICore)

import OpenAttributeGraphShims

#if OPENSWIFTUI_SUPPORT_2024_API

// MARK: - DynamicPropertyBuffer [6.5.4]

/// Unsafe storage type for `DynamicProperty` instances.
@available(OpenSwiftUI_v1_0, *)
public struct _DynamicPropertyBuffer {
    private var contents: UnsafeHeterogeneousBuffer

    package init() {
        contents = .init()
    }

    package init<T>(
        fields: DynamicPropertyCache.Fields,
        container: _GraphValue<T>,
        inputs: inout _GraphInputs,
        baseOffset: Int
    ) {
        self.init()
        addFields(fields, container: container, inputs: &inputs, baseOffset: baseOffset)
    }

    package init<T>(
        fields: DynamicPropertyCache.Fields,
        container: _GraphValue<T>,
        inputs: inout _GraphInputs
    ) {
        self.init(fields: fields, container: container, inputs: &inputs, baseOffset: 0)
    }

    package var isEmpty: Bool {
        contents.isEmpty
    }

    package mutating func addFields<T>(
        _ fields: DynamicPropertyCache.Fields,
        container: _GraphValue<T>,
        inputs: inout _GraphInputs,
        baseOffset: Int
    ) {
        switch fields.layout {
        case let .product(fieldArray):
            for field in fieldArray {
                field.type._makeProperty(
                    in: &self,
                    container: container,
                    fieldOffset: field.offset &+ baseOffset,
                    inputs: &inputs
                )
            }
        case let .sum(type, taggedFields):
            guard !taggedFields.isEmpty else {
                return
            }
            let box = EnumBox(
                cases: taggedFields.map { taggedField in
                    (
                        taggedField.tag,
                        _DynamicPropertyBuffer(
                            fields: DynamicPropertyCache.Fields(layout: .product(taggedField.fields)),
                            container: container,
                            inputs: &inputs,
                            baseOffset: 0
                        )
                    )
                },
                active: nil
            )
            func project<Enum>(type _: Enum.Type) {
                let index = contents.append(box, vtable: EnumVTable<Enum>.self)
                contents[index].flags.fieldOffset = Int32(baseOffset)
            }
            _openExistential(type, do: project)
        }
    }

    package mutating func append<T>(_ box: T, fieldOffset: Int) where T: DynamicPropertyBox {
        let index = contents.append(box, vtable: BoxVTable<T>.self)
        contents[index].flags.fieldOffset =  Int32(fieldOffset)
    }

    package func destroy() {
        if Signpost.linkCreate.isEnabled {
            for element in contents {
                traceLinkDestroy(address: element.address)
            }
        }
        contents.destroy()
    }

    package func reset() {
        for element in contents {
            element.vtable(as: BoxVTableBase.self)
                .reset(elt: element)
        }
    }

    package func traceMountedProperties<T>(
        to graphValue: _GraphValue<T>,
        fields: DynamicPropertyCache.Fields
    ) {
        if Signpost.linkCreate.isEnabled {
            let type = String(describing: T.self)
            let typeLibrary = Tracing.libraryName(defining: T.self)
            let identifier = graphValue.value.identifier.rawValue
            let identity = graphValue.value.graph.graphIdentity()
            if case let .product(fieldsArray) = fields.layout {
                for (index, element) in contents.enumerated() {
                    guard index != fieldsArray.count else {
                        return
                    }
                    traceLinkCreate(
                        field: fieldsArray[index],
                        address: element.address,
                        type: type,
                        typeLibrary: typeLibrary,
                        identifier: identifier,
                        identity: identity
                    )
                }
            }
        }
    }

    package func update(container: UnsafeMutableRawPointer, phase: ViewPhase) -> Bool {
        var changed = false
        for element in contents {
            let updateResult = element.vtable(as: BoxVTableBase.self)
                .update(
                    elt: element,
                    property: container.advanced(by: Int(element.flags.fieldOffset)),
                    phase: phase
                )
            element.flags.lastChanged = updateResult
            changed = changed || updateResult
        }
        return changed
    }

    package func getState<S>(type: S.Type = S.self) -> Binding<S>? {
        for element in contents {
            guard let binding = element.vtable(as: BoxVTableBase.self)
                .getState(elt: element, type: type) else {
                continue
            }
            return binding
        }
        return nil

    }

    package func applyChanged(to body: (Int) -> Void) {
        for element in contents {
            if element.flags.lastChanged {
                body(Int(element.flags.fieldOffset))
            }
        }
    }
}

extension UInt32 {
    @inline(__always)
    private static var fieldOffsetMask: UInt32 { 0x7FFF_FFFF }

    fileprivate var fieldOffset: Int32 {
        get { Int32(bitPattern: self & Self.fieldOffsetMask) }
        set { self = UInt32(newValue) | (self & ~Self.fieldOffsetMask) }
    }

    @inline(__always)
    private static var lastChangedMask: UInt32 { 0x8000_0000 }

    fileprivate var lastChanged: Bool {
        get { (self & Self.lastChangedMask) == Self.lastChangedMask }
        set {
            if newValue {
                self |= Self.lastChangedMask
            } else {
                self &= ~Self.lastChangedMask
            }
        }
    }
}

@available(*, unavailable)
extension _DynamicPropertyBuffer: Sendable {}

#else

// MARK: - DynamicPropertyBuffer [3.5.2]

private let nullPtr: UnsafeMutableRawPointer = Unmanaged.passUnretained(unsafeBitCast(0, to: AnyObject.self)).toOpaque()

/// Unsafe storage type for `DynamicProperty` instances.
@available(OpenSwiftUI_v1_0, *)
public struct _DynamicPropertyBuffer {
    private(set) var buf: UnsafeMutableRawPointer
    private(set) var size: Int32
    private(set) var _count: Int32

    package init() {
        buf = nullPtr
        size = 0
        _count = 0
    }

    package init<Value>(
        fields: DynamicPropertyCache.Fields,
        container: _GraphValue<Value>,
        inputs: inout _GraphInputs,
        baseOffset: Int = 0
    ) {
        self.init()
        addFields(fields, container: container, inputs: &inputs, baseOffset: baseOffset)
    }

    package var isEmpty: Bool {
        _count == 0
    }

    package mutating func addFields<Value>(
        _ fields: DynamicPropertyCache.Fields,
        container: _GraphValue<Value>,
        inputs: inout _GraphInputs,
        baseOffset: Int
    ) {
        switch fields.layout {
        case let .product(fieldArray):
            for field in fieldArray {
                field.type._makeProperty(
                    in: &self,
                    container: container,
                    fieldOffset: field.offset &+ baseOffset,
                    inputs: &inputs
                )
            }
        case let .sum(type, taggedFields):
            guard !taggedFields.isEmpty else {
                return
            }
            let size = MemoryLayout<(Item, EnumBox)>.stride
            let pointer = allocate(bytes: size)
            func project<Enum>(type _: Enum.Type) {
                pointer
                    .assumingMemoryBound(to: Item.self)
                    .initialize(to: Item(vtable: EnumVTable<Enum>.self, size: size, fieldOffset: baseOffset))
            }
            _openExistential(type, do: project)
            pointer
                .advanced(by: MemoryLayout<Item>.size)
                .assumingMemoryBound(to: EnumBox.self)
                .initialize(to: EnumBox(
                    cases: taggedFields.map { taggedField in
                        (
                            taggedField.tag,
                            _DynamicPropertyBuffer(
                                fields: DynamicPropertyCache.Fields(layout: .product(taggedField.fields)),
                                container: container,
                                inputs: &inputs,
                                baseOffset: 0
                            )
                        )
                    },
                    active: nil
                ))
            _count &+= 1
        }
    }

    package mutating func append<Box: DynamicPropertyBox>(_ box: Box, fieldOffset: Int) {
        let size = (MemoryLayout<Box>.size + MemoryLayout<UnsafeHeterogeneousBuffer.Item>.size + 0xf) & ~0xf
        let pointer = allocate(bytes: size)
        let item = Item(vtable: BoxVTable<Box>.self, size: size, fieldOffset: fieldOffset)
        pointer
            .assumingMemoryBound(to: Item.self)
            .initialize(to: item)
        pointer
            .advanced(by: MemoryLayout<Item>.size)
            .assumingMemoryBound(to: Box.self)
            .initialize(to: box)
        _count &+= 1
    }

    package func destroy() {
        Swift.precondition(_count >= 0)
        var count = _count
        var pointer = buf
        while count > 0 {
            let itemPointer = pointer.assumingMemoryBound(to: Item.self)
            let boxPointer = pointer.advanced(by: MemoryLayout<Item>.size)
            if Signpost.linkDestroy.isEnabled {
                traceLinkDestroy(address: boxPointer)
            }
            itemPointer.pointee.vtable.deinitialize(ptr: boxPointer)
            pointer += Int(itemPointer.pointee.size)
            count &-= 1
        }
        if size > 0 {
            buf.deallocate()
        }
    }

    package func reset() {
        Swift.precondition(_count >= 0)
        var count = _count
        var pointer = buf
        while count > 0 {
            let itemPointer = pointer.assumingMemoryBound(to: Item.self)
            let boxPointer = pointer.advanced(by: MemoryLayout<Item>.size)
            itemPointer.pointee.vtable.reset(ptr: boxPointer)
            pointer += Int(itemPointer.pointee.size)
            count &-= 1
        }
    }

    package func getState<Value>(type: Value.Type) -> Binding<Value>? {
        Swift.precondition(_count >= 0)
        var count = _count
        var pointer = buf
        while count > 0 {
            let itemPointer = pointer.assumingMemoryBound(to: Item.self)
            let boxPointer = pointer.advanced(by: MemoryLayout<Item>.size)
            if let binding = itemPointer.pointee.vtable.getState(ptr: boxPointer, type: type) {
                return binding
            }
            pointer += Int(itemPointer.pointee.size)
            count &-= 1
        }
        return nil
    }

    package func update(container: UnsafeMutableRawPointer, phase: _GraphInputs.Phase) -> Bool {
        Swift.precondition(_count >= 0)
        var changed = false
        var count = _count
        var pointer = buf
        while count > 0 {
            let itemPointer = pointer.assumingMemoryBound(to: Item.self)
            let boxPointer = pointer.advanced(by: MemoryLayout<Item>.size)
            let propertyPointer = container.advanced(by: Int(itemPointer.pointee.fieldOffset))
            let updateResult = itemPointer.pointee.vtable.update(
                ptr: boxPointer,
                property: propertyPointer,
                phase: phase
            )
            itemPointer.pointee.lastChanged = updateResult
            changed = changed || updateResult
            pointer += Int(itemPointer.pointee.size)
            count &-= 1
        }
        return changed
    }

    private mutating func allocate(bytes: Int) -> UnsafeMutableRawPointer {
        Swift.precondition(_count >= 0)
        var count = _count
        var pointer = buf
        while count > 0 {
            let itemPointer = pointer.assumingMemoryBound(to: Item.self)
            pointer += Int(itemPointer.pointee.size)
            count &-= 1
        }
        return if Int(size) - buf.distance(to: pointer) >= bytes {
            pointer
        } else {
            allocateSlow(bytes: bytes, ptr: pointer)
        }
    }

    private mutating func allocateSlow(bytes: Int, ptr: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer {
        let oldSize = Int(size)
        var allocSize = max(oldSize &* 2, 64)
        let expectedSize = oldSize + bytes
        while allocSize < expectedSize {
            allocSize &*= 2
        }
        let allocatedBuffer = UnsafeMutableRawPointer.allocate(
            byteCount: allocSize,
            alignment: .zero
        )
        var count = UInt(_count)
        var newBuffer = allocatedBuffer
        var oldBuffer = buf
        while count > 0 {
            let newItemPointer = newBuffer.assumingMemoryBound(to: Item.self)
            let oldItemPointer = oldBuffer.assumingMemoryBound(to: Item.self)
            newItemPointer.initialize(to: oldItemPointer.pointee)
            oldItemPointer.pointee.vtable.moveInitialize(
                ptr: newBuffer.advanced(by: MemoryLayout<Item>.size),
                from: oldBuffer.advanced(by: MemoryLayout<Item>.size)
            )
            let itemSize = Int(oldItemPointer.pointee.size)
            newBuffer += itemSize
            oldBuffer += itemSize
            count &-= 1
        }
        oldBuffer = buf
        if size > 0 {
            oldBuffer.deallocate()
        }
        buf = allocatedBuffer
        size = Int32(allocSize)
        return allocatedBuffer.advanced(by: oldBuffer.distance(to: ptr))
    }

    package func traceMountedProperties<Value>(
        to value: _GraphValue<Value>,
        fields: DynamicPropertyCache.Fields
    ) {
        if Signpost.linkCreate.isEnabled {
            let type = String(describing: Value.self)
            let typeLibrary = Tracing.libraryName(defining: Value.self)
            let identifier = value.value.identifier.rawValue
            let identity = value.value.graph.graphIdentity()
            if case let .product(fieldsArray) = fields.layout {
                var index = 0
                var pointer = buf
                while index < _count && index < fieldsArray.count {
                    let itemPointer = pointer.assumingMemoryBound(to: Item.self)
                    let boxPointer = pointer.advanced(by: MemoryLayout<Item>.size)
                    traceLinkCreate(
                        field: fieldsArray[index],
                        address: boxPointer,
                        type: type,
                        typeLibrary: typeLibrary,
                        identifier: identifier,
                        identity: identity
                    )
                    pointer += Int(itemPointer.pointee.size)
                    index &+= 1
                }
            }
        }
    }

    package func applyChanged(to body: (Int) -> Void) {
        var index = 0
        var pointer = buf
        while index < _count {
            let itemPointer = pointer.assumingMemoryBound(to: Item.self)
            if itemPointer.pointee.lastChanged {
                body(Int(itemPointer.pointee.fieldOffset))
            }
            index &+= 1
            pointer += Int(itemPointer.pointee.size)
        }
    }
}

extension _DynamicPropertyBuffer {
    private struct Item {
        init(vtable: BoxVTableBase.Type, size: Int, fieldOffset: Int) {
            self.vtable = vtable
            self.size = Int32(size)
            self._fieldOffsetAndLastChanged = UInt32(Int32(fieldOffset))
        }

        private(set) var vtable: BoxVTableBase.Type
        private(set) var size: Int32
        private var _fieldOffsetAndLastChanged: UInt32

        @inline(__always)
        private static var fieldOffsetMask: UInt32 { 0x7FFF_FFFF }
        var fieldOffset: Int32 {
            Int32(bitPattern: _fieldOffsetAndLastChanged & Item.fieldOffsetMask)
        }

        @inline(__always)
        private static var lastChangedMask: UInt32 { 0x8000_0000 }
        var lastChanged: Bool {
            get { (_fieldOffsetAndLastChanged & Item.lastChangedMask) == Item.lastChangedMask }
            set {
                if newValue {
                    _fieldOffsetAndLastChanged |= Item.lastChangedMask
                } else {
                    _fieldOffsetAndLastChanged &= ~Item.lastChangedMask
                }
            }
        }
    }
}

#endif


#if OPENSWIFTUI_SUPPORT_2024_API

// MARK: - BoxVTableBase [6.5.4]

private class BoxVTableBase: UnsafeHeterogeneousBuffer.VTable {
    class func reset(elt: _UnsafeHeterogeneousBuffer_Element) {
        _openSwiftUIEmptyStub()
    }

    class func update(
        elt: _UnsafeHeterogeneousBuffer_Element,
        property : UnsafeMutableRawPointer,
        phase: _GraphInputs.Phase
    ) -> Bool {
        false
    }

    class func getState<Value>(
        elt: _UnsafeHeterogeneousBuffer_Element,
        type: Value.Type
    ) -> Binding<Value>? {
        nil
    }
}

#else


// MARK: - BoxVTableBase [3.5.2]

private class BoxVTableBase {
    class func moveInitialize(
        ptr: UnsafeMutableRawPointer,
        from: UnsafeMutableRawPointer
    ) {
        _openSwiftUIBaseClassAbstractMethod()
    }

    class func deinitialize(ptr: UnsafeMutableRawPointer) {
        _openSwiftUIEmptyStub()
    }

    class func reset(ptr: UnsafeMutableRawPointer) {
        _openSwiftUIEmptyStub()
    }

    class func update(
        ptr: UnsafeMutableRawPointer,
        property: UnsafeMutableRawPointer,
        phase: _GraphInputs.Phase
    ) -> Bool {
        false
    }

    class func getState<Value>(
        ptr _: UnsafeMutableRawPointer,
        type _: Value.Type
    ) -> Binding<Value>? {
        nil
    }
}

#endif

#if OPENSWIFTUI_SUPPORT_2024_API

// MARK: - BoxVTable [6.5.4]

private class BoxVTable<Box: DynamicPropertyBox>: BoxVTableBase {
    override class func moveInitialize(
        elt: _UnsafeHeterogeneousBuffer_Element,
        from: _UnsafeHeterogeneousBuffer_Element
    ) {
        let fromBoxPointer = from.body(as: Box.self)
        let destinationBoxPointer = elt.body(as: Box.self)
        destinationBoxPointer.initialize(to: fromBoxPointer.move())
    }

    override class func deinitialize(elt: _UnsafeHeterogeneousBuffer_Element) {
        let boxPointer = elt.body(as: Box.self)
        boxPointer.pointee.destroy()
        boxPointer.deinitialize(count: 1)
    }

    override class func reset(elt: _UnsafeHeterogeneousBuffer_Element) {
        let boxPointer = elt.body(as: Box.self)
        boxPointer.pointee.reset()
    }

    override class func update(
        elt: _UnsafeHeterogeneousBuffer_Element,
        property: UnsafeMutableRawPointer,
        phase: _GraphInputs.Phase
    ) -> Bool {
        let boxPointer = elt.body(as: Box.self)
        let propertyPointer = property.assumingMemoryBound(to: Box.Property.self)
        let changed = boxPointer.pointee.update(property: &propertyPointer.pointee, phase: phase)
        if changed {
            traceLinkUpdate(property: propertyPointer.pointee, address: elt.address)
        }
        return changed
    }

    override class func getState<Value>(
        elt: _UnsafeHeterogeneousBuffer_Element,
        type: Value.Type
    ) -> Binding<Value>? {
        let boxPointer = elt.body(as: Box.self)
        return boxPointer.pointee.getState(type: type)
    }
}

#else

// MARK: - BoxVTable [3.5.2]

private class BoxVTable<Box: DynamicPropertyBox>: BoxVTableBase {
    override class func moveInitialize(ptr destination: UnsafeMutableRawPointer, from: UnsafeMutableRawPointer) {
        let fromBoxPointer = from.assumingMemoryBound(to: Box.self)
        let destinationBoxPointer = destination.assumingMemoryBound(to: Box.self)
        destinationBoxPointer.initialize(to: fromBoxPointer.move())
    }

    override class func deinitialize(ptr: UnsafeMutableRawPointer) {
        let boxPointer = ptr.assumingMemoryBound(to: Box.self)
        boxPointer.pointee.destroy()
        boxPointer.deinitialize(count: 1)
    }

    override class func reset(ptr: UnsafeMutableRawPointer) {
        let boxPointer = ptr.assumingMemoryBound(to: Box.self)
        boxPointer.pointee.reset()
    }

    override class func update(
        ptr: UnsafeMutableRawPointer,
        property: UnsafeMutableRawPointer,
        phase: _GraphInputs.Phase
    ) -> Bool {
        let boxPointer = ptr.assumingMemoryBound(to: Box.self)
        let propertyPointer = property.assumingMemoryBound(to: Box.Property.self)
        let changed = boxPointer.pointee.update(property: &propertyPointer.pointee, phase: phase)
        if changed {
            traceLinkUpdate(property: propertyPointer.pointee, address: ptr)
        }
        return changed
    }

    override class func getState<Value>(ptr: UnsafeMutableRawPointer, type: Value.Type) -> Binding<Value>? {
        let boxPointer = ptr.assumingMemoryBound(to: Box.self)
        return boxPointer.pointee.getState(type: type)
    }
}

#endif

// MARK: - EnumBox [6.5.4]

private struct EnumBox {
    var cases: [(tag: Int, links: _DynamicPropertyBuffer)]
    var active: (tag: Int, index: Int)?
}

#if OPENSWIFTUI_SUPPORT_2024_API

// MARK: - EnumVTable [6.5.4]

private final class EnumVTable<Enum>: BoxVTableBase {
    override class func moveInitialize(
        elt: _UnsafeHeterogeneousBuffer_Element,
        from: _UnsafeHeterogeneousBuffer_Element
    ) {
        let fromBoxPointer = from.body(as: EnumBox.self)
        let destinationBoxPointer = elt.body(as: EnumBox.self)
        destinationBoxPointer.initialize(to: fromBoxPointer.move())
    }

    override class func deinitialize(elt: _UnsafeHeterogeneousBuffer_Element) {
        let boxPointer = elt.body(as: EnumBox.self)
        for (_, links) in boxPointer.pointee.cases {
            links.destroy()
        }
    }

    override class func reset(elt: _UnsafeHeterogeneousBuffer_Element) {
        let boxPointer = elt.body(as: EnumBox.self)
        guard let (_, index) = boxPointer.pointee.active else {
            return
        }
        boxPointer.pointee.cases[index].links.reset()
        boxPointer.pointee.active = nil
    }

    override class func update(
        elt: _UnsafeHeterogeneousBuffer_Element,
        property: UnsafeMutableRawPointer,
        phase: _GraphInputs.Phase
    ) -> Bool {
        var changed = false
        withUnsafeMutablePointerToEnumCase(of: property.assumingMemoryBound(to: Enum.self)) { tag, _, pointer in
            let boxPointer = elt.body(as: EnumBox.self)
            if let (activeTag, index) = boxPointer.pointee.active, activeTag != tag {
                boxPointer.pointee.cases[index].links.reset()
                boxPointer.pointee.active = nil
                changed = true
            }
            if boxPointer.pointee.active == nil {
                guard let matchedIndex = boxPointer.pointee.cases.firstIndex(where: { $0.tag == tag }) else {
                    return
                }
                boxPointer.pointee.active = (tag, matchedIndex)
                changed = true
            }
            if let (_, index) = boxPointer.pointee.active {
                changed = boxPointer.pointee.cases[index].links.update(container: pointer, phase: phase)
            }
        }
        return changed
    }

    override class func getState<Value>(
        elt: _UnsafeHeterogeneousBuffer_Element,
        type: Value.Type
    ) -> Binding<Value>? {
        let boxPointer = elt.body(as: EnumBox.self)
        guard let (_, index) = boxPointer.pointee.active else {
            return nil
        }
        return boxPointer.pointee.cases[index].links.getState(type: type)
    }
}

#else

// MARK: - EnumVTable [3.5.2]

private class EnumVTable<Enum>: BoxVTableBase {
    override class func moveInitialize(
        ptr destination: UnsafeMutableRawPointer,
        from: UnsafeMutableRawPointer
    ) {
        let fromBoxPointer = from.assumingMemoryBound(to: EnumBox.self)
        let destinationBoxPointer = destination.assumingMemoryBound(to: EnumBox.self)
        destinationBoxPointer.initialize(to: fromBoxPointer.move())
    }

    override class func deinitialize(ptr: UnsafeMutableRawPointer) {
        let boxPointer = ptr.assumingMemoryBound(to: EnumBox.self)
        for (_, links) in boxPointer.pointee.cases {
            links.destroy()
        }
    }

    override class func reset(ptr: UnsafeMutableRawPointer) {
        let boxPointer = ptr.assumingMemoryBound(to: EnumBox.self)
        guard let (_, index) = boxPointer.pointee.active else {
            return
        }
        boxPointer.pointee.cases[index].links.reset()
        boxPointer.pointee.active = nil
    }

    override class func update(
        ptr: UnsafeMutableRawPointer,
        property: UnsafeMutableRawPointer,
        phase: _GraphInputs.Phase
    ) -> Bool {
        var changed = false
        withUnsafeMutablePointerToEnumCase(of: property.assumingMemoryBound(to: Enum.self)) { tag, _, pointer in
            let boxPointer = ptr.assumingMemoryBound(to: EnumBox.self)
            if let (activeTag, index) = boxPointer.pointee.active, activeTag != tag {
                boxPointer.pointee.cases[index].links.reset()
                boxPointer.pointee.active = nil
                changed = true
            }
            if boxPointer.pointee.active == nil {
                guard let matchedIndex = boxPointer.pointee.cases.firstIndex(where: { $0.tag == tag }) else {
                    return
                }
                boxPointer.pointee.active = (tag, matchedIndex)
                changed = true
            }
            if let (_, index) = boxPointer.pointee.active {
                changed = boxPointer.pointee.cases[index].links.update(container: pointer, phase: phase)
            }
        }
        return changed
    }

    override class func getState<Value>(
        ptr: UnsafeMutableRawPointer,
        type: Value.Type
    ) -> Binding<Value>? {
        let boxPointer = ptr.assumingMemoryBound(to: EnumBox.self)
        guard let (_, index) = boxPointer.pointee.active else {
            return nil
        }
        return boxPointer.pointee.cases[index].links.getState(type: type)
    }
}
#endif
