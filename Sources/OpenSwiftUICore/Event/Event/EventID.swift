//
//  EventID.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import Foundation

// MARK: - EventID

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
public struct EventID: Hashable {
    package var type: any Any.Type

    package var serial: Int

    package init(type: any Any.Type, serial: Int) {
        self.type = type
        self.serial = serial
    }

    public static func == (lhs: EventID, rhs: EventID) -> Bool {
        lhs.type == rhs.type && lhs.serial == rhs.serial
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(type))
        hasher.combine(serial)
    }
}

@available(*, unavailable)
extension EventID: Sendable {}

extension EventID {
    package init<T, S>(_ obj: T, subtype: S.Type) where T: NSObject {
        type = (T, S).self
        serial = unsafeBitCast(obj, to: Int.self)
    }
}

extension EventID: CustomStringConvertible {
    public var description: String {
        "\(type)#\(serial)"
    }
}
