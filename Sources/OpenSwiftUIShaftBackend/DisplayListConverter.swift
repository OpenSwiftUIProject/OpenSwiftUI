//
//  DisplayListConverter.swift
//  OpenSwiftUIShaftBackend
//
//  Converts OpenSwiftUI DisplayList to Shaft widget tree
//

import Foundation
import OpenSwiftUICore
import Shaft

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
        if widgets.count == 1 {
            return widgets[0]
        }
        
        // Multiple items - stack them
        return Stack { widgets }
    }
    
    /// Convert a single DisplayList.Item to a Shaft widget
    private func convertItem(_ item: OpenSwiftUICore.DisplayList.Item) -> Widget? {
        // Each item has a frame and a value
        let frame = item.frame
        
        switch item.value {
        case .empty:
            return nil
            
        case .content(let content):
            // Actual renderable content
            return convertContent(content, frame: frame)
            
        case .effect(let effect, let childList):
            // Effect applied to child display list
            let childWidget = convertDisplayList(childList, contentsScale: CGFloat(contentsScale))
            return applyEffect(effect, to: childWidget, frame: frame)
            
        case .states(let states):
            // State-dependent display lists
            // For now, just render the first state if available
            if let firstState = states.first {
                return convertDisplayList(firstState.1, contentsScale: CGFloat(contentsScale))
            }
            return nil
        }
    }
    
    /// Convert Content to Shaft widget
    private func convertContent(
        _ content: OpenSwiftUICore.DisplayList.Content,
        frame: CGRect
    ) -> Widget? {
        switch content.value {
        case .color(let resolvedColor):
            return convertColor(resolvedColor, frame: frame)
            
        case .text(let textView, let size):
            return convertText(textView, size: size, frame: frame)
            
        case .shape(let path, let paint, let fillStyle):
            return convertShape(path: path, paint: paint, fillStyle: fillStyle, frame: frame)
            
        case .image(let graphicsImage):
            return convertImage(graphicsImage, frame: frame)
            
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
            
        case .platformView, .platformLayer, .view, .drawing:
            // Platform-specific or complex cases - not supported initially
            return nil
            
        case .backdrop, .chameleonColor, .shadow, .placeholder:
            // Advanced features - not supported initially
            return nil
        }
    }
    
    /// Apply an effect to a widget
    private func applyEffect(
        _ effect: OpenSwiftUICore.DisplayList.Effect,
        to widget: Widget,
        frame: CGRect
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
        switch transform {
        case .affine(let affineTransform):
            // Extract translation for now
            let tx = Float(affineTransform.tx)
            let ty = Float(affineTransform.ty)
            if tx != 0 || ty != 0 {
                return Positioned(left: tx, top: ty) { widget }
            }
            // TODO: Handle rotation and scale
            return widget
            
        case .rotation, .rotation3D, .projection:
            // TODO: Implement 3D transforms
            return widget
        }
    }
    
    // MARK: - Content Converters
    
    private func convertColor(
        _ resolvedColor: OpenSwiftUICore.Color.Resolved,
        frame: CGRect
    ) -> Widget {
        // Convert from linear color (0.0-1.0) to sRGB bytes (0-255)
        let a = UInt8(resolvedColor.opacity * 255)
        let r = UInt8(resolvedColor.linearRed * 255)
        let g = UInt8(resolvedColor.linearGreen * 255)
        let b = UInt8(resolvedColor.linearBlue * 255)
        let shaftColor = Shaft.Color.argb(a, r, g, b)
        
        return SizedBox(
            width: Float(frame.width),
            height: Float(frame.height)
        ) {
            ColoredBox(color: shaftColor)
        }
    }
    
    private func convertText(
        _ textView: StyledTextContentView,
        size: CGSize,
        frame: CGRect
    ) -> Widget {
        // TODO: Extract actual text content from StyledTextContentView
        // This is a complex type that needs proper parsing
        // For now, return a placeholder
        return SizedBox(
            width: Float(frame.width),
            height: Float(frame.height)
        ) {
            Text("TODO: Extract text")
        }
    }
    
    private func convertShape(
        path: OpenSwiftUICore.Path,
        paint: AnyResolvedPaint,
        fillStyle: FillStyle,
        frame: CGRect
    ) -> Widget {
        // TODO: Convert CGPath to Shaft Path
        // TODO: Handle paint and fill styles
        return SizedBox(
            width: Float(frame.width),
            height: Float(frame.height)
        )
    }
    
    private func convertImage(
        _ graphicsImage: GraphicsImage,
        frame: CGRect
    ) -> Widget {
        // TODO: Extract and convert image data
        return SizedBox(
            width: Float(frame.width),
            height: Float(frame.height)
        )
    }
}
