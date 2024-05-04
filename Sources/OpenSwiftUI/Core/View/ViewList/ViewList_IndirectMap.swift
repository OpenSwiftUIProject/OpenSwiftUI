//
//  ViewList_IndirectMap.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: 70E71091E926A1B09B75AAEB38F5AA3F

internal import OpenGraphShims

final class _ViewList_IndirectMap {
    let subgraph: OGSubgraph
    #if canImport(Darwin)
    private var map: [OGAttribute: OGAttribute]
    #endif
    
    init(subgraph: OGSubgraph) {
        self.subgraph = subgraph
        #if canImport(Darwin)
        self.map = [:]
        #endif
    }
}
