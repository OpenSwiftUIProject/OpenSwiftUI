//
//  DescriptiveDynamicProperty.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2024/9/22.
//

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
