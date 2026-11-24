//
//  DisplayListStaticRenderer.swift
//  OpenSwiftUICore
//
//  Status: WIP

package import Foundation
package import OpenCoreGraphicsShims

// MARK: - DisplayList + static rendering

extension DisplayList {
    package enum StaticFillShape {
        case rectangle
        case ellipse(CGRect)
        case roundedRectangle(CGRect, radius: CGFloat)
    }

    /// The small, platform-neutral command set shared by headless renderers.
    ///
    /// This intentionally models only the DisplayList subset that can be
    /// rendered without a platform graphics stack. Unsupported content is
    /// skipped until the command set grows an explicit representation for it.
    package enum StaticRenderCommand {
        case fill(
            frame: CGRect,
            transform: CGAffineTransform,
            color: Color.Resolved,
            shape: StaticFillShape = .rectangle
        )
        #if os(WASI)
        case gradient(
            frame: CGRect,
            transform: CGAffineTransform,
            gradient: WebResolvedGradient,
            shape: StaticFillShape
        )
        case pushClip(
            frame: CGRect,
            transform: CGAffineTransform,
            shape: StaticFillShape
        )
        case popClip
        case symbol(
            frame: CGRect,
            transform: CGAffineTransform,
            name: String,
            style: StaticTextStyle,
            color: Color.Resolved
        )
        #endif
        case text(
            frame: CGRect,
            transform: CGAffineTransform,
            text: String,
            style: StaticTextStyle,
            color: Color.Resolved,
            firstBaseline: CGFloat
        )
    }

    package func staticRenderCommands() -> [StaticRenderCommand] {
        var visitor = StaticRenderCommandVisitor()
        visitor.append(list: self)
        return visitor.commands
    }
}

private struct StaticRenderCommandVisitor {
    var commands: [DisplayList.StaticRenderCommand] = []

    mutating func append(
        list: DisplayList,
        transform: CGAffineTransform = .identity,
        opacity: Float = 1.0,
        stateHashes: [StrongHash] = []
    ) {
        for item in list.items {
            append(
                item: item,
                transform: transform,
                opacity: opacity,
                stateHashes: stateHashes
            )
        }
    }

    private mutating func append(
        item: DisplayList.Item,
        transform: CGAffineTransform,
        opacity: Float,
        stateHashes: [StrongHash]
    ) {
        let itemTransform = transform.translatedBy(
            x: item.frame.minX,
            y: item.frame.minY
        )
        switch item.value {
        case let .content(content):
            append(
                content: content,
                frame: CGRect(origin: .zero, size: item.frame.size),
                transform: itemTransform,
                opacity: opacity,
                stateHashes: stateHashes
            )
        case let .effect(effect, list):
            append(
                effect: effect,
                list: list,
                transform: itemTransform,
                opacity: opacity,
                stateHashes: stateHashes
            )
        case let .states(states):
            guard let activeHash = stateHashes.last,
                  let (_, list) = states.first(where: { $0.0 == activeHash })
            else { return }
            append(
                list: list,
                transform: itemTransform,
                opacity: opacity,
                stateHashes: Array(stateHashes.dropLast())
            )
        case .empty:
            break
        }
    }

    private mutating func append(
        content: DisplayList.Content,
        frame: CGRect,
        transform: CGAffineTransform,
        opacity: Float,
        stateHashes: [StrongHash]
    ) {
        switch content.value {
        case let .color(color):
            commands.append(.fill(
                frame: frame,
                transform: transform,
                color: color.multiplyingOpacity(by: opacity)
            ))
        case let .shape(path, paint, _):
            var shape = DisplayList.StaticFillShape.rectangle
            var bounds = frame
            #if os(WASI)
            var supportsGradient = false
            switch path.storage {
            case let .rect(rect):
                bounds = rect.standardized
                supportsGradient = true
            case let .ellipse(rect):
                bounds = rect.standardized
                shape = .ellipse(bounds)
                supportsGradient = true
            case let .roundedRect(roundedRect):
                if let radius = roundedRect.wasiUniformCornerRadius {
                    bounds = roundedRect.rect.standardized
                    shape = .roundedRectangle(bounds, radius: radius)
                    supportsGradient = true
                }
            default:
                break
            }
            #endif
            if let color = paint.staticResolvedColor {
                commands.append(.fill(
                    frame: bounds,
                    transform: transform,
                    color: color.multiplyingOpacity(by: opacity),
                    shape: shape
                ))
                return
            }
            #if os(WASI)
            if supportsGradient, let gradient = paint.webGradient(bounds: bounds, opacity: opacity) {
                commands.append(.gradient(frame: bounds, transform: transform, gradient: gradient, shape: shape))
            }
            #endif
        case let .flattened(list, offset, _):
            append(
                list: list,
                transform: transform.translatedBy(x: offset.x, y: offset.y),
                opacity: opacity,
                stateHashes: stateHashes
            )
        case let .text(contentView, measuredSize):
            guard let run = contentView.text.storage?.staticSingleLineRun else {
                #if DEBUG
                print("OpenSwiftUI static renderer: skipping unsupported text content")
                #endif
                return
            }
            let metrics = contentView.text.metrics(
                in: measuredSize,
                layoutMargins: nil
            )
            commands.append(.text(
                frame: frame,
                transform: transform,
                text: run.text,
                style: run.style,
                color: run.color.multiplyingOpacity(by: opacity),
                firstBaseline: metrics.firstBaseline
            ))
        #if os(WASI)
        case let .image(graphicsImage):
            if case let .systemSymbol(name, pointSize, weight) = graphicsImage.contents {
                let color = (graphicsImage.maskColor ?? .white).multiplyingOpacity(by: opacity)
                commands.append(.symbol(
                    frame: frame,
                    transform: transform,
                    name: name,
                    style: StaticTextStyle(pointSize: pointSize, weight: weight),
                    color: color
                ))
            }
        #endif
        default:
            break
        }
    }

    private mutating func append(
        effect: DisplayList.Effect,
        list: DisplayList,
        transform: CGAffineTransform,
        opacity: Float,
        stateHashes: [StrongHash]
    ) {
        switch effect {
        case let .opacity(alpha):
            append(
                list: list,
                transform: transform,
                opacity: opacity * alpha,
                stateHashes: stateHashes
            )
        case let .transform(.affine(affine)):
            append(
                list: list,
                transform: affine.concatenating(transform),
                opacity: opacity,
                stateHashes: stateHashes
            )
        case let .state(hash):
            append(
                list: list,
                transform: transform,
                opacity: opacity,
                stateHashes: stateHashes + [hash]
            )
        case .properties, .identity, .archive, .contentTransition, .accessibility:
            append(
                list: list,
                transform: transform,
                opacity: opacity,
                stateHashes: stateHashes
            )
        case .geometryGroup, .compositingGroup, .backdropGroup:
            append(
                list: list,
                transform: transform,
                opacity: opacity,
                stateHashes: stateHashes
            )
        case let .blendMode(blend) where blend == .normal:
            append(
                list: list,
                transform: transform,
                opacity: opacity,
                stateHashes: stateHashes
            )
        case let .filter(filter) where filter.isIdentity:
            append(
                list: list,
                transform: transform,
                opacity: opacity,
                stateHashes: stateHashes
            )
        #if os(WASI)
        case let .clip(path, _, _):
            let clipBounds: CGRect
            let clipShape: DisplayList.StaticFillShape
            switch path.storage {
            case .empty:
                return
            case let .rect(rect):
                clipBounds = rect.standardized
                clipShape = .rectangle
            case let .ellipse(rect):
                clipBounds = rect.standardized
                clipShape = .ellipse(clipBounds)
            case let .roundedRect(roundedRect):
                clipBounds = roundedRect.rect.standardized
                if let radius = roundedRect.wasiUniformCornerRadius {
                    clipShape = .roundedRectangle(clipBounds, radius: radius)
                } else {
                    clipShape = .rectangle
                }
            default:
                clipBounds = path.boundingRect.standardized
                clipShape = .rectangle
            }
            guard !clipBounds.isEmpty else { return }
            let startIndex = commands.count
            commands.append(.pushClip(frame: clipBounds, transform: transform, shape: clipShape))
            append(
                list: list,
                transform: transform,
                opacity: opacity,
                stateHashes: stateHashes
            )
            if commands.count == startIndex + 1 {
                commands.removeLast()
            } else {
                commands.append(.popClip)
            }
        #endif
        default:
            // Unsupported visual effects are skipped as a complete subtree so
            // this renderer never silently paints content with wrong semantics.
            break
        }
    }
}

private struct StaticColorPaintVisitor: ResolvedPaintVisitor {
    var color: Color.Resolved?

    mutating func visitPaint<P>(_ paint: P) where P: ResolvedPaint {
        color = paint as? Color.Resolved
    }
}

private extension AnyResolvedPaint {
    var staticResolvedColor: Color.Resolved? {
        var visitor = StaticColorPaintVisitor()
        visit(&visitor)
        return visitor.color
    }
}
