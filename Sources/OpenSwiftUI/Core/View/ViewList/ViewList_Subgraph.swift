//
//  ViewList_Subgraph.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: 70E71091E926A1B09B75AAEB38F5AA3F

internal import OpenGraphShims

class _ViewList_Subgraph {
    let subgraph: OGSubgraph
    private var refcount : UInt32
    
    init(subgraph: OGSubgraph) {
        self.subgraph = subgraph
        self.refcount = 1 // TODO
    }
    
    func invalidate() {}
}

extension _ViewList_Subgraph {
    var isValid: Bool {
        guard refcount > 0 else {
            return false
        }
        return subgraph.isValid
    }
    
    func retain() {
        refcount &+= 1
    }
    
    func release(isInserted: Bool) {
        refcount &-= 1
        guard refcount == 0 else {
            return
        }
        invalidate()
        guard subgraph.isValid else {
            return
        }
        subgraph.willInvalidate(isInserted: isInserted)
        subgraph.invalidate()
    }
}
