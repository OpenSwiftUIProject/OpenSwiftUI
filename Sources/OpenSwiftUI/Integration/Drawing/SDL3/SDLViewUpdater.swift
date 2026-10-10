//
//  SDLViewUpdater.swift
//  OpenSwiftUI

#if OPENSWIFTUI_SDL3
import Foundation
import OpenCoreGraphicsShims
import OpenSwiftUICore
import SwiftSDL3

final class SDLViewUpdater {
    let context: OpaquePointer
    private var warned = Set<String>()
    private var displayScale: CGFloat = 1

    convenience init(window: OpaquePointer) {
        guard let context = SDL_CreateRenderer(window, nil) else {
            fatalError("SDL_CreateRenderer: \(String(cString: SDL_GetError()))")
        }
        self.init(context: context)
    }

    init(context: OpaquePointer) {
        self.context = context
        SDL_SetRenderDrawBlendMode(context, SDL_BLENDMODE_BLEND)
        print("OpenSwiftUI UI framework: SDL3; renderer: \(String(cString: SDL_GetRendererName(context)))")
    }

    func destroy() { SDL_DestroyRenderer(context) }

    func render(_ list: DisplayList, scale: CGFloat) {
        precondition(SDL_IsMainThread(), "SDL3 presentation must run on its video initialization thread")
        SDL_SetRenderScale(context, Float(scale), Float(scale))
        displayScale = scale
        SDL_SetRenderDrawColor(context, 255, 255, 255, 255)
        SDL_RenderClear(context)
        draw(list, transform: .identity, opacity: 1)
        #if DEBUG
        if let path = ProcessInfo.processInfo.environment["OPENSWIFTUI_SDL_CAPTURE_PATH"],
           let surface = SDL_RenderReadPixels(context, nil) {
            defer { SDL_DestroySurface(surface) }
            if !SDL_SaveBMP(surface, path) {
                unsupported("frame capture: \(String(cString: SDL_GetError()))")
            }
        }
        #endif
        if !SDL_RenderPresent(context) {
            unsupported("presentation: \(String(cString: SDL_GetError()))")
        }
    }

    private func draw(_ list: DisplayList, transform: CGAffineTransform, opacity: Float) {
        for item in list.items {
            switch item.value {
            case let .content(content):
                switch content.value {
                case let .color(color):
                    fill(item.frame, color: color, transform: transform, opacity: opacity)
                case let .text(view, size):
                    drawText(view, size: size, origin: item.frame.origin, transform: transform, opacity: opacity)
                case let .flattened(nested, offset, _):
                    let local = CGAffineTransform(translationX: item.frame.minX + offset.x, y: item.frame.minY + offset.y)
                    draw(nested, transform: local.concatenating(transform), opacity: opacity)
                default:
                    unsupported("content (paths, images and drawing are not implemented yet)")
                }
            case let .effect(effect, nested):
                let local = CGAffineTransform(translationX: item.position.x, y: item.position.y)
                let nestedTransform = local.concatenating(transform)
                switch effect {
                case let .opacity(alpha):
                    draw(nested, transform: nestedTransform, opacity: opacity * alpha)
                case let .transform(.affine(affine)):
                    draw(nested, transform: affine.concatenating(nestedTransform), opacity: opacity)
                case .identity, .geometryGroup:
                    draw(nested, transform: nestedTransform, opacity: opacity)
                default:
                    unsupported("effect")
                }
            case .states:
                unsupported("state interpolation")
            case .empty: break
            }
        }
    }

    private func fill(_ frame: CGRect, color: Color.Resolved, transform: CGAffineTransform, opacity: Float) {
        let tint = SDL_FColor(r: color.red, g: color.green, b: color.blue, a: color.opacity * opacity)
        let corners = [
            CGPoint(x: frame.minX, y: frame.minY), CGPoint(x: frame.maxX, y: frame.minY),
            CGPoint(x: frame.maxX, y: frame.maxY), CGPoint(x: frame.minX, y: frame.maxY),
        ]
        let vertices = corners.map { point -> SDL_Vertex in
            let point = point.applying(transform)
            return SDL_Vertex(position: SDL_FPoint(x: Float(point.x), y: Float(point.y)), color: tint, tex_coord: SDL_FPoint())
        }
        let indices: [Int32] = [0, 1, 2, 0, 2, 3]
        if !SDL_RenderGeometry(context, nil, vertices, 4, indices, 6) {
            unsupported("SDL_RenderGeometry: \(String(cString: SDL_GetError()))")
        }
    }

    private func drawText(_ view: StyledTextContentView, size: CGSize, origin: CGPoint,
                          transform: CGAffineTransform, opacity: Float) {
        let transformScale = max(hypot(transform.a, transform.b), hypot(transform.c, transform.d))
        guard let text = view.text as? BackendResolvedStyledText,
              let raster = text.layout.rasterize(in: size, scale: displayScale * transformScale),
              let texture = SDL_CreateTexture(context, SDL_PIXELFORMAT_RGBA32, SDL_TEXTUREACCESS_STATIC,
                                              Int32(raster.width), Int32(raster.height)) else { return }
        defer { SDL_DestroyTexture(texture) }
        let uploaded = raster.pixels.withUnsafeBytes {
            SDL_UpdateTexture(texture, nil, $0.baseAddress, Int32(raster.width * 4))
        }
        guard uploaded else {
            unsupported("text texture upload: \(String(cString: SDL_GetError()))")
            return
        }
        guard SDL_SetTextureBlendMode(texture, SDL_BLENDMODE_BLEND_PREMULTIPLIED) else {
            unsupported("premultiplied text blending: \(String(cString: SDL_GetError()))")
            return
        }
        let frame = raster.bounds.offsetBy(dx: origin.x, dy: origin.y)
        let corners = [CGPoint(x: frame.minX, y: frame.minY), CGPoint(x: frame.maxX, y: frame.minY),
                       CGPoint(x: frame.maxX, y: frame.maxY), CGPoint(x: frame.minX, y: frame.maxY)]
        let uv = [SDL_FPoint(x: 0, y: 0), SDL_FPoint(x: 1, y: 0), SDL_FPoint(x: 1, y: 1), SDL_FPoint(x: 0, y: 1)]
        let tint = SDL_FColor(r: opacity, g: opacity, b: opacity, a: opacity)
        let vertices = zip(corners, uv).map { point, uv in
            let point = point.applying(transform)
            return SDL_Vertex(position: SDL_FPoint(x: Float(point.x), y: Float(point.y)), color: tint, tex_coord: uv)
        }
        let indices: [Int32] = [0, 1, 2, 0, 2, 3]
        if !SDL_RenderGeometry(context, texture, vertices, 4, indices, 6) {
            unsupported("text geometry: \(String(cString: SDL_GetError()))")
        }
    }

    private func unsupported(_ description: String) {
        if warned.insert(description).inserted {
            FileHandle.standardError.write(Data("OpenSwiftUI SDL3: unsupported \(description)\n".utf8))
        }
    }
}
#endif
