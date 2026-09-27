//
//  AccessibilityActivationPoint.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP

package import Foundation
import OpenSwiftUI_SPI

package struct AccessibilityActivationPointStorage: Equatable {
    package var activate: AccessibilityActivationPoint.Location?
    package var drag: [AccessibilityActivationPoint]
    package var drop: [AccessibilityActivationPoint]

    package init() {
        activate = nil
        drag = []
        drop = []
    }

    package init(kind: AccessibilityActivationKind.RawValue, point: AccessibilityActivationPoint.Location) {
        self.init()
        switch kind {
        case .activate:
            activate = point
        case let .drag(description):
            description.assertUnstyled()
            drag = [.init(location: point, description: description)]
        case let .drop(description):
            description.assertUnstyled()
            drop = [.init(location: point, description: description)]
        }
    }
}

extension AccessibilityActivationPointStorage: AccessibilityCombinable {
    @discardableResult
    package mutating func merge(with child: Self) -> Bool {
        let result: Bool
        if activate == nil {
            activate = child.activate
            result = true
        } else {
            result = !child.drag.isEmpty || child.drop.isEmpty
        }
        drag.append(contentsOf: child.drag)
        drop.append(contentsOf: child.drop)
        return result
    }
}

package struct AccessibilityActivationPoint: Equatable {
    package enum Location: Equatable {
        case point(CGPoint)
        case unitPoint(UnitPoint)
        case automatic
    }

    package var location: Location
    package var description: Text
}

package struct AccessibilityActivationKind {
    package enum RawValue: Equatable {
        case activate
        case drag(Text)
        case drop(Text)
    }

    package var rawValue: RawValue

    package init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    package static let `default` = Self(rawValue: .activate)
}

extension AccessibilityActivationKind {
    package static var defaultDescriptor: String {
        #if canImport(Darwin)
        AXOpenSwiftUIInteractionLocationDescriptorDefaultName()
        #else
        _openSwiftUIPlatformUnimplementedFailure()
        #endif
    }
}

extension AccessibilityActivationPoint.Location: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        switch self {
        case let .point(point):
            try encoder.messageField(1, point)
        case let .unitPoint(point):
            try encoder.messageField(2, point)
        case .automatic:
            break
        }
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        self = .automatic
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: self = .point(try decoder.messageField(field))
            case 2: self = .unitPoint(try decoder.messageField(field))
            default: try decoder.skipField(field)
            }
        }
    }
}
