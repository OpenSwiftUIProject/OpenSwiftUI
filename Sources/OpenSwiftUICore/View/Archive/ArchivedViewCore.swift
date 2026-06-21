//
//  ArchivedViewCore.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: D016D0E3769EA092A45BCB1F998387D5 (SwiftUICore)

package import CoreText_Private
package import Foundation

// MARK: - ArchivedViewCore

package struct ArchivedViewCore {
    package static let majorVersion: Int = 13
    package static let archivedViewHostKey = CodingUserInfoKey(rawValue: "org.OpenSwiftUIProject.OpenSwiftUI.ArchivedViewHost")!
    package static let archiveOptionsKey = CodingUserInfoKey(rawValue: "org.OpenSwiftUIProject.OpenSwiftUI.ArchivedViewInput")!
    package static let rbEncoderSetKey = CodingUserInfoKey(rawValue: "org.OpenSwiftUIProject.OpenSwiftUI.RBEncoderSet")!

    package struct Metadata: Codable {
        package var majorVersion: Int
        package var stateAttachments: [Int]
        package var stableIDsAttachment: Int?
        package var dataAttachment: Int?
        package var archiveID: UUID
        package var deploymentVersion: ArchivedViewInput.DeploymentVersion

        package var preferredBundleLanguage: String? = Bundle.main.preferredLocalizations.first
        @CodableRawRepresentable
        package var preferredCompositionLanguage: CTCompositionLanguage = OpenSwiftUI_CTParagraphStyleGetCompositionLanguageForLanguage(nil)

        package init(
            majorVersion: Int = ArchivedViewCore.majorVersion,
            stateAttachments: [Int] = [],
            stableIDAttachment: Int? = nil,
            dataAttachment: Int? = nil,
            archiveID: UUID = .init(),
            deploymentVersion: ArchivedViewInput.DeploymentVersion = .current
        ) {
            self.majorVersion = majorVersion
            self.stateAttachments = stateAttachments
            self.stableIDsAttachment = stableIDAttachment
            self.dataAttachment = dataAttachment
            self.archiveID = archiveID
            self.deploymentVersion = deploymentVersion
        }

        package func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(majorVersion, forKey: .majorVersion)
            try container.encode(stateAttachments, forKey: .stateAttachments)
            try container.encodeIfPresent(stableIDsAttachment, forKey: .stableIDsAttachment)
            try container.encodeIfPresent(dataAttachment, forKey: .dataAttachment)
            try container.encode(archiveID, forKey: .archiveID)
            try container.encode(deploymentVersion, forKey: .deploymentVersion)
            try container.encodeIfPresent(preferredBundleLanguage, forKey: .preferredBundleLanguage)
            try container.encode(_preferredCompositionLanguage, forKey: .preferredCompositionLanguage)
        }

        private enum CodingKeys: String, CodingKey {
            case majorVersion
            case stateAttachments
            case stableIDsAttachment
            case dataAttachment
            case archiveID
            case deploymentVersion
            case preferredBundleLanguage
            case preferredCompositionLanguage
        }
    }
}

extension ArchivedViewCore.Metadata {
    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        majorVersion = try container.decode(Int.self, forKey: .majorVersion)
        stateAttachments = try container.decode([Int].self, forKey: .stateAttachments)
        stableIDsAttachment = try container.decodeIfPresent(Int.self, forKey: .stableIDsAttachment)
        dataAttachment = try container.decodeIfPresent(Int.self, forKey: .dataAttachment)
        archiveID = try container.decode(UUID.self, forKey: .archiveID)
        deploymentVersion = try container.decodeIfPresent(
            ArchivedViewInput.DeploymentVersion.self,
            forKey: .deploymentVersion
        ) ?? .oldest
        preferredBundleLanguage = try container.decodeIfPresent(String.self, forKey: .preferredBundleLanguage)
        _preferredCompositionLanguage = try container.decodeIfPresent(
            CodableRawRepresentable<CTCompositionLanguage>.self,
            forKey: .preferredCompositionLanguage
        ) ?? CodableRawRepresentable(.unset)
    }
}
