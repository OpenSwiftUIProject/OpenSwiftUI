//
//  NamedImageProvider.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: ? (SwiftUICore)

package import Foundation
package import OpenCoreGraphicsShims

// MARK: - Image.NamedImageProvider

extension Image {
    package struct NamedImageProvider: ImageProvider {
        package var name: String

        package var value: Float?

        package var location: Image.Location

        package var backupLocation: Image.Location?

        package var label: AccessibilityImageLabel?

        package var decorative: Bool

        package init(
            name: String,
            value: Float? = nil,
            location: Image.Location,
            label: AccessibilityImageLabel?,
            decorative: Bool,
            backupLocation: Image.Location? = nil
        ) {
            self.name = name
            self.value = value
            self.location = location
            self.label = label
            self.decorative = decorative
            self.backupLocation = backupLocation
        }

        package func resolve(in context: ImageResolutionContext) -> Image.Resolved {
            // TODO: Full CoreUI-based resolution
            // The real implementation:
            // 1. Tries vector resolution first (via vectorInfo)
            // 2. Falls back to bitmap resolution (via bitmapInfo)
            // 3. Returns resolveError if both fail
            resolveError(in: context.environment)
        }

        package func resolveError(in environment: EnvironmentValues) -> Image.Resolved {
            Image.Resolved(
                image: GraphicsImage(
                    contents: nil,
                    scale: environment.displayScale,
                    unrotatedPixelSize: .zero,
                    orientation: .up,
                    isTemplate: false
                ),
                decorative: decorative,
                label: label
            )
        }

        package func resolveNamedImage(in context: ImageResolutionContext) -> Image.NamedResolved? {
            let environment = context.environment
            let isTemplate = environment.imageIsTemplate()
            return Image.NamedResolved(
                name: name,
                location: location,
                value: value,
                symbolRenderingMode: context.symbolRenderingMode?.storage,
                isTemplate: isTemplate,
                environment: environment
            )
        }

        package static func == (a: NamedImageProvider, b: NamedImageProvider) -> Bool {
            a.name == b.name
                && a.value == b.value
                && a.location == b.location
                && a.backupLocation == b.backupLocation
                && a.label == b.label
                && a.decorative == b.decorative
        }
    }
}
