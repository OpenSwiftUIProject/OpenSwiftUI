//
//  ArchivedViewStates.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

import Foundation
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - _ArchivedViewStates [TODO]

@_spi(Private)
@available(OpenSwiftUI_v2_0, *)
public struct _ArchivedViewStates {}

// MARK: - _ArchivedViewStates.DeploymentVersion

@_spi(Private)
extension _ArchivedViewStates {
    @available(OpenSwiftUI_v6_0, *)
    public struct DeploymentVersion: Hashable, Comparable, Codable, Sendable {
        var base: ArchivedViewInput.DeploymentVersion

        init(base: ArchivedViewInput.DeploymentVersion) {
            self.base = base
        }

        public static let v5: DeploymentVersion = .init(base: .v5)

        public static let v6: DeploymentVersion = .init(base: .v6)

        @_alwaysEmitIntoClient
        public static var current: DeploymentVersion { .v6 }

        public static func < (
            lhs: DeploymentVersion,
            rhs: DeploymentVersion
        ) -> Bool {
            lhs.base < rhs.base
        }
    }
}

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
extension _ArchivedViewStates.DeploymentVersion {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(base.rawValue)
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        base = .init(rawValue: try container.decode(Int8.self))
    }
}
