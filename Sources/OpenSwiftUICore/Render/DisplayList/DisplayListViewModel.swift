//
//  DisplayListViewModel.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: CA3A65C294B7CEBAC4D3EE28C528C257 (SwiftUICore)

import OpenCoreGraphicsShims

// MARK: - DisplayList.ViewUpdater.Model

extension DisplayList.ViewUpdater {
    enum Model {
        static func merge(
            item: inout DisplayList.Item,
            index: DisplayList.Index,
            into state: inout Model.State
        ) -> MergedViewRequirements {
            if case let .states(states) = item.value {
                let list: DisplayList
                if let hash = state.stateHashes.popLast(),
                   let match = states.first(where: { $0.0 == hash }) {
                    list = match.1
                } else {
                    list = DisplayList()
                }
                item.value = .effect(.identity, list)
            }
            let shouldRewriteVibrancyFilter =
                (state.opacity != 1.0 && state.blend != .normal) ||
                state.rewriteVibrantColorMatrix ||
                state.filters.contains { filter in
                    switch filter {
                    case .colorMultiply: false
                    default: true
                    }
                }
            if shouldRewriteVibrancyFilter,
               case let .effect(effect, list) = item.value,
               case let .filter(filter) = effect,
               case let .vibrantColorMatrix(matrix) = filter {
                item.rewriteVibrancyFilterAsBackdrop(matrix: matrix, list: list)
            }
            var requirements: MergedViewRequirements = item.discardContainingClips(state: &state) ? .visibleContent : []

            if !state.clips.isEmpty {
                if !item.canMergeWithClipMask(state: state) {
                    requirements.insert(.inheritedView)
                } else if let clipRect = state.clipRect() {
                    if !item.canMergeWithClipRect(clipRect, state: &state) {
                        requirements.insert(.inheritedView)
                    }
                }
            }
            if !requirements.contains(.inheritedView),
               state.transform != .identity,
               !item.canMergeWithTransform {
                requirements.insert(.inheritedView)
            }
            if !requirements.contains(.inheritedView),
               (state.shadow != nil || !state.filters.isEmpty),
               !item.canInheritShadowOrFilters {
                requirements.insert(.inheritedView)
            }
            if !requirements.contains(.inheritedView),
               state.properties.contains(.ignoresEvents),
               !item.canInheritIgnoresEvents {
                requirements.insert(.inheritedView)
            }
            if requirements.contains(.inheritedView) {
                state.reset()
            }
            state.transform = state.transform.translatedBy(x: item.position.x, y: item.position.y)
            state.versions.transform.combine(with: item.version)
            let value = item.value
            value.finishMerge(&requirements, item: &item, state: &state)
            return requirements
        }
        
        struct MergedViewRequirements: OptionSet {
            let rawValue: UInt8
            
            init(rawValue: UInt8) {
                self.rawValue = rawValue
            }

            // NOTE: These three flags are fully inlined and the names are inferred from the merge/update call sites.
            static let itemView = MergedViewRequirements(rawValue: 1 << 0)
            static let inheritedView = MergedViewRequirements(rawValue: 1 << 1)
            static let visibleContent = MergedViewRequirements(rawValue: 1 << 2)
        }

        fileprivate static func merge(
            _ content: DisplayList.Content,
            from item: DisplayList.Item,
            into state: inout State,
            requirements: inout MergedViewRequirements
        ) {
            requirements.insert(.itemView)
            state.versions.properties.combine(with: item.version)
            switch content.value {
            case let .backdrop(effect):
                appendInheritedFilters(effect.filters, version: item.version, into: &state)
            case let .chameleonColor(_, filters):
                appendInheritedFilters(filters, version: item.version, into: &state)
            case .view, .platformView, .platformLayer:
                requirements.insert(.inheritedView)
            default:
                break
            }
        }

        fileprivate static func merge(
            _ effect: DisplayList.Effect,
            list: DisplayList,
            item: inout DisplayList.Item,
            into state: inout State,
            requirements: inout MergedViewRequirements
        ) {
            switch effect {
            case .identity, .geometryGroup, .archive, .animation, .contentTransition,
                    .accessibility, .interpolatorRoot, .interpolatorLayer, .interpolatorAnimation:
                requirements.insert(.visibleContent)
            case .compositingGroup:
                state.compositingGroup = true
                state.versions.properties.combine(with: item.version)
                requirements.formUnion([.inheritedView, .visibleContent])
            case let .backdropGroup(enabled):
                if enabled {
                    state.backdropGroupID &+= 1
                }
                state.versions.properties.combine(with: item.version)
                requirements.insert(.visibleContent)
            case let .properties(properties):
                state.properties.formUnion(properties)
                state.versions.properties.combine(with: item.version)
                requirements.insert(.visibleContent)
            case .platformGroup, .view, .platform:
                requirements.formUnion([.inheritedView, .visibleContent])
            case let .opacity(opacity):
                state.opacity *= opacity
                state.versions.opacity.combine(with: item.version)
                requirements.insert(.visibleContent)
            case let .blendMode(blend):
                state.blend = blend
                state.versions.blend.combine(with: item.version)
                requirements.insert(.visibleContent)
            case let .clip(path, style, _):
                state.addClip(path, style: style)
                state.versions.clips.combine(with: item.version)
                requirements.insert(.visibleContent)
            case .mask:
                requirements.formUnion([.inheritedView, .visibleContent])
            case let .transform(transform):
                merge(transform, item: item, into: &state, requirements: &requirements)
            case let .filter(filter):
                merge(filter, list: list, item: &item, into: &state, requirements: &requirements)
            case let .state(hash):
                state.stateHashes.append(hash)
                requirements.formUnion([.inheritedView, .visibleContent])
            }
        }

        private static func merge(
            _ transform: DisplayList.Transform,
            item: DisplayList.Item,
            into state: inout State,
            requirements: inout MergedViewRequirements
        ) {
            switch transform {
            case let .affine(transform):
                state.adjust(for: transform)
                state.transform = transform.concatenating(state.transform)
                state.versions.transform.combine(with: item.version)
                requirements.insert(.visibleContent)
            case let .projection(transform) where transform.isAffine:
                let affine = CGAffineTransform(transform)
                state.adjust(for: affine)
                state.transform = affine.concatenating(state.transform)
                state.versions.transform.combine(with: item.version)
                requirements.insert(.visibleContent)
            default:
                requirements.formUnion([.inheritedView, .visibleContent])
            }
        }

        private static func merge(
            _ filter: GraphicsFilter,
            list: DisplayList,
            item: inout DisplayList.Item,
            into state: inout State,
            requirements: inout MergedViewRequirements
        ) {
            if state.rewriteVibrantColorMatrix,
               case let .colorMatrix(matrix, false) = filter {
                item.rewriteVibrancyFilterAsBackdrop(matrix: matrix, list: list)
                requirements.formUnion([.itemView, .visibleContent])
                return
            }
            switch filter {
            case let .shadow(shadow):
                state.shadow = Indirect(shadow)
                state.versions.shadow.combine(with: item.version)
            case let .vibrantColorMatrix(matrix):
                state.rewriteVibrantColorMatrix = true
                state.filters.append(.colorMatrix(matrix, premultiplied: false))
                state.versions.filters.combine(with: item.version)
            default:
                state.filters.append(filter)
                state.versions.filters.combine(with: item.version)
            }
            requirements.insert(.visibleContent)
        }

        @inline(__always)
        private static func appendInheritedFilters(
            _ filters: [GraphicsFilter],
            version: DisplayList.Version,
            into state: inout State
        ) {
            guard !filters.isEmpty else {
                return
            }
            state.filters.append(contentsOf: filters.reversed())
            state.versions.filters.combine(with: version)
        }
        
        // MARK: - DisplayList.ViewUpdater.Clip
        
        struct Clip: Equatable {
            var path: Path
            var transform: CGAffineTransform?
            var style: FillStyle

            var isEmpty: Bool {
                path.isEmpty
            }
            
            func clipRect() -> FixedRoundedRect? {
                guard transform == nil else {
                    return nil
                }
                switch path.storage {
                case let .rect(rect):
                    return FixedRoundedRect(rect, cornerSize: .zero, style: .circular)
                case let .ellipse(rect):
                    // OpenSwiftUI Addition:
                    // SwiftUI 6.5.4 Buggy implementation: guard rect.width == rect.height
                    // SwiftUI 7.2.5 Fixed: guard abs(rect.width - rect.height) < 0.001
                    guard rect.width.approximates(rect.height, epsilon: 0.001) else {
                        return nil
                    }
                    let radius = rect.width * 0.5
                    return FixedRoundedRect(rect, cornerRadius: radius, style: .circular)
                case let .roundedRect(roundedRect):
                    return roundedRect
                default:
                    return nil
                }
            }
        }
        
        // MARK: - DisplayList.ViewUpdater.State

        struct State {
            struct Globals {
                var updater: DisplayList.ViewUpdater
                var time: Time
                var maxVersion: DisplayList.Version
                var environment: DisplayList.ViewRenderer.Environment
            }
            var globals: UnsafePointer<Globals>
            var opacity: Float = 1.0
            var blend: GraphicsBlendMode = .normal
            var transform: CGAffineTransform = .identity
            var clips: [Clip] = []
            var filters: [GraphicsFilter] = []
            var shadow: Indirect<ResolvedShadowStyle>?
            var properties: DisplayList.Properties = []
            var rewriteVibrantColorMatrix: Bool = false
            var compositingGroup: Bool = false
            var backdropGroupID: UInt32 = .zero
            var stateHashes: [StrongHash] = []
            var platformState: PlatformState = .init()
            struct Versions {
                var opacity: DisplayList.Version = .init()
                var blend: DisplayList.Version = .init()
                var transform: DisplayList.Version = .init()
                var clips: DisplayList.Version = .init()
                var filters: DisplayList.Version = .init()
                var shadow: DisplayList.Version = .init()
                var properties: DisplayList.Version = .init()
            }
            var versions: Versions = .init()

            var hasDODEffects: Bool {
                guard shadow == nil else {
                    return true
                }
                return filters.contains { filter in
                    switch filter {
                    case let .blur(blurStyle):
                        !blurStyle.isOpaque
                    case let .variableBlur(variableBlurStyle):
                        !variableBlurStyle.isOpaque
                    case .shadow:
                        true
                    default:
                        false
                    }
                }
            }

            mutating func reset() {
                opacity = 1.0
                blend = .normal
                transform = .identity
                clips = []
                filters = []
                shadow = nil
                properties = []
                stateHashes = []
                versions = .init()
            }

            func clipRect() -> FixedRoundedRect? {
                guard clips.count == 1,
                      let rect = clips[0].clipRect(),
                      transform.isRectilinear
                else {
                    return nil
                }
                return rect.applying(transform.inverted())
            }

            fileprivate mutating func adjust(for transform: CGAffineTransform) {
                guard shadow != nil || !filters.isEmpty else {
                    return
                }
                let transformedWidth = CGSize(width: 1.0, height: 1.0).applying(transform).width
                guard abs(transformedWidth - 1.0) > 0.001 else {
                    return
                }
                let scale = 1.0 / transformedWidth
                if let shadow {
                    var value = shadow.value
                    value.radius *= scale
                    value.offset *= scale
                    self.shadow = Indirect(value)
                }
                for (index, filter) in filters.enumerated() {
                    guard case var .blur(blurStyle) = filter else {
                        continue
                    }
                    blurStyle.radius *= scale
                    filters[index] = .blur(blurStyle)
                }
            }

            fileprivate mutating func addClip(_ path: Path, style: FillStyle) {
                guard transform.isRectilinear else {
                    appendClip(path, transform: transform, style: style)
                    return
                }
                switch path.storage {
                case .empty:
                    clips = [Clip(path: path, transform: nil, style: style)]
                case let .rect(rect):
                    appendClip(
                        Path(rect.applying(transform)),
                        transform: nil,
                        style: style
                    )
                case let .ellipse(rect):
                    appendClip(
                        Path(ellipseIn: rect.applying(transform)),
                        transform: nil,
                        style: style
                    )
                case let .roundedRect(roundedRect):
                    appendClip(
                        Path(storage: .roundedRect(roundedRect.applying(transform))),
                        transform: nil,
                        style: style
                    )
                default:
                    appendClip(
                        path,
                        transform: transform,
                        style: style
                    )
                }
            }

            @inline(__always)
            private mutating func appendClip(_ path: Path, transform: CGAffineTransform?, style: FillStyle) {
                if transform == nil {
                    for (index, clip) in clips.enumerated() where clip.transform == nil {
                        var existingPath = clip.path
                        if existingPath.intersectRoundedRects(path) {
                            clips[index].path = existingPath
                            return
                        }
                    }
                }
                clips.append(Clip(path: path, transform: transform, style: style))
            }
        }
    }
}

// MARK: - DisplayList.Item.Value helper

extension DisplayList.Item.Value {
    @inline(__always)
    internal func finishMerge(
        _ requirements: inout DisplayList.ViewUpdater.Model.MergedViewRequirements,
        item: inout DisplayList.Item,
        state: inout DisplayList.ViewUpdater.Model.State
    ) {
        switch self {
        case .empty:
            requirements.remove(.inheritedView)
        case let .content(content):
            DisplayList.ViewUpdater.Model.merge(content, from: item, into: &state, requirements: &requirements)
        case let .effect(effect, list):
            DisplayList.ViewUpdater.Model.merge(effect, list: list, item: &item, into: &state, requirements: &requirements)
        case .states:
            _openSwiftUIUnreachableCode()
        }
    }
}

// MARK: - Path + intersectRoundedRects

@available(OpenSwiftUI_v1_0, *)
extension Path {
    fileprivate mutating func intersectRoundedRects(_ other: Path) -> Bool {
        guard let lhs = roundedRect(), let rhs = other.roundedRect() else {
            return false
        }
        guard lhs.cornerSize != .zero || rhs.cornerSize != .zero else {
            self = Path(lhs.rect.intersection(rhs.rect))
            return true
        }
        if lhs.cornerSize == rhs.cornerSize && lhs.style == rhs.style {
            if lhs.rect.x.approximates(rhs.rect.x, epsilon: 0.001),
               lhs.rect.width.approximates(rhs.rect.width, epsilon: 0.001) {
                let y = max(lhs.rect.y, rhs.rect.y)
                let height = min(lhs.rect.y + lhs.rect.height, rhs.rect.y + rhs.rect.height) - y
                let storage: Path.Storage = height > 0 ? .roundedRect(FixedRoundedRect(
                    CGRect(x: lhs.rect.x, y: y, width: lhs.rect.width, height: height),
                    cornerSize: lhs.cornerSize,
                    style: lhs.style
                )) : .empty
                self = Path(storage: storage)
                return true
            }
            if lhs.rect.y.approximates(rhs.rect.y, epsilon: 0.001),
               lhs.rect.height.approximates(rhs.rect.height, epsilon: 0.001) {
                let x = max(lhs.rect.x, rhs.rect.x)
                let width = min(lhs.rect.x + lhs.rect.width, rhs.rect.x + rhs.rect.width) - x
                let storage: Path.Storage = width > 0 ? .roundedRect(FixedRoundedRect(
                    CGRect(x: x, y: lhs.rect.y, width: width, height: lhs.rect.height),
                    cornerSize: lhs.cornerSize,
                    style: lhs.style
                )) : .empty
                self = Path(storage: storage)
                return true
            }
        }
        if lhs.contains(rhs) {
            self = Path(storage: .roundedRect(rhs))
            return true
        } else if rhs.contains(lhs) {
            self = Path(storage: .roundedRect(lhs))
            return true
        } else {
            return false
        }
    }
}

// MARK: - DisplayList.Item helper

extension DisplayList.Item {
    func canMergeWithClipMask(state: DisplayList.ViewUpdater.Model.State) -> Bool {
        switch value {
        case .empty:
            return true
        case let .content(content):
            switch content.value {
            case .platformView, .platformLayer, .text:
                return false
            case let .flattened(_, _, options), let .drawing(_, _, options):
                return options.isAccelerated
            default:
                return true
            }
        case let .effect(effect, _):
            switch effect {
            case .platformGroup, .mask:
                return false
            case let .transform(transform):
                switch transform {
                case let .affine(transform):
                    return transform == .identity
                case .projection:
                    return false
                case let .rotation(data):
                    return data.transform == .identity
                case .rotation3D:
                    return false
                }
            case .animation, .view:
                _openSwiftUIUnreachableCode()
            default:
                return true
            }
        case .states:
            _openSwiftUIUnreachableCode()
        }
    }

    func canMergeWithClipRect(
        _ clipRect: FixedRoundedRect,
        state: inout DisplayList.ViewUpdater.Model.State
    ) -> Bool {
        switch value {
        case .empty:
            return true
        case let .content(content):
            switch content.value {
            case .backdrop, .color, .chameleonColor, .shadow, .text, .flattened, .drawing:
                return frame.insetBy(dx: -0.001, dy: -0.001).contains(clipRect.rect)
            case .image:
                return frame.approximates(clipRect.rect, epsilon: 0.001)
            case let .shape(path, _, _):
                guard case let .rect(rect) = path.storage else {
                    return false
                }
                return rect.contains(clipRect.rect)
            case .platformView, .platformLayer:
                return false
            case .view, .placeholder:
                _openSwiftUIUnreachableCode()
            }
        case let .effect(effect, _):
            switch effect {
            case .filter(let filter):
                guard case .shadow = filter else {
                    return true
                }
                return false
            case .animation:
                _openSwiftUIUnreachableCode()
            default:
                return true
            }
        case .states:
            _openSwiftUIUnreachableCode()
        }
    }

    var canMergeWithTransform: Bool {
        guard case let .effect(effect, _) = value else {
            return true
        }
        switch effect {
        case let .clip(path, _, _):
            switch path.storage {
            case .rect, .roundedRect:
                return false
            case let .ellipse(rect):
                // SwiftUI 6.5.4 Buggy implementation: rect.width == rect.height
                // SwiftUI 7.2.5 Fixed: !rect.width.approximates(rect.height, epsilon: 0.001)
                return !rect.width.approximates(rect.height, epsilon: 0.001)
            default:
                return true
            }
        default:
            return true
        }
    }

    var canInheritShadowOrFilters: Bool {
        switch value {
        case .empty:
            return true
        case let .content(content):
            switch content.value {
            case .shadow, .platformView, .platformLayer:
                return false
            default:
                return true
            }
        case let .effect(effect, _):
            switch effect {
            case let .blendMode(blend):
                return blend == .normal
            case .clip, .platformGroup, .mask:
                return false
            case let .transform(transform):
                let affineTransform: CGAffineTransform
                switch transform {
                case let .affine(transform):
                    affineTransform = transform
                case .projection:
                    return false
                case let .rotation(data):
                    affineTransform = data.transform
                case .rotation3D:
                    return false
                }
                return affineTransform.isUniform
            case let .filter(filter):
                if case .shadow = filter {
                    return false
                } else {
                    return true
                }
            case .animation, .view:
                _openSwiftUIUnreachableCode()
            default:
                return true
            }
        case .states:
            _openSwiftUIUnreachableCode()
        }
    }

    var canInheritIgnoresEvents: Bool {
        switch value {
        case .empty:
            return true
        case let .content(content):
            if case .platformView = content.value {
                return false
            } else {
                return true
            }
        case let .effect(effect, _):
            if case .platformGroup = effect {
                return false
            } else {
                return true
            }
        case .states:
            _openSwiftUIUnreachableCode()
        }
    }

    fileprivate mutating func rewriteVibrancyFilterAsBackdrop(
        matrix: _ColorMatrix,
        list: DisplayList
    ) {
        let backdropItem = DisplayList.Item(
            .content(
                DisplayList.Content(
                    .backdrop(BackdropEffect(color: .clear)),
                    seed: .init()
                )
            ),
            frame: CGRect(origin: .zero, size: size),
            identity: .none,
            version: version
        )
        let filterItem = DisplayList.Item(
            .effect(
                .filter(.colorMatrix(matrix, premultiplied: false)),
                DisplayList(backdropItem)
            ),
            frame: CGRect(origin: .zero, size: size),
            identity: .none,
            version: version
        )
        value = .effect(.mask(list), DisplayList(filterItem))
    }
    
    #if OPENSWIFTUI_SUPPORT_2025_API
    // 7.2.5
//    fileprivate mutating func rewriteVibrancyFilterAsBackdrop(
//        _ matrix: GraphicsFilter.VibrantColorMatrix,
//        list: DisplayList
//    ) {
//        guard matrix.options == [], matrix.maxColorComponent == .inf else {
//            return
//        }
//        let backdropItem = DisplayList.Item(
//            .content(DisplayList.Content(.backdrop(BackdropEffect(color: .clear)), seed: .init())),
//            frame: CGRect(origin: .zero, size: size),
//            identity: .none,
//            version: version
//        )
//        let filterItem = DisplayList.Item(
//            .effect(
//                .filter(.colorMatrix(matrix, premultiplied: false)),
//                DisplayList(backdropItem)
//            ),
//            frame: CGRect(origin: .zero, size: size),
//            identity: .none,
//            version: version
//        )
//        value = .effect(.mask(list), DisplayList(filterItem))
//    }
    #endif
    
    fileprivate func discardContainingClips(
        state: inout DisplayList.ViewUpdater.Model.State
    ) -> Bool {
        guard !state.clips.isEmpty else {
            return true
        }
        guard !state.clips[0].isEmpty else {
            return false
        }
        guard case let .content(content) = value,
              state.transform.isRectilinear else {
            return true
        }
        let inverseTransform = state.transform.inverted()
        var effectOutset: CGFloat?
        var index = 0
        while index < state.clips.endIndex {
            guard let clipRect = state.clips[index].clipRect() else {
                index &+= 1
                continue
            }
            var localClipRect = clipRect.applying(inverseTransform)
            let sectionRect: CGRect
            switch content.value {
            case .backdrop, .color, .chameleonColor, .image, .text, .flattened, .drawing:
                sectionRect = frame
            case let .shape(path, _, _):
                sectionRect = path.boundingRect.offsetBy(dx: frame.origin.x, dy: frame.origin.y)
            case .shadow, .platformView, .platformLayer, .view, .placeholder:
                return true
            }
            guard localClipRect.hasIntersection(sectionRect) else {
                return false
            }
            let resolvedEffectOutset = effectOutset ?? state.clipDiscardEffectOutset
            effectOutset = resolvedEffectOutset
            if resolvedEffectOutset != 0 {
                guard let insetClipRect = localClipRect.insetBy(dx: resolvedEffectOutset, dy: resolvedEffectOutset) else {
                    index &+= 1
                    continue
                }
                localClipRect = insetClipRect
            }
            guard localClipRect.contains(rect: sectionRect) else {
                index &+= 1
                continue
            }
            state.clips.remove(at: index)
        }
        return true
    }
}

// MARK: - DisplayList.ViewUpdater.Model.State helper

extension DisplayList.ViewUpdater.Model.State {
    @inline(__always)
    fileprivate var clipDiscardEffectOutset: CGFloat {
        var outset: CGFloat = 0
        if let shadow {
            outset += shadow.value.clipDiscardOutset
        }
        for filter in filters {
            switch filter {
            case let .blur(blurStyle):
                if !blurStyle.isOpaque {
                    outset += blurStyle.radius * 2.8
                }
            default:
                break
            }
        }
        return outset
    }
}

// MARK: - ResolvedShadowStyle helper

extension ResolvedShadowStyle {
    @inline(__always)
    fileprivate var clipDiscardOutset: CGFloat {
        radius * 2.8 + max(abs(offset.width), abs(offset.height))
    }
}
