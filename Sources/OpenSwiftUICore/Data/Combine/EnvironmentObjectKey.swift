//
//  EnvironmentObjectKey.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

#if OPENSWIFTUI_OPENCOMBINE
import OpenCombine
#else
import Combine
#endif

// MARK: - EnvironmentObjectKey

struct EnvironmentObjectKey<ObjectType>: EnvironmentKey, Hashable where ObjectType: AnyObject {
    init() {
        _openSwiftUIEmptyStub()
    }

    static var defaultValue: ObjectType? { nil }
}

// MARK: - EnvironmentValues + EnvironmentObjectKey

extension EnvironmentValues {
    subscript<ObjectType>(key: EnvironmentObjectKey<ObjectType>) -> ObjectType? where ObjectType: AnyObject {
        get { self[objectType: ObjectType.self] }
        set { self[objectType: ObjectType.self] = newValue }
    }

    subscript<ObjectType>(objectType _: ObjectType.Type) -> ObjectType? where ObjectType: AnyObject {
        get { self[EnvironmentObjectKey<ObjectType>.self] }
        set { self[EnvironmentObjectKey<ObjectType>.self] = newValue }
    }
}
