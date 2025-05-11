//
//  DisplayList.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: F37E3733E490AA5E3BDC045E3D34D9F8 (SwiftUICore)

package import Foundation

// MARK: - _DisplayList_Identity

private var lastIdentity: UInt32 = 0

package struct _DisplayList_Identity: Hashable, Codable, CustomStringConvertible {
    package private(set) var value: UInt32
    
    init(value: UInt32) {
        self.value = value
    }
    
    package init() {
        lastIdentity += 1
        self.init(value: lastIdentity)
    }
    
    package init(decodedValue value: UInt32) {
        self.init(value: value)
    }
    
    package static let none = _DisplayList_Identity(value: 0)
    package var description: String { "#\(value)" }
}

// MARK: - DisplayList

package struct DisplayList: Equatable {
    package private(set) var items: [Item]
    
    package struct Features: OptionSet {
        package let rawValue: UInt16
        package init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
        package static let required = Features(rawValue: 1 << 0)
        package static let views = Features(rawValue: 1 << 1)
        package static let animations = Features(rawValue: 1 << 2)
        package static let dynamicContent = Features(rawValue: 1 << 3)
        package static let interpolatorLayers = Features(rawValue: 1 << 4)
        package static let interpolatorRoots = Features(rawValue: 1 << 5)
        package static let stateEffects = Features(rawValue: 1 << 6)
        package static let states = Features(rawValue: 1 << 7)
        package static let flattened = Features(rawValue: 1 << 9)
    }
    
    package private(set) var features: Features
    package private(set) var properties: Properties

    package init() {
        items = []
        features = []
        properties = []
    }
    
    package init(_ item: Item) {
        switch item.value {
        case .empty:
            items = []
            features = []
            properties = []
        default:
            items = [item]
            features = item.features
            properties = item.properties
        }
    }
    
    // TO BE VERIFIED
    package init(_ items: [Item]) {
        var features: Features = []
        var properties: Properties = []
        for item in items {
            features.formUnion(item.features)
            properties.formUnion(item.properties)
        }
        self.items = items
        self.features = features
        self.properties = properties
    }
    
    package mutating func append(_ item: Item) {
        preconditionFailure("TODO")
    }
    
    package mutating func append(contentsOf other: DisplayList) {
        preconditionFailure("TODO")
    }    
}

@available(*, unavailable)
extension DisplayList: Sendable {}

@available(*, unavailable)
extension DisplayList.Version: Sendable {}

extension DisplayList {
    package typealias Identity = _DisplayList_Identity

    package typealias StableIdentity = _DisplayList_StableIdentity

    package typealias StableIdentityMap = _DisplayList_StableIdentityMap

    package typealias StableIdentityRoot = _DisplayList_StableIdentityRoot

    package typealias StableIdentityScope = _DisplayList_StableIdentityScope

    package struct Item: Equatable {
        package var frame: CGRect

        package var version: Version

        package var value: Item.Value

        package var identity: Identity

        package enum Value {
            case empty
            case content(Content)
            case effect(Effect, DisplayList)
            case states([(StrongHash, DisplayList)])
        }

        package init(_ value: Item.Value, frame: CGRect, identity: Identity, version: Version) {
            self.frame = frame
            self.version = version
            self.value = value
            self.identity = identity
        }
        
        package static func == (lhs: Item, rhs: Item) -> Bool {
            lhs.identity == rhs.identity && lhs.version == rhs.version
        }
        
        package var position: CGPoint { frame.origin }

        package var size: CGSize { frame.size }
    }
    
    package struct Content {
        package var value: Content.Value

        package var seed: Seed

        package enum Value {
            indirect case backdrop(BackdropEffect)
            indirect case color(Color.Resolved)
            indirect case chameleonColor(fallback: Color.Resolved, filters: [GraphicsFilter])
            indirect case image(GraphicsImage)
            indirect case shape(Path, AnyResolvedPaint, FillStyle)
            indirect case shadow(Path, ResolvedShadowStyle)
            indirect case platformView(any PlatformViewFactory)
            indirect case platformLayer(any PlatformLayerFactory)
            indirect case text(StyledTextContentView, CGSize)
            indirect case flattened(DisplayList, CGPoint, RasterizationOptions)
            indirect case drawing(any RBDisplayListContents, CGPoint, RasterizationOptions)
            indirect case view(any _DisplayList_ViewFactory)
            case placeholder(id: Identity)
        }
        package init(_ value: Content.Value, seed: Seed) {
            self.value = value
            self.seed = seed
        }
    }

//    package typealias ViewFactory = _DisplayList_ViewFactory

    package enum Effect {
        case identity
        case geometryGroup
        case compositingGroup
        case backdropGroup(Bool)
        indirect case archive(ArchiveIDs?)
        case properties(Properties)
        indirect case platformGroup(any PlatformGroupFactory)
        case opacity(Float)
        case blendMode(GraphicsBlendMode)
        indirect case clip(Path, FillStyle, _: GraphicsContext.ClipOptions = .init())
        indirect case mask(DisplayList, _: GraphicsContext.ClipOptions = .init())
        indirect case transform(Transform)
        indirect case filter(GraphicsFilter)
        indirect case animation(any _DisplayList_AnyEffectAnimation)
        indirect case contentTransition(ContentTransition.State)
        indirect case view(any _DisplayList_ViewFactory)
        indirect case accessibility([AccessibilityNodeAttachment])
        indirect case platform(PlatformEffect)
        indirect case state(StrongHash)
        indirect case interpolatorRoot(InterpolatorGroup, contentOrigin: CGPoint, contentOffset: CGSize)
        case interpolatorLayer(InterpolatorGroup, serial: UInt32)
        indirect case interpolatorAnimation(InterpolatorAnimation)
    }
        
    package enum Transform {
        #if canImport(Darwin)
        case affine(CGAffineTransform)
        #endif
        case projection(ProjectionTransform)
        // case rotation(_RotationEffect.Data)
        // case rotation3D(_Rotation3DEffect.Data)
    }
    
//    package typealias AnyEffectAnimation = _DisplayList_AnyEffectAnimation
//    package typealias AnyEffectAnimator = _DisplayList_AnyEffectAnimator
    
    package struct ArchiveIDs {
        package var uuid: UUID
        package var stableIDs: StableIdentityMap
        package init(uuid: UUID, stableIDs: StableIdentityMap) {
            self.uuid = uuid
            self.stableIDs = stableIDs
        }
    }
    
    package struct InterpolatorAnimation {
        package var value: StrongHash?
        package var animation: Animation?
    }
    
    package struct Version: Comparable, Hashable {
        private static var lastValue: Int = .zero
        
        package private(set) var value: Int
        
        package init() { value = .zero }
        
        package init(decodedValue value: Int) {
            Version.lastValue = max(Version.lastValue, value)
            self.value = value
        }
        
        package init(forUpdate: Void) {
            Version.lastValue &+= 1
            value = Version.lastValue
        }
        
        package mutating func combine(with other: Version) {
            value = max(value, other.value)
        }

        package static func < (lhs: Version, rhs: Version) -> Bool {
            lhs.value < rhs.value
        }
    }

    package struct Seed: Hashable {
        package private(set) var value: UInt16
        
        init(value: UInt16) {
            self.value = value
        }
        
        package init() {
            self.init(value: .zero)
        }

        package init(decodedValue value: UInt16) {
            self.init(value: value)
        }

        package init(_ version: Version) {
            if version.value == .zero {
                self.init(value: .zero)
            } else {
                var rawValue = UInt32(bitPattern: Int32(truncatingIfNeeded: version.value >> 16))
                rawValue += (rawValue << 5)
                rawValue ^= UInt32(bitPattern: Int32(truncatingIfNeeded: version.value))
                rawValue = 1 | (rawValue << 1)
                self.init(value: UInt16(truncatingIfNeeded: rawValue))
            }
        }
        
        package mutating func invalidate() {
            guard value != .zero else { return }
            value = (~value | 1)
        }
        
        package static let undefined: Seed = Seed(value: 2)
    }
    
    package struct Properties: OptionSet {
        package let rawValue: UInt8
        package init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
        package static let foregroundLayer = Properties(rawValue: 1 << 0)
        package static let ignoresEvents = Properties(rawValue: 1 << 1)
        package static let privacySensitive = Properties(rawValue: 1 << 2)
        package static let archivesInteractiveControls = Properties(rawValue: 1 << 3)
        package static let secondaryForegroundLayer = Properties(rawValue: 1 << 4)
        package static let tertiaryForegroundLayer = Properties(rawValue: 1 << 5)
        package static let quaternaryForegroundLayer = Properties(rawValue: 1 << 6)
        package static let screencaptureProhibited = Properties(rawValue: 1 << 7)
    }
    
    package struct Key: PreferenceKey {
        package static let _includesRemovedValues: Bool = true
        package static let defaultValue = DisplayList()
        package static func reduce(value: inout DisplayList, nextValue: () -> DisplayList) {
            value.append(contentsOf: nextValue())
        }
    }
    
    package struct Options: OptionSet, ViewInput {
        package let rawValue: UInt8
        package init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        package static let disableCanonicalization = Options(rawValue: 1 << 0)
        package static let defaultValue: Options = []
    }
    
    package struct Index {
        package private(set) var identity: _DisplayList_Identity = .none
        package private(set) var serial: UInt32 = .zero
        package private(set) var archiveIdentity: _DisplayList_Identity = .none
        package private(set) var archiveSerial: UInt32 = .zero
        private var restored: RestoreOptions = []
        
        package init() {}
        package mutating func enter(identity: Identity) -> Index {
            if identity == .none {
                self.serial &+= 1
                let copy = self
                self.restored = []
                return copy
            } else {
                let copy = self
                self.identity = identity
                self.serial = 0
                self.restored = ._1
                return copy
            }
        }
        
        package mutating func leave(index saved: Index) {
            if restored.contains(._4) || saved.restored.contains(._8) {
                let oldIdentity = identity
                let oldSerial = serial
                if restored.contains(._4) {
                    identity = archiveIdentity
                    serial = archiveSerial
                }
                if restored.contains(._8) {
                    archiveIdentity = oldIdentity
                    archiveSerial = oldSerial
                }
            }
            if restored.contains(._1) {
                identity = saved.identity
                serial = saved.serial
            }
            if restored.contains(._2) {
                archiveIdentity = saved.archiveIdentity
                archiveSerial = saved.archiveSerial
            }
            restored = saved.restored
        }
        
        package mutating func updateArchive(entering: Bool) {
            if entering {
                archiveIdentity = identity
                archiveSerial = serial
                identity = .none
                serial = .zero
                if !restored.contains([._2, ._4]) {
                    restored = restored.union([._2, ._4])
                }
            } else {
                // false
                identity = archiveIdentity
                serial = archiveSerial
                archiveIdentity = .none
                archiveSerial = .zero
                if !restored.contains([._1, ._8]) {
                    restored = restored.union([._1, ._8])
                }
            }
        }
        
        package mutating func skip(list: DisplayList) {
            preconditionFailure("TODO")
        }
        
        package mutating func skip(item: Item) {
            preconditionFailure("TODO")
        }
        
        package mutating func skip(effect: Effect) {
            
            preconditionFailure("TODO")
        }
        
        package func assertItem(_ item: Item) {}
        
        package var id: ID {
            ID(identity: identity, serial: serial, archiveIdentity: archiveIdentity, archiveSerial: archiveSerial)
        }
        
        package struct ID: Hashable {
            var identity: _DisplayList_Identity
            var serial: UInt32
            var archiveIdentity: _DisplayList_Identity
            var archiveSerial: UInt32
        }
        
        private struct RestoreOptions: OptionSet {
            let rawValue: UInt8
            
            static let _1 = RestoreOptions(rawValue: 1 << 0)
            static let _2 = RestoreOptions(rawValue: 1 << 1)
            static let _4 = RestoreOptions(rawValue: 1 << 2)
            static let _8 = RestoreOptions(rawValue: 1 << 3)
        }
    }
}

// MARK: - DisplayList.Item + Extension

extension DisplayList.Item {
    package mutating func canonicalize(options: DisplayList.Options = .init()) {
        // TODO
    }

    // package func matchesTopLevelStructure(of other: DisplayList.Item) -> Bool

    package var features: DisplayList.Features {
        // TODO
        []
    }
}

// TODO

extension DisplayList {
    // FIXME
    package class InterpolatorGroup {}
}

package struct AccessibilityNodeAttachment {}

extension GraphicsContext {
    @frozen
    public struct ClipOptions: OptionSet {
        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
}

package protocol PlatformGroupFactory {}
package protocol _DisplayList_AnyEffectAnimation {}

public struct ContentTransition {
    package struct State {}
}
package protocol _DisplayList_ViewFactory {}

package protocol PlatformViewFactory {}
package protocol PlatformLayerFactory {}

package struct GraphicsImage {}
package struct ResolvedShadowStyle {}

package struct StyledTextContentView {}
package struct RasterizationOptions {}
package protocol RBDisplayListContents {} // RenderBox.RBDisplayListContents
public struct PlatformDrawableOptions {}
public protocol PlatformDrawable : AnyObject {}
