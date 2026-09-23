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
                case let .flattened(nested, offset, _):
                    let local = CGAffineTransform(translationX: item.frame.minX + offset.x, y: item.frame.minY + offset.y)
                    draw(nested, transform: local.concatenating(transform), opacity: opacity)
                default:
                    unsupported("content (text, paths, images and drawing are not implemented yet)")
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

    private func unsupported(_ description: String) {
        if warned.insert(description).inserted {
            FileHandle.standardError.write(Data("OpenSwiftUI SDL3: unsupported \(description)\n".utf8))
        }
    }
}
#endif
