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
                // TODO
            }
        }
    }
}
