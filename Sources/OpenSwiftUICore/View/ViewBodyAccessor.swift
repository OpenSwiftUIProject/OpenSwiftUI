//
//  ViewBodyAccessor.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
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
