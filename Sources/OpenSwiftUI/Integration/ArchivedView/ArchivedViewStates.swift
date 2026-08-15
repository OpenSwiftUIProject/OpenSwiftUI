//
//  ArchivedViewStates.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

import Foundation
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - _ArchivedViewStates

@_spi(Private)
public struct _ArchivedViewStates {
    public struct DeploymentVersion: Hashable, Comparable, Codable {
        package var base: ArchivedViewInput.DeploymentVersion

        package init(base: ArchivedViewInput.DeploymentVersion) {
            self.base = base
        }

        public static let v5: DeploymentVersion = .init(base: .v5)

        public static let v6: DeploymentVersion = .init(base: .v6)

        public static func < (
            lhs: DeploymentVersion,
            rhs: DeploymentVersion
        ) -> Bool {
            lhs.base < rhs.base
        }

        public init(from decoder: any Decoder) throws {
            base = try ArchivedViewInput.DeploymentVersion(from: decoder)
        }

        public func encode(to encoder: any Encoder) throws {
            try base.encode(to: encoder)
        }
    }
}
