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
