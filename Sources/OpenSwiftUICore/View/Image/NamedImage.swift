//
//  NamedImage.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Empty
//  ID: 8E7DCD4CEB1ACDE07B249BFF4CBC75C0 (SwiftUICore)

package import Foundation

// TODO
package enum NamedImage {
    package enum Key: Equatable {
        case uuid(UUID)
    }
}

extension Image {
    // TODO
    package enum Location: Equatable, Hashable {
        case bundle(Bundle)
        case system
        case privateSystem

        package var supportsNonVectorImages: Bool {
            guard case .bundle = self else {
                return false
            }
            return true
        }

        // package var catalog: CUICatalog?

        package var bundle: Bundle? {
            guard case .bundle(let bundle) = self else {
                return nil
            }
            return bundle
        }
    }
}
