//
//  ImageDynamicRange.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: B0F5FD51133E70141176B7B8AC4E9712 (SwiftUICore)

package import Foundation

// MARK: - Image.DynamicRange

@available(OpenSwiftUI_v5_0, *)
// @_spi_available(watchOS, introduced: 10.0)
extension Image {
    public struct DynamicRange: Hashable, Sendable {
        package enum Storage: UInt8, Hashable, Comparable {
            case standard
            case constrainedHigh
            case high

            package static func < (lhs: Image.DynamicRange.Storage, rhs: Image.DynamicRange.Storage) -> Bool {
                lhs.rawValue < rhs.rawValue
            }
        }

        package var storage: Image.DynamicRange.Storage

        package init(storage: Image.DynamicRange.Storage) {
            self.storage = storage
        }

        /// Restrict the image content dynamic range to the standard range.
        public static let standard: Image.DynamicRange = .init(storage: .standard)

        /// Allow image content to use some extended range. This is
        /// appropriate for placing HDR content next to SDR content.
        public static let constrainedHigh: Image.DynamicRange = .init(storage: .constrainedHigh)

        /// Allow image content to use an unrestricted extended range.
        public static let high: Image.DynamicRange = .init(storage: .high)

        package var maxHeadroom: Image.Headroom {
            switch storage {
            case .standard: .standard
            case .constrainedHigh: .constrainedHigh
            case .high: .high
            }
        }
    }

    package struct Headroom: RawRepresentable, Comparable {
        package let rawValue: CGFloat

        package init(rawValue: CGFloat) {
            self.rawValue = rawValue
        }

        package static func < (lhs: Image.Headroom, rhs: Image.Headroom) -> Bool {
            lhs.rawValue < rhs.rawValue
        }

        package static let standard: Image.Headroom = .init(rawValue: 1.0)

        package static let constrainedHigh: Image.Headroom = .init(rawValue: 2.0)

        package static let highHLG: Image.Headroom = .init(rawValue: 5.0)

        package static let high: Image.Headroom = .init(rawValue: 8.0)
    }

    /// Returns a new image configured with the specified allowed
    /// dynamic range.
    ///
    /// The following example enables HDR rendering for a specific
    /// image view, assuming that the image has an HDR (ITU-R 2100)
    /// color space and the output device supports it:
    ///
    ///     Image("hdr-asset").allowedDynamicRange(.high)
    ///
    /// - Parameter range: the requested dynamic range, or nil to
    ///   restore the default allowed range.
    ///
    /// - Returns: a new image.
    public func allowedDynamicRange(_ range: Image.DynamicRange?) -> Image {
        Image(
            DynamicRangeProvider(
                base: self,
                allowedDynamicRange: range
            )
        )
    }
}

// MARK: - DynamicRangeProvider

private struct DynamicRangeProvider: ImageProvider {
    var base: Image

    var allowedDynamicRange: Image.DynamicRange?

    func resolve(in context: ImageResolutionContext) -> Image.Resolved {
        var context = context
        if let allowedDynamicRange {
            context.allowedDynamicRange = allowedDynamicRange
        }
        return base.resolve(in: context)
    }

    func resolveNamedImage(in context: ImageResolutionContext) -> Image.NamedResolved? {
        var context = context
        if let allowedDynamicRange {
            context.allowedDynamicRange = allowedDynamicRange
        }
        return base.resolveNamedImage(in: context)
    }
}

// MARK: - EnvironmentValues + DynamicRange

private struct AllowedDynamicRangeKey : EnvironmentKey {
    static var defaultValue: Image.DynamicRange? { nil }
}

@available(OpenSwiftUI_v5_0, *)
// @_spi_available(watchOS, introduced: 10.0)
extension EnvironmentValues {
    /// The allowed dynamic range for the view, or nil.
    public var allowedDynamicRange: Image.DynamicRange? {
        get { self[AllowedDynamicRangeKey.self] }
        set { self[AllowedDynamicRangeKey.self] = newValue }
    }
}

struct MaxAllowedDynamicRangeKey: BridgedEnvironmentKey {
    static var defaultValue: Image.DynamicRange? { nil }
}

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
extension EnvironmentValues {
    public var maxAllowedDynamicRange: Image.DynamicRange? {
        get { self[MaxAllowedDynamicRangeKey.self] }
        set { self[MaxAllowedDynamicRangeKey.self] = newValue }
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, *)
@_spi_available(watchOS, introduced: 10.0)
extension View {

    /// Returns a new view configured with the specified allowed
    /// dynamic range.
    ///
    /// The following example enables HDR rendering within a view
    /// hierarchy:
    ///
    ///     MyView().allowedDynamicRange(.high)
    ///
    /// - Parameter range: the requested dynamic range, or nil to
    ///   restore the default allowed range.
    ///
    /// - Returns: a new view.
    @_alwaysEmitIntoClient
    nonisolated
    public func allowedDynamicRange(_ range: Image.DynamicRange?) -> some View {
        return environment(\.allowedDynamicRange, range)
    }
}

// MARK: - DynamicRange + ProtobufEnum

extension Image.DynamicRange: ProtobufEnum {
    package var protobufValue: UInt {
        UInt(storage.rawValue)
    }

    package init?(protobufValue value: UInt) {
        guard let storage = Image.DynamicRange.Storage(rawValue: UInt8(value)) else {
            return nil
        }
        self.storage = storage
    }
}
