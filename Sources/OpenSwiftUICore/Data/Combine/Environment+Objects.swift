//
//  Environment+Objects.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: D6C90B7A81ED24386CD276102C65B68D (SwiftUICore)

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
    subscript<ObjectType>(_: EnvironmentObjectKey<ObjectType>) -> ObjectType? where ObjectType: AnyObject {
        get { self[objectType: ObjectType.self] }
        set { self[objectType: ObjectType.self] = newValue }
    }

    subscript<ObjectType>(forceUnwrapping key: EnvironmentObjectKey<ObjectType>) -> ObjectType where ObjectType: AnyObject {
        get {
            guard let object = self[key] else {
                preconditionFailure("No Observable object of type \(ObjectType.self) found. A View.environmentObject(_:) for \(ObjectType.self) may be missing as an ancestor of this view.")
            }
            return object
        }
        set {
            self[key] = newValue
        }
    }

    subscript<ObjectType>(objectType _: ObjectType.Type) -> ObjectType? where ObjectType: AnyObject {
        get { self[EnvironmentObjectKey<ObjectType>.self] }
        set { self[EnvironmentObjectKey<ObjectType>.self] = newValue }
    }
}
