//
//  LinkDestination.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/11/28.
//  Lastest Version: iOS 15.5
//  Status: Complete
//  ID: 85AAA54365DC4DDF1DC8F2FECEF4501A

import Foundation

struct LinkDestination {
    var configuration: Configuration

    @Environment(\.openURL)
    private var openURL: OpenURLAction

    @Environment(\._openSensitiveURL)
    private var openSensitiveURL: OpenURLAction

    func open() {
        let openURLAction = configuration.isSensitive ? openSensitiveURL : openURL
        openURLAction(configuration.url)
    }
}

extension LinkDestination {
    struct Configuration: Codable {
        var url: URL
        var isSensitive: Bool
        
        init(url: URL, isSensitive: Bool) {
            self.url = url
            self.isSensitive = isSensitive
        }

        private enum CodingKeys: CodingKey {
            case url
            case isSensitive
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            url = try container.decode(URL.self, forKey: .url)
            isSensitive = try container.decode(Bool.self, forKey: .isSensitive)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(url, forKey: .url)
            try container.encode(isSensitive, forKey: .isSensitive)
        }
    }
}
