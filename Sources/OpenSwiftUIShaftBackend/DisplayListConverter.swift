//
//  DisplayListConverter.swift
//  OpenSwiftUIShaftBackend
//
//  Converts OpenSwiftUI DisplayList to Shaft widget tree
//

import Foundation
import OpenSwiftUICore
import Shaft
import SwiftMath

/// Converts OpenSwiftUI DisplayList structures into Shaft widgets
final class DisplayListConverter {
    private var contentsScale: Float = 1.0

    init() {}

    /// Convert a DisplayList to a Shaft widget tree
    func convertDisplayList(
        _ displayList: OpenSwiftUICore.DisplayList,
        contentsScale: CGFloat
    ) -> Widget {
        self.contentsScale = Float(contentsScale)

        // Handle empty display list
        guard !displayList.items.isEmpty else {
            return SizedBox(width: 0, height: 0)
        }

        // Convert all items
        let widgets = displayList.items.compactMap { convertItem($0) }

        // If single item, return it directly
        // if widgets.count == 1 {
        //     return widgets[0]
        // }

        // Multiple items - stack them
        return Stack { widgets }
    }

    /// Convert a single DisplayList.Item to a Shaft widget
    private func convertItem(_ item: OpenSwiftUICore.DisplayList.Item) -> Widget {
        // Each item has a frame and a value
        let frame = item.frame

        let result =
            switch item.value {
            case .empty:
                SizedBox()

            case .content(let content):
                // Actual renderable content
                convertContent(content)

            case .effect(let effect, let childList):
                // Effect applied to child display list
                // let childWidget = 
                applyEffect(effect, to: convertDisplayList(
                    childList, contentsScale: CGFloat(contentsScale)
                ))

            case .states(let states):
                // State-dependent display lists
                // For now, just render the first state if available
                if let firstState = states.first {
                    convertDisplayList(firstState.1, contentsScale: CGFloat(contentsScale))
                } else {
                    Text("states not implemented")
                }
            }

        return Positioned(
            left: Float(frame.minX), top: Float(frame.minY),
            width: Float(frame.width), height: Float(frame.height)
        ) {
            result
        }
    }

    /// Convert Content to Shaft widget
    private func convertContent(
        _ content: OpenSwiftUICore.DisplayList.Content,
    ) -> Widget {
        switch content.value {
        case .color(let resolvedColor):
            return convertColor(resolvedColor)

        case .text(let textView, let size):
            return convertText(textView, size: size)

        case .shape(let path, let paint, let fillStyle):
            return convertShape(path: path, paint: paint, fillStyle: fillStyle)

        case .image(let graphicsImage):
            return convertImage(graphicsImage)

        case .flattened(let displayList, let offset, _):
            // Nested display list
            let childWidget = convertDisplayList(displayList, contentsScale: CGFloat(contentsScale))
            if offset != .zero {
                return Positioned(
                    left: Float(offset.x),
                    top: Float(offset.y)
                ) {
                    childWidget
                }
            }
            return childWidget

        default:
            return Text("\(content.value) not implemented")
        }
    }

    /// Apply an effect to a widget
    private func applyEffect(
        _ effect: OpenSwiftUICore.DisplayList.Effect,
        to widget: Widget,
    ) -> Widget {
        switch effect {
        case .identity:
            return widget

        case .opacity(let alpha):
            // TODO: Shaft doesn't have Opacity widget - need to implement custom
            // For now, just return the widget without opacity
            return widget

        case .transform(let transform):
            return applyTransform(transform, to: widget)

        case .clip(let path, _, _):
            // TODO: Implement clipping with path
            return widget

        case .mask(let maskList, _):
            // TODO: Implement masking
            return widget

        case .geometryGroup, .compositingGroup, .backdropGroup:
            // Grouping effects - just return widget for now
            return widget

        case .properties, .blendMode, .filter:
            // Advanced effects - not supported initially
            return widget

        case .archive, .platformGroup, .animation, .contentTransition, .view, .accessibility,
            .platform, .state, .interpolatorRoot, .interpolatorLayer, .interpolatorAnimation:
            // Complex features - not supported initially
            return widget
        }
    }

    /// Apply transform to widget
    private func applyTransform(
        _ transform: OpenSwiftUICore.DisplayList.Transform,
        to widget: Widget
    ) -> Widget {
        mark("transform: \(transform)")
        switch transform {
        case .affine(let affineTransform):
            // TODO: affine transform
            return widget

        case .rotation(let data):
            return Transform(
                transform: Matrix4x4f.rotate(z: .init(radians: Float(data.angle.radians)))
            ) {
                widget
            }

        case .rotation3D, .projection:
            // TODO: Implement 3D transforms
            return widget
        }
    }

    // MARK: - Content Converters

    private func convertColor(
        _ resolvedColor: OpenSwiftUICore.Color.Resolved,
    ) -> Widget {
        // Convert from linear color (0.0-1.0) to sRGB bytes (0-255)
        let a = UInt8(resolvedColor.opacity * 255)
        let r = UInt8(resolvedColor.linearRed * 255)
        let g = UInt8(resolvedColor.linearGreen * 255)
        let b = UInt8(resolvedColor.linearBlue * 255)
        let shaftColor = Shaft.Color.argb(a, r, g, b)

        return DecoratedBox(decoration: .box(color: shaftColor))
    }

    private func convertText(
        _ textView: StyledTextContentView,
        size: CGSize,
    ) -> Widget {
        // TODO: Extract actual text content from StyledTextContentView
        // This is a complex type that needs proper parsing
        // For now, return a placeholder
        return Text("TODO: Extract text")
    }

    private func convertShape(
        path: OpenSwiftUICore.Path,
        paint: AnyResolvedPaint,
        fillStyle: FillStyle,
    ) -> Widget {
        // TODO: Convert CGPath to Shaft Path
        // TODO: Handle paint and fill styles
        return Text("TODO: Extract shape")
    }

    private func convertImage(
        _ graphicsImage: GraphicsImage,
    ) -> Widget {
        // TODO: Extract and convert image data
        return Text("TODO: Extract image")
    }
}
