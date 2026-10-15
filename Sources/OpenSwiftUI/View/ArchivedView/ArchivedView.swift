//
//  ArchivedView.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Blocked by ArchiveReader, DisplayList.HostedViews, DisplayList.AccessibilityUpdater, NamedImage.Cache, and DisplayList protobuf coding
//  ID: 145AEADE96C7CFB715E6BB334BECE23C (SwiftUI)

public import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
@_spi(ForSwiftUIOnly)
@_spi(Private)
public import OpenSwiftUICore

// MARK: - _ArchivedViewStates

@_spi(Private)
@available(OpenSwiftUI_v2_0, *)
public struct _ArchivedViewStates: RandomAccessCollection {
    // TODO: ArchiveReader
    // The archive reader stores the attachments that `metadata` indexes.
    var metadata: ArchivedViewCore.Metadata
    var stableIDs: _DisplayList_StableIdentityMap?
    var cache: MutableBox<[Int: Any]>
    var delegate: AnyArchivedViewDelegate?

    @_spi(Private)
    @available(OpenSwiftUI_v3_0, *)
    @available(*, deprecated, message: "no longer supported")
    public struct EncodingStyle {
        public static let binaryPlist: EncodingStyle = .init()

        public static let json: EncodingStyle = .init()
    }

    public init() {
        stableIDs = nil
        cache = MutableBox([:])
        delegate = nil
        metadata = ArchivedViewCore.Metadata()
    }

    public init(data: Data) throws {
        // TODO: DataArchiveReader
        _openSwiftUIUnimplementedFailure()
    }

    public init(contentsOf url: URL) throws {
        precondition(url.isFileURL, "The archive URL must be a file URL.")
        // TODO: FileArchiveReader
        _openSwiftUIUnimplementedFailure()
    }

    public init(contentsOf file: FileHandle) throws {
        // TODO: FileArchiveReader
        _openSwiftUIUnimplementedFailure()
    }

    @available(OpenSwiftUI_v4_0, *)
    public init<D>(data: Data, delegate: D) throws where D: ArchivedViewDelegate {
        // TODO: DataArchiveReader
        _openSwiftUIUnimplementedFailure()
    }

    @available(OpenSwiftUI_v4_0, *)
    public init<D>(contentsOf url: URL, delegate: D) throws where D: ArchivedViewDelegate {
        precondition(url.isFileURL, "The archive URL must be a file URL.")
        // TODO: FileArchiveReader
        _openSwiftUIUnimplementedFailure()
    }

    @available(OpenSwiftUI_v4_0, *)
    public init<D>(contentsOf file: FileHandle, delegate: D) throws where D: ArchivedViewDelegate {
        // TODO: FileArchiveReader
        _openSwiftUIUnimplementedFailure()
    }

    // TODO: ArchiveReader
    // private init(reader: ArchiveReader, delegate: AnyArchivedViewDelegate?) throws
    //
    // Decodes the last attachment as `ArchivedViewCore.Metadata` with a
    // `JSONDecoder`, rejects a `majorVersion` that differs from
    // `ArchivedViewCore.majorVersion` with `Error.invalidArchiveVersion`,
    // and, when `metadata.stableIDsAttachment` is set, decodes that attachment
    // as `_DisplayList_StableIdentityMap` with a `ProtobufDecoder` after
    // checking that the index is within the reader, otherwise throwing
    // `Error.invalidStableIDAttachment`. It registers the standard decoders
    // through `ViewDecoders.registerStandardArchiveDecoders()` first.

    public var startIndex: Int {
        0
    }

    public var endIndex: Int {
        metadata.stateAttachments.count
    }

    public subscript(index: Int) -> _ArchivedView {
        (try? state(at: index)) ?? _ArchivedView()
    }

    public func state(at index: Int) throws -> _ArchivedView {
        precondition(index >= 0 && index < metadata.stateAttachments.count, "Archived view state index out of range.")
        // TODO: ArchiveReader
        // Reads `reader[metadata.stateAttachments[index]]`, decodes `State`
        // with a `ProtobufDecoder` whose user info is filled by
        // `makeUserInfo(_:)`, and returns a view with the decoded state, the
        // metadata archive ID, the stable IDs, and `index`.
        _openSwiftUIUnimplementedFailure()
    }

    private func makeUserInfo(_ userInfo: inout [CodingUserInfoKey: Any]) {
        // TODO: ArchiveReader.readerKey, ArchiveReader.cacheKey,
        // ArchiveReader.namedImagesKey, NamedImage.Cache,
        // ArchivedViewCore.preferredBundleLanguageKey, and
        // ArchivedViewCore.preferredCompositionLanguageKey
        _openSwiftUIUnimplementedWarning()
    }

    public var auxiliaryData: Data? {
        guard metadata.dataAttachment != nil else {
            return nil
        }
        // TODO: ArchiveReader
        _openSwiftUIUnimplementedFailure()
    }

    public func attachment(at index: Int) -> Data? {
        // TODO: ArchiveReader
        _openSwiftUIUnimplementedFailure()
    }

    struct State: ProtobufDecodableMessage, ProtobufEncodableMessage {
        var size: CGSize
        var list: DisplayList

        struct Tag: ProtobufTag {
            let rawValue: UInt

            init(rawValue: UInt) {
                self.rawValue = rawValue
            }

            static let size: Tag = .init(rawValue: 1)

            static let list: Tag = .init(rawValue: 2)
        }

        init(size: CGSize = .zero, list: DisplayList = .init()) {
            self.size = size
            self.list = list
        }

        init(from decoder: inout ProtobufDecoder) throws {
            var size: CGSize = .zero
            var list: DisplayList = .init()
            while let field = try decoder.nextField() {
                switch field.tag(as: Tag.self) {
                case .size:
                    size = try decoder.messageField(field)
                case .list:
                    // TODO: DisplayList protobuf coding
                    // SwiftUI decodes the display list message here.
                    try decoder.skipField(field)
                default:
                    try decoder.skipField(field)
                }
            }
            self.size = size
            self.list = list
        }

        func encode(to encoder: inout ProtobufEncoder) throws {
            try encoder.messageField(Tag.size.rawValue, size)
            // TODO: DisplayList protobuf coding
            // SwiftUI encodes `list` under `Tag.list`.
            _openSwiftUIUnimplementedWarning()
        }
    }

    enum Error: Swift.Error {
        case unknownUUID(UUID)
        case invalidArchiveVersion
        case invalidStableIDAttachment
    }
}

@_spi(Private)
@available(*, unavailable)
extension _ArchivedViewStates: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension _ArchivedViewStates.EncodingStyle: Sendable {}

// MARK: - _ArchivedViewStates.DeploymentVersion

@_spi(Private)
extension _ArchivedViewStates {
    @available(OpenSwiftUI_v6_0, *)
    public struct DeploymentVersion: Hashable, Comparable, Codable, Sendable {
        var base: ArchivedViewInput.DeploymentVersion

        init(base: ArchivedViewInput.DeploymentVersion) {
            self.base = base
        }

        public static let v5: DeploymentVersion = .init(base: .v5)

        public static let v6: DeploymentVersion = .init(base: .v6)

        @_alwaysEmitIntoClient
        public static var current: DeploymentVersion { .v6 }

        public static func < (
            lhs: DeploymentVersion,
            rhs: DeploymentVersion
        ) -> Bool {
            lhs.base < rhs.base
        }
    }
}

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
extension _ArchivedViewStates.DeploymentVersion {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(base.rawValue)
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        base = .init(rawValue: try container.decode(Int8.self))
    }
}

// MARK: - ViewDecoders + Archive

extension ViewDecoders {
    static func registerStandardArchiveDecoders() {
        registerStandard {
            // TODO: ArchivableLinkModifier
            // TODO: TimelineProgressView<ArchivableLinearProgressView.Base>.ArchivableTimelineProgressView
            // TODO: TimelineProgressView<CircularPercentageGaugeRing>.ArchivableTimelineProgressView
            HandGestureShortcutInteractiveControl.HandGestureShortcutPreferenceWriter.registerDecoder()
            // TODO: TimelineProgressView<ResolvedCircularPlaybackProgressView.Base>.ArchivableTimelineProgressView
            // TODO: ArchivableButtonAppIntentModifier
            ArchivableToggleAppIntentModifier.registerDecoder()
            // TODO: ArchivablePlaybackButtonViewModifier
            ArchivableAccessibilityActionModifier.registerDecoder()
            // TODO: ArchivableAccessibilityViewModifier.Factory
            // TODO: InvalidatableContentModifier
        }
    }
}

// MARK: - _ArchivedView

@_spi(Private)
@available(OpenSwiftUI_v2_0, *)
public struct _ArchivedView: UnaryView, PrimitiveView, Equatable {
    var state: _ArchivedViewStates.State
    var index: Int
    var archiveID: UUID
    var stableIDs: _DisplayList_StableIdentityMap?
    var maxAnimationDurationStorage: Float

    public init() {
        state = .init()
        index = 0
        archiveID = UUID()
        stableIDs = nil
        maxAnimationDurationStorage = 2
    }

    public var containsForegroundLayers: Bool {
        contains(.foregroundLayer)
    }

    func containsForegroundLayers(level: _ForegroundLayerLevel) -> Bool {
        contains(level.properties)
    }

    public var containsPrivacySensitive: Bool {
        contains(.privacySensitive)
    }

    public var containsInteractiveControls: Bool {
        contains(.archivesInteractiveControls)
    }

    public var maxAnimationDuration: Double {
        get { Double(maxAnimationDurationStorage) }
        set { maxAnimationDurationStorage = Float(newValue) }
    }

    private func contains(_ properties: DisplayList.Properties) -> Bool {
        !state.list.properties.intersection(properties).isEmpty
    }

    public static func == (lhs: _ArchivedView, rhs: _ArchivedView) -> Bool {
        lhs.index == rhs.index && lhs.archiveID == rhs.archiveID
    }

    nonisolated public static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        var outputs = _ViewOutputs()
        let interpolatorGroup = DisplayList.UnaryInterpolatorGroup()
        let requiresDisplayList = inputs.preferences.requiresDisplayList
        let requiresAccessibilityNodes = inputs.preferences.requiresAccessibilityNodes
        var inputs = inputs
        if requiresDisplayList {
            inputs.preferences.add(ArchivedViewStatesKey.self)
        }
        inputs.containerPosition = inputs.animatedPosition()
        let identity = DisplayList.Identity()
        inputs.pushIdentity(identity)
        let displayList = Attribute(ArchivedDisplayList(
            interpolatorGroup: interpolatorGroup,
            identity: identity,
            view: view.value,
            size: inputs.animatedSize()
        ))
        inputs.needsDisplayListAccessibility = true
        // TODO: _ViewInputs.EnvironmentTransform
        // TODO: DisplayList.HostedViews
        // SwiftUI keeps a hosted view state box for the current subgraph,
        // creates the hosted views attribute from it, and splices the hosted
        // view display lists into `displayList`.
        if requiresDisplayList {
            outputs.displayList = displayList
            // TODO: DisplayList.HostedViews.Preference<ArchivedViewStatesKey>
            // The archived view states preference feeds
            // `InterpolatableArchiveContent.Init`, which is applied with
            // `outputs.applyInterpolatorGroup(interpolatorGroup, content:, inputs:, animatesSize: true, defersRender: true)`.
            _openSwiftUIUnimplementedWarning()
        }
        if inputs.preferences.contains(ViewRespondersKey.self) {
            // TODO: DisplayList.HostedViewResponder and DisplayList.HostedViews.ResponderFilter
            _openSwiftUIUnimplementedWarning()
        }
        if inputs.requestsLayoutComputer {
            outputs.layoutComputer = Attribute(ArchivedLayoutComputer(view: view.value))
        }
        if requiresAccessibilityNodes {
            // TODO: DisplayList.AccessibilityUpdater and ArchivedAccessibilityAttachment
            _openSwiftUIUnimplementedWarning()
        }
        var visitor = ArchivedViewPreferenceVisitor(outputs: outputs)
        for key in inputs.preferences.keys {
            key.visitKey(&visitor)
        }
        return visitor.outputs
    }
}

private struct ArchivedViewPreferenceVisitor: PreferenceKeyVisitor {
    var outputs: _ViewOutputs

    mutating func visit<Key>(key: Key.Type) where Key: PreferenceKey {
        guard key != DisplayList.Key.self,
              key != ViewRespondersKey.self,
              key != AccessibilityNodesKey.self,
              key != ArchivedViewStatesKey.self
        else {
            return
        }
        // TODO: DisplayList.HostedViews.Preference<Key>
        // SwiftUI appends a hosted views preference attribute for every other key.
    }
}

// MARK: - _AnyArchivedViewDelegate

private final class _AnyArchivedViewDelegate<D>: AnyArchivedViewDelegate where D: ArchivedViewDelegate {
    var delegate: D

    init(_ delegate: D) {
        self.delegate = delegate
        super.init()
    }

    override func resolveImage(uuid: UUID) throws -> Image.ResolvedUUID {
        try delegate.resolveImage(uuid: uuid)
    }
}

// MARK: - ArchivedViewState

struct ArchivedViewState: Equatable {
    var id: ID
    var animation: Animation?

    struct ID: Hashable {
        var hash: StrongHash
        var creator: AnyAttribute
    }
}

// MARK: - ArchivedViewStatesKey

struct ArchivedViewStatesKey: PreferenceKey {
    static var defaultValue: [ArchivedViewState] { [] }

    static func reduce(value: inout [ArchivedViewState], nextValue: () -> [ArchivedViewState]) {
        value.append(contentsOf: nextValue())
    }
}

// MARK: - InterpolatableArchiveContent

private struct InterpolatableArchiveContent: InterpolatableContent, Equatable {
    var index: Int
    var archiveID: UUID
    var hasStableIDs: Bool
    var states: [ArchivedViewState]

    struct Init: Rule {
        @Attribute var view: _ArchivedView
        @Attribute var states: [ArchivedViewState]

        var value: InterpolatableArchiveContent {
            InterpolatableArchiveContent(
                index: view.index,
                archiveID: view.archiveID,
                hasStableIDs: view.stableIDs != nil,
                states: states
            )
        }
    }

    static let defaultTransition: ContentTransition = .init(
        storage: .named(ContentTransition.NamedTransition(name: .fadeIfDifferent))
    )

    func modifyTransition(state: inout ContentTransition.State, to other: InterpolatableArchiveContent) {
        guard archiveID != other.archiveID else {
            return
        }
        if hasStableIDs, other.hasStableIDs {
            return
        }
        state.transition.storage = .named(ContentTransition.NamedTransition(name: .opacity))
    }

    func defaultAnimation(to other: InterpolatableArchiveContent) -> Animation? {
        var oldIDs: Set<ArchivedViewState.ID>?
        for state in other.states {
            guard let animation = state.animation else {
                continue
            }
            if oldIDs == nil {
                oldIDs = Set(states.map(\.id))
            }
            if oldIDs!.contains(state.id) {
                continue
            }
            return animation
        }
        return nil
    }
}

// MARK: - ArchivedDisplayList

private struct ArchivedDisplayList: StatefulRule {
    let interpolatorGroup: DisplayList.UnaryInterpolatorGroup
    let identity: DisplayList.Identity
    @Attribute var view: _ArchivedView
    @Attribute var size: ViewSize

    typealias Value = DisplayList

    mutating func updateValue() {
        let version = DisplayList.Version(forUpdate: ())
        let view = view
        let archiveIDs = DisplayList.ArchiveIDs(
            uuid: view.archiveID,
            stableIDs: view.stableIDs ?? .init()
        )
        interpolatorGroup.maxDuration = view.maxAnimationDuration
        var item = DisplayList.Item(
            .effect(.archive(archiveIDs), view.state.list),
            frame: CGRect(origin: .zero, size: size.value),
            identity: identity,
            version: version
        )
        item.canonicalize()
        // TODO: DisplayList.UnaryInterpolatorGroup.apply
        // SwiftUI lets the interpolator group rewrite the item before the
        // list is published.
        value = DisplayList(item)
    }
}

// TODO: ArchivedAccessibilityAttachment (Blocked by DisplayList.AccessibilityUpdater)
//
// private struct ArchivedAccessibilityAttachment: StatefulRule {
//     @Attribute var list: DisplayList
//     @Attribute var accessibilityEnabled: Bool
//     @Attribute var phase: _GraphInputs.Phase
//     @Attribute var position: CGPoint
//     @Attribute var size: ViewSize
//     @Attribute var transform: ViewTransform
//     var resetSeed: UInt32
//     let updater: DisplayList.AccessibilityUpdater
//
//     typealias Value = AccessibilityNodeList
// }
//
// When accessibility is disabled the rule publishes an empty node list and,
// if the list attribute changed, recreates the updater root and clears its
// cache. Otherwise it recreates the root when the phase reset seed changed,
// resets the transform position, runs the updater over the list with the
// transform and size, and publishes the root node with the updater's latest
// version when the update reported changes or no value exists yet.

// MARK: - ArchivedLayoutComputer

private struct ArchivedLayoutComputer: StatefulRule {
    @Attribute var view: _ArchivedView
    var lastSize: CGSize = .zero

    typealias Value = LayoutComputer

    mutating func updateValue() {
        let size = view.state.size
        guard size != lastSize || !hasValue else {
            return
        }
        update(to: Engine(size: size))
        lastSize = size
    }

    struct Engine: LayoutEngine {
        let size: CGSize

        func sizeThatFits(_ proposedSize: _ProposedSize) -> CGSize {
            size
        }
    }
}
