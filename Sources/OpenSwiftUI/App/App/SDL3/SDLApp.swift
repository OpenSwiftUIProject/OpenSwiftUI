//
//  SDLApp.swift
//  OpenSwiftUI

#if OPENSWIFTUI_SDL3
import Foundation
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore
import SwiftSDL3

func runSDLApp(_ app: some App) -> Never {
    precondition(Thread.isMainThread, "SDL3 must run on the main thread")
    guard SDL_Init(SDL_INIT_VIDEO) else {
        fatalError("SDL_Init: \(String(cString: SDL_GetError()))")
    }
    let wakeEvent = SDL_RegisterEvents(1)
    var hosts: [SDLHostingView] = []
    Update.dispatchImmediately(reason: nil) {
        let graph = AppGraph(app: app)
        graph.instantiate()
        AppGraph.shared = graph
        for item in graph.rootSceneList?.items ?? [] {
            switch item.value {
            case .windowGroup:
                hosts.append(SDLHostingView(
                    rootView: item.value.view,
                    environment: item.environment,
                    wakeEvent: wakeEvent
                ))
            default:
                fatalError("SDL3 currently supports WindowGroup scenes only")
            }
        }
    }
    var running = !hosts.isEmpty
    while running {
        autoreleasepool {
            // Service Swift/Foundation work as well as SDL events. A bare SDL_WaitEvent
            // would starve the graph's RunLoop transaction observers on Linux.
            _ = RunLoop.main.run(mode: .default, before: Date(timeIntervalSinceNow: 0.001))
            RunLoop.flushObservers()
            for host in hosts { host.renderIfNeeded() }
            var event = SDL_Event()
            if SDL_WaitEventTimeout(&event, 16) {
                repeat {
                    if event.type == SDL_EVENT_QUIT.rawValue {
                        running = false
                    } else if event.type == SDL_EVENT_WINDOW_CLOSE_REQUESTED.rawValue {
                        if let index = hosts.firstIndex(where: { $0.windowID == event.window.windowID }) {
                            hosts[index].close()
                            hosts.remove(at: index)
                            running = !hosts.isEmpty
                        }
                    } else {
                        for host in hosts { host.handle(event) }
                    }
                } while SDL_PollEvent(&event)
            }
        }
    }
    for host in hosts { host.close() }
    hosts.removeAll()
    SDL_Quit()
    exit(0)
}
#endif
