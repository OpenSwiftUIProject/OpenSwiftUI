//
//  ArchivedViewInput.swift
//  OpenSwiftUICore
//
//  Status: Complete

// MARK: - ArchivedViewInput [6.0.87]

/// A view input that manages archived view state and configuration.
///
/// `ArchivedViewInput` provides a way to store and retrieve view archival information,
/// including feature flags and deployment version compatibility. This is used internally
/// by OpenSwiftUI to maintain compatibility across different versions and to enable
/// optimizations for archived view hierarchies.
package struct ArchivedViewInput: ViewInput {
    /// Option flags that control archived view behavior.
    ///
    /// These flags determine various aspects of how archived views are processed,
    /// including stability guarantees, font handling, and layout precision.
    package struct Flags: OptionSet {
        package let rawValue: UInt8

        package init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        /// Indicates that the view hierarchy is archived.
        package static let isArchived: ArchivedViewInput.Flags = .init(rawValue: 1 << 0)

        /// Enables stable identifier tracking for archived views.
        package static let stableIDs: ArchivedViewInput.Flags = .init(rawValue: 1 << 1)

        /// Enables custom font URL preservation in archived views.
        package static let customFontURLs: ArchivedViewInput.Flags = .init(rawValue: 1 << 2)

        /// Enables asset catalog reference preservation in archived views.
        package static let assetCatalogRefences: ArchivedViewInput.Flags = .init(rawValue: 1 << 3)

        /// Enables precise text layout calculations for archived views.
        package static let preciseTextLayout: ArchivedViewInput.Flags = .init(rawValue: 1 << 4)
    }

    /// The value type that encapsulates archived view configuration.
    ///
    /// This type combines feature flags with deployment version information
    /// to provide complete archived view context.
    package struct Value: Equatable {
        /// The active feature flags for this archived view.
        package var flags: ArchivedViewInput.Flags

        /// The deployment version this archived view was created with.
        package var deploymentVersion: ArchivedViewInput.DeploymentVersion

        /// Creates a new archived view value.
        ///
        /// - Parameters:
        ///   - flags: The feature flags to apply. Defaults to no flags.
        ///   - deploymentVersion: The deployment version. Defaults to current.
        package init(
            flags: ArchivedViewInput.Flags = .init(),
            deploymentVersion: ArchivedViewInput.DeploymentVersion = .current
        ) {
            self.flags = flags
            self.deploymentVersion = deploymentVersion
        }

        /// A pre-configured value indicating an archived view.
        package static let isArchived: ArchivedViewInput.Value = .init(flags: .isArchived)

        /// Whether this view hierarchy is archived.
        package var isArchived: Bool {
            flags.contains(.isArchived)
        }

        /// Whether stable identifier tracking is enabled.
        package var stableIDs: Bool {
            flags.contains(.stableIDs)
        }

        /// Whether custom font URL preservation is enabled.
        package var customFontURLs: Bool {
            flags.contains(.customFontURLs)
        }

        /// Whether asset catalog reference preservation is enabled.
        package var assetCatalogRefences: Bool {
            flags.contains(.assetCatalogRefences)
        }

        /// Whether precise text layout is enabled.
        package var preciseTextLayout: Bool {
            flags.contains(.preciseTextLayout)
        }
    }

    /// Represents a deployment version for archived view compatibility.
    ///
    /// Deployment versions track OpenSwiftUI version compatibility to ensure
    /// archived views can be properly decoded and displayed across different
    /// runtime versions.
    package struct DeploymentVersion: Hashable, Comparable, Codable, Sendable {
        /// The raw version value.
        package let rawValue: Int8

        /// Creates a deployment version with the specified raw value.
        ///
        /// - Parameter rawValue: The version identifier.
        package init(rawValue: Int8) {
            self.rawValue = rawValue
        }

        /// OpenSwiftUI version 5 deployment target.
        package static let v5: ArchivedViewInput.DeploymentVersion = .init(rawValue: 1)

        /// OpenSwiftUI version 6 deployment target.
        package static let v6: ArchivedViewInput.DeploymentVersion = .init(rawValue: 2)

        /// The current deployment version for archived views.
        @_alwaysEmitIntoClient
        package static var current: ArchivedViewInput.DeploymentVersion { .v6 }

        package static func < (
            lhs: ArchivedViewInput.DeploymentVersion,
            rhs: ArchivedViewInput.DeploymentVersion
        ) -> Bool {
            lhs.rawValue < rhs.rawValue
        }

        /// The oldest supported deployment version.
        package static let oldest: ArchivedViewInput.DeploymentVersion = .v5
    }

    /// The default value for archived view input.
    package static let defaultValue: ArchivedViewInput.Value = .init()
}

extension ArchivedViewInput.DeploymentVersion {
    package func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(Int8.self)
        self.init(rawValue: rawValue)
    }
}

extension _GraphInputs {
    @inline(__always)
    var archivedView: ArchivedViewInput.Value {
        get { self[ArchivedViewInput.self] }
        set { self[ArchivedViewInput.self] = newValue }
    }
}

extension _ViewInputs {
    @inline(__always)
    var archivedView: ArchivedViewInput.Value {
        get { self[ArchivedViewInput.self] }
        set { self[ArchivedViewInput.self] = newValue }
    }
}
