//
//  WindowSceneConfiguration.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import Foundation

// MARK: - WindowSceneConfigurationAttributes

protocol WindowSceneConfigurationAttributes {
    func sceneListValue(_ configuration: WindowSceneConfiguration<Self>) -> SceneList.Item.Value
}

// MARK: - RootViewCreating

protocol RootViewCreating {
    func makeSceneRootView(_ view: AnyView) -> AnyView
}

// MARK: - WindowSceneConfiguration

struct WindowSceneConfiguration<Attributes> where Attributes: WindowSceneConfigurationAttributes {
    var attributes: Attributes
    var mainContent: AnyView
    var title: Text?
    var presentationDataType: (Any.Type)?
    var decoder: ((Data) -> AnyHashable?)?

    func sceneListValue() -> SceneList.Item.Value {
        attributes.sceneListValue(self)
    }
}
