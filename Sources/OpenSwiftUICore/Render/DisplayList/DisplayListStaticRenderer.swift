//
//  DisplayListStaticRenderer.swift
//  OpenSwiftUICore
//
//  Status: WIP

package import Foundation
package import OpenCoreGraphicsShims

// MARK: - DisplayList + static rendering

extension DisplayList {
    /// The small, platform-neutral command set shared by headless renderers.
    ///
    /// This intentionally models only the DisplayList subset that can be
    /// rendered without a platform graphics stack. Unsupported content is
    /// skipped until the command set grows an explicit representation for it.
    package enum StaticRenderCommand {
        case fill(
            frame: CGRect,
            transform: CGAffineTransform,
            color: Color.Resolved
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
        case let .shape(_, paint, _):
            if let color = paint.staticResolvedColor {
                commands.append(.fill(
                    frame: frame,
                    transform: transform,
                    color: color.multiplyingOpacity(by: opacity)
                ))
            }
        case let .flattened(list, offset, _):
            append(
                list: list,
                transform: transform.translatedBy(x: offset.x, y: offset.y),
                opacity: opacity,
                stateHashes: stateHashes
            )
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
        case .identity, .archive, .contentTransition, .accessibility, .properties:
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
