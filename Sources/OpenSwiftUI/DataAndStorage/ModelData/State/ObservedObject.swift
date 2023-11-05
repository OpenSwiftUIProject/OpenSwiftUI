//
//  ObservedObject.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/11/5.
//  Lastest Version: iOS 15.5
//  Status: Blocked by DynamicProperty

#if OPENSWIFTUI_USE_COMBINE
import Combine
#else
import OpenCombine
#endif
internal import OpenSwiftUIShims

@propertyWrapper
@frozen
public struct ObservedObject<ObjectType> where ObjectType: ObservableObject {
    @dynamicMemberLookup
    @frozen
    public struct Wrapper {
        let root: ObjectType
        public subscript<Subject>(dynamicMember keyPath: ReferenceWritableKeyPath<ObjectType, Subject>) -> Binding<Subject> {
            Binding(root, keyPath: keyPath)
        }
    }

    @usableFromInline
    var _seed = 0

    public var wrappedValue: ObjectType

    @_alwaysEmitIntoClient
    public init(initialValue: ObjectType) {
        self.init(wrappedValue: initialValue)
    }

    public init(wrappedValue: ObjectType) {
        self.wrappedValue = wrappedValue
    }

    public var projectedValue: ObservedObject<ObjectType>.Wrapper {
        .init(root: wrappedValue)
    }
}

extension ObservedObject: DynamicProperty {
    public static func _makeProperty(in _: inout _DynamicPropertyBuffer, container _: _GraphValue<some Any>, fieldOffset _: Int, inputs _: inout _GraphInputs) {
        // TODO
    }

    public static var _propertyBehaviors: UInt32 { 2 }
}

extension Binding {
    init<ObjectType: ObservableObject>(_ root: ObjectType, keyPath: ReferenceWritableKeyPath<ObjectType, Value>) {
        let location = ObservableObjectLocation(base: root, keyPath: keyPath)
        let box = LocationBox(location: location)
        self.init(value: location.get(), location: box)
    }
}
