//
//  Link.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 6FFE843582373F7ACAB4C773335A2472 (SwiftUICore)

package import Foundation

package struct LinkDestination: DynamicProperty {
    package struct Configuration: Codable {
        package var url: URL
        package var isSensitive: Bool

        package init(url: URL, isSensitive: Bool = false) {
            self.url = url
            self.isSensitive = isSensitive
        }
    }

    @Environment(\.openURL)
    private var openURL: OpenURLAction

    @Environment(\._openSensitiveURL)
    private var openSensitiveURL: OpenURLAction

    package var configuration: Configuration

    package init(configuration: Configuration) {
        self.configuration = configuration
    }

    package func open() {
        let openURLAction = configuration.isSensitive ? openSensitiveURL : openURL
        openURLAction(configuration.url)
    }
}
