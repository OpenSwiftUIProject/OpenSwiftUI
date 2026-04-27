//
//  DisplayListViewModel.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Blocked by MergedViewRequirements
//  ID: CA3A65C294B7CEBAC4D3EE28C528C257 (SwiftUICore)

import OpenCoreGraphicsShims

// MARK: - DisplayList.ViewUpdater.Model

extension DisplayList.ViewUpdater {
    enum Model {
        static func merge(
            item: inout DisplayList.Item,
            index: DisplayList.Index,
            into: inout Model.State
        ) -> MergedViewRequirements {
            _openSwiftUIUnimplementedFailure()
        }
        
        // FIXME
        struct MergedViewRequirements: OptionSet {
            let rawValue: UInt8
            
            init(rawValue: UInt8) {
                self.rawValue = rawValue
            }
        }
        
        // MARK: - DisplayList.ViewUpdater.Clip
        
        struct Clip {
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
                    // SwiftUI 6.5.1 Buggy implementation: guard rect.width == rect.height
                    // SwiftUI 7.2.5 Fixed: guard abs(rect.width - rect.height) < 0.001
                    guard abs(rect.width - rect.height) < 0.001 else {
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

// MARK: - Path + intersectRoundedRects [WIP]

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
            if lhs.rect.minX.approximates(rhs.rect.minX, epsilon: 0.001),
               lhs.rect.width.approximates(rhs.rect.width, epsilon: 0.001) {
                let minY = max(lhs.rect.minY, rhs.rect.minY)
                let maxY = min(lhs.rect.maxY, rhs.rect.maxY)
                guard minY < maxY else {
                    self = Path()
                    return true
                }
                self = Path(
                    roundedRect: CGRect(
                        x: lhs.rect.minX,
                        y: minY,
                        width: lhs.rect.width,
                        height: maxY - minY
                    ),
                    cornerSize: lhs.cornerSize,
                    style: lhs.style
                )
                return true
            }
            if lhs.rect.minY.approximates(rhs.rect.minY, epsilon: 0.001),
               lhs.rect.height.approximates(rhs.rect.height, epsilon: 0.001) {
                let minX = max(lhs.rect.minX, rhs.rect.minX)
                let maxX = min(lhs.rect.maxX, rhs.rect.maxX)
                guard minX < maxX else {
                    self = Path()
                    return true
                }
                self = Path(
                    roundedRect: CGRect(
                        x: minX,
                        y: lhs.rect.minY,
                        width: maxX - minX,
                        height: lhs.rect.height
                    ),
                    cornerSize: lhs.cornerSize,
                    style: lhs.style
                )
                return true
            }
        }
        if lhs.contains(rhs) {
            self = Path(storage: .roundedRect(rhs))
            return true
        }
        if rhs.contains(lhs) {
            self = Path(storage: .roundedRect(lhs))
            return true
        }
        return false
    }
}

// MARK: - DisplayList.Item helper [WIP]

extension DisplayList.Item {
    fileprivate func rewriteVibrancyFilterAsBackdrop(
        matrix: _ColorMatrix,
        list: DisplayList
    ) {
        _openSwiftUIUnimplementedWarning()
    }
    
    fileprivate func discardContainingClips(
        state: inout DisplayList.ViewUpdater.Model.State
    ) -> Bool {
        _openSwiftUIUnimplementedWarning()
        return false
    }
}
