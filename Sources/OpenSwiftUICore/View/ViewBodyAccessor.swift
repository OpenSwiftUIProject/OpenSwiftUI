//
//  ViewBodyAccessor.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

struct ViewBodyAccessor<Container: View>: BodyAccessor {
    typealias Body = Container.Body
    
    func updateBody(of container: Container, changed: Bool) {
        guard changed else {
            return
        }
        setBody {
            container.body
        }
    }
}
