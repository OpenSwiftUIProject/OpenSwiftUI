//
//  Tracing.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: D59B7A281FFF29619A43A3D8F551CCE1

// MARK: - Tracing

enum Tracing {
    static func libraryName(defining _: Any.Type) -> String {
        // TODO:
        ""
    }
//    private static moduleLookupCache: ThreadSpecific<[UnsafeRawPointer : String]>
}

// MARK: - DescriptiveDynamicProperty

private protocol DescriptiveDynamicProperty {
    var _linkValue: Any { get }
}

extension DescriptiveDynamicProperty {
    var linkValueDescription: String {
        if let descriptiveDynamicProperty = _linkValue as? DescriptiveDynamicProperty {
            descriptiveDynamicProperty.linkValueDescription
        } else {
            String(describing: _linkValue)
        }
    }
}

extension DynamicProperty {
    fileprivate var linkValueDescription: String {
        if let descriptiveDynamicProperty = self as? DescriptiveDynamicProperty {
            descriptiveDynamicProperty.linkValueDescription
        } else {
            String(describing: self)
        }
    }
}

extension State: DescriptiveDynamicProperty {
    fileprivate var _linkValue: Any {
        projectedValue.wrappedValue
    }
}

extension Binding: DescriptiveDynamicProperty {
    fileprivate var _linkValue: Any {
        wrappedValue
    }
}

extension Environment: DescriptiveDynamicProperty {
    fileprivate var _linkValue: Any {
        wrappedValue
    }
}
