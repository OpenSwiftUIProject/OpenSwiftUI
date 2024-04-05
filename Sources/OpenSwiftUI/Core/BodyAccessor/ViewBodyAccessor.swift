//
//  ViewBodyAccessor.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

struct ViewBodyAccessor<Container: View>: BodyAccessor {
    typealias Body = Container.Body
    
    func updateBody(of: Container, changed: Bool) {
        guard changed else {
            return
        }
        // TODO
    }
}
