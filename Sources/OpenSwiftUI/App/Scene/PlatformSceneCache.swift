//
//  PlatformSceneCache.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import OpenSwiftUICore

// MARK: - PlatformSceneCache

final class PlatformSceneCache {
    static let shared = PlatformSceneCache()

    struct Info {
        var scenes: [HashableWeakBox<PlatformViewController>: ScenePhase]
    }

    var infoMap: [SceneID: Info] = [:]

    private init() {
        _openSwiftUIEmptyStub()
    }

    func addHost(_ host: PlatformViewController, id: SceneID) {
        let box = HashableWeakBox(host)
        guard infoMap[id]?.scenes[box] == nil else { return }
        if var info = infoMap[id] {
            info.scenes[box] = .active
            infoMap[id] = info
        } else {
            infoMap[id] = Info(scenes: [box: .active])
        }
    }

    func removeHost(_ host: PlatformViewController, id: SceneID) {
        guard var info = infoMap[id] else { return }
        let box = HashableWeakBox(host)
        info.scenes[box] = nil
        if info.scenes.isEmpty {
            infoMap[id] = nil
        } else {
            infoMap[id] = info
        }
    }

    func setPhase(_ phase: ScenePhase, id: SceneID, host: PlatformViewController) {
        guard var info = infoMap[id] else { return }
        let box = HashableWeakBox(host)
        info.scenes[box] = phase
        infoMap[id] = info
        guard let appGraph = AppGraph.shared else { return }
        Update.ensure { [self] in
            let items = appGraph.rootSceneList?.items ?? []
            let phases: [ScenePhase] = items.compactMap { item -> ScenePhase? in
                guard let scenes = infoMap[item.id]?.scenes else {
                    return nil
                }
                if isLinkedOnOrAfter(.v6) {
                    return scenes.values.max() ?? .background
                } else {
                    return scenes.values.min() ?? .background
                }
            }
            let finalPhase: ScenePhase
            if phases.isEmpty {
                finalPhase = .background
            } else if isLinkedOnOrAfter(.v6) {
                finalPhase = phases.max() ?? .background
            } else {
                finalPhase = phases.min() ?? .background
            }
            let changed = appGraph.$rootScenePhase.setValue(finalPhase)
            if changed {
                appGraph.graphDidChange()
            }
        }
    }
}
