//
//  ViewListOutputs.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

internal import OpenGraphShims

/// Output values from `View._makeViewList()`.
public struct _ViewListOutputs {
    var views: Views
    var nextImplicitID: Int
    var staticCount: Int?
    
    enum Views {
        case staticList(_ViewList_Elements)
        case dynamicList(Attribute<ViewList>, ListModifier?)
    }
    
    class ListModifier {
        init() {}
        
        func apply(to: inout ViewList)  {
            // TODO
        }
    }
}

// TODO
protocol ViewList {
}
