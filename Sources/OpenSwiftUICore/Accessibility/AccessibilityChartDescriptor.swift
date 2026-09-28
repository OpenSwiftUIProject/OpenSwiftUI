//
//  AccessibilityChartDescriptor.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 7BC255353E40EE9AA85BDA85829B61DC (SwiftUICore)

#if canImport(Accessibility)
public import Accessibility
#endif
import libAccessibilityPrivate
import Foundation
import OpenAttributeGraphShims
import OpenSwiftUI_SPI

/// A type to generate an `AXChartDescriptor` object that you use to provide
/// information about a chart and its data for an accessible experience
/// in VoiceOver or other assistive technologies.
///
/// Note that you may use the `@Environment` property wrapper inside the
/// implementation of your `AXChartDescriptorRepresentable`, in which case you
/// should implement `updateChartDescriptor`, which will be called when the
/// `Environment` changes.
///
/// For example, to provide accessibility for a view that represents a chart,
/// you would first declare your chart descriptor representable type:
///
///     struct MyChartDescriptorRepresentable: AXChartDescriptorRepresentable {
///         func makeChartDescriptor() -> AXChartDescriptor {
///             // Build and return your `AXChartDescriptor` here.
///         }
///
///         func updateChartDescriptor(_ descriptor: AXChartDescriptor) {
///             // Update your chart descriptor with any new values.
///         }
///     }
///
/// Then, provide an instance of your `AXChartDescriptorRepresentable` type to
/// your view using the `accessibilityChartDescriptor` modifier:
///
///     var body: some View {
///         MyChartView()
///             .accessibilityChartDescriptor(MyChartDescriptorRepresentable())
///     }
///
@available(OpenSwiftUI_v3_0, *)
public protocol AXChartDescriptorRepresentable {
    /// Create the `AXChartDescriptor` for this view, and return it.
    ///
    /// This will be called once per identity of your `View`. It will not be run
    /// again unless the identity of your `View` changes. If you need to
    /// update the `AXChartDescriptor` based on changes in your `View`, or in
    /// the `Environment`, implement `updateChartDescriptor`.
    /// This method will only be called if / when accessibility needs the
    /// `AXChartDescriptor` of your view, for VoiceOver.
    func makeChartDescriptor() -> AXChartDescriptor

    /// Update the existing `AXChartDescriptor` for your view, based on changes
    /// in your view or in the `Environment`.
    ///
    /// This will be called as needed, when accessibility needs your
    /// `AXChartDescriptor` for VoiceOver. It will only be called if the inputs
    /// to your views, or a relevant part of the `Environment`, have changed.
    func updateChartDescriptor(_ descriptor: AXChartDescriptor)
}

@available(OpenSwiftUI_v3_0, *)
extension AXChartDescriptorRepresentable {
    public func updateChartDescriptor(_ descriptor: AXChartDescriptor) {
        _openSwiftUIEmptyStub()
    }
}

package class AccessibilityChartDescriptorStorage: Equatable {
    package func resolve() throws -> AXChartDescriptor {
        _openSwiftUIBaseClassAbstractMethod()
    }

    package func isEqual(to other: AccessibilityChartDescriptorStorage) -> Bool {
        false
    }

    package static func == (lhs: AccessibilityChartDescriptorStorage, rhs: AccessibilityChartDescriptorStorage) -> Bool {
        lhs.isEqual(to: rhs)
    }
}

final package class RepresentableChartDescriptorStorage: AccessibilityChartDescriptorStorage {
    private var representable: any AXChartDescriptorRepresentable

    private var cachedDescriptor: AXChartDescriptor?

    private var needsUpdate: Bool

    private var generation: UInt32

    package init(_ representable: any AXChartDescriptorRepresentable) {
        self.representable = representable
        cachedDescriptor = nil
        needsUpdate = false
        generation = 0
    }

    package func reset() {
        generation = 0
        needsUpdate = false
        cachedDescriptor = nil
    }

    package func markNeedsUpdate(_ representable: any AXChartDescriptorRepresentable) {
        self.representable = representable
        generation.unsafeIncrement()
        needsUpdate = true
    }

    package override func resolve() throws -> AXChartDescriptor {
        if let cachedDescriptor {
            if needsUpdate {
                representable.updateChartDescriptor(cachedDescriptor)
                needsUpdate = false
            }
            return cachedDescriptor
        } else {
            let descriptor = representable.makeChartDescriptor()
            cachedDescriptor = descriptor
            needsUpdate = false
            return descriptor
        }
    }

    package override func isEqual(to other: AccessibilityChartDescriptorStorage) -> Bool {
        guard let other = other as? RepresentableChartDescriptorStorage else {
            return false
        }
        return generation == other.generation && compareValues(representable, other.representable)
    }
}

package struct CodableAXChartDescriptor: Codable {
    package var storage: AccessibilityChartDescriptorStorage

    package init(_ storage: AccessibilityChartDescriptorStorage) {
        self.storage = storage
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.decode(Data.self, forKey: .dictionaryData)
        storage = AccessibilitySpecificChartDescriptorStorage(data: data)
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let descriptor = try storage.resolve()
        let data = try NSKeyedArchiver.archivedData(
            withRootObject: descriptor.dictionaryRepresentation(),
            requiringSecureCoding: true
        )
        try container.encode(data, forKey: .dictionaryData)
    }

    private enum CodingKeys: String, CodingKey {
        case dictionaryData
    }
}

class AccessibilitySpecificChartDescriptorStorage: AccessibilityChartDescriptorStorage {
    private var storage: Storage

    init(_ descriptor: AXChartDescriptor) {
        storage = .resolved(descriptor)
    }

    init(data: Data) {
        storage = .data(data)
    }

    override func resolve() throws -> AXChartDescriptor {
        switch storage {
        case let .data(data):
            guard let dictionary = _AXOpenSwiftUIUnarchiveChartDescriptor(data) as? [AnyHashable: Any] else {
                throw ChartDescriptorArchiveError.unarchiveFailed
            }
            let descriptor = AXChartDescriptor(dictionary: dictionary)
            storage = .resolved(descriptor)
            return descriptor
        case let .resolved(descriptor):
            return descriptor
        }
    }

    override func isEqual(to other: AccessibilityChartDescriptorStorage) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        if case let (.data(lhs), .data(rhs)) = (storage, other.storage) {
            return lhs == rhs
        } else {
            guard let lhs = try? resolve(), let rhs = try? other.resolve() else {
                return false
            }
            return lhs.dictionaryRepresentation() as NSDictionary == rhs.dictionaryRepresentation() as NSDictionary
        }
    }

    private enum Storage {
        case data(Data)
        case resolved(AXChartDescriptor)
    }

    enum ChartDescriptorArchiveError: Error {
        case unarchiveFailed
    }
}
