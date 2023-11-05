//
//  StateObject.swift
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

@frozen
@propertyWrapper
public struct StateObject<ObjectType> where ObjectType: ObservableObject {
    @usableFromInline
    @frozen
    enum Storage {
        case initially(() -> ObjectType)
        case object(ObservedObject<ObjectType>)
    }

    @usableFromInline
    var storage: StateObject<ObjectType>.Storage

    @inlinable
    public init(wrappedValue thunk: @autoclosure @escaping () -> ObjectType) {
        storage = .initially(thunk)
    }

    public var wrappedValue: ObjectType {
        objectValue.wrappedValue
    }

    public var projectedValue: ObservedObject<ObjectType>.Wrapper {
        objectValue.projectedValue
    }
}

extension StateObject: DynamicProperty {
    public static func _makeProperty(in _: inout _DynamicPropertyBuffer, container _: _GraphValue<some Any>, fieldOffset _: Int, inputs _: inout _GraphInputs) {
        // TODO:
    }

    public static var _propertyBehaviors: UInt32 { 2 }
}

extension StateObject {
    var objectValue: ObservedObject<ObjectType> {
        switch storage {
        case let .initially(thunk):
            Log.runtimeIssues("Accessing StateObject's object without being installed on a View. This will create a new instance each time.")
            return ObservedObject(wrappedValue: thunk())
        case let .object(value):
            return value
        }
    }
}
