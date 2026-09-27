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

@available(OpenSwiftUI_v3_0, *)
public protocol AXChartDescriptorRepresentable {
    func makeChartDescriptor() -> AXChartDescriptor

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
