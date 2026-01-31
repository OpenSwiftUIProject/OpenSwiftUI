//
//  SceneList.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - SceneList

struct SceneList {
    var items: [SceneList.Item]

//    func allDocumentGroups() -> [IdentifiedDocumentGroupConfiguration] {
//        preconditionFailure("TODO")
//    }

    func windowGroup(presenting: Any.Type) -> SceneList.Item? {
        preconditionFailure("TODO")
    }

    func windowGroup<A>(id: String?, presenting: A.Type) -> SceneList.Item? where A: Decodable, A: Encodable, A: Hashable {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - SceneList.Item

extension SceneList {
    struct Item: Identifiable {
        var value: SceneList.Item.Value
        var id: SceneID
        var version: DisplayList.Version
        var environment: EnvironmentValues
        var options: SceneList.Item.Options = []
        var accessibilityProperties: AccessibilityProperties?
        var activationConditions: Set<String>?
        // var resizability: WindowResizability.Role
        var defaultPosition: UnitPoint?
        var defaultSize: CGSize?
        // var restorationBehavior: SceneRestorationBehavior.Role
        // var windowManagerRole: WindowManagerRole
        #if os(iOS) || os(visionOS)
        var connectionOptionPayloadStorage: ConnectionOptionPayloadStorage = .init()
        #elseif os(macOS)
        // TODO: macOS specific properties
        #endif

        // MARK: - SceneList.Item.Summary

        struct Summary: Identifiable {
            var id: SceneID
            var kind: SceneList.Item.Kind
            var value: SceneList.Item.Value
            var isPrimaryItem: Bool
            var options: SceneList.Item.Options
        }

        // MARK: - SceneList.Item.Value

        enum Value {
            case windowGroup(WindowSceneConfiguration<WindowGroupConfigurationAttributes>)
//            case stage(WindowSceneConfiguration<StageConfigurationAttributes>)
//            case documentGroup(IdentifiedDocumentGroupConfiguration)
            case settings(AnyView)
//            case menuBarExtra(MenuBarExtraConfiguration)
//            case customScene(UISceneAdaptorConfiguration)
//            case singleWindow(SingleWindowConfiguration)
//            case documentIntroduction(DocumentIntroductionConfiguration)
//            case alertDialog(DialogConfiguration)
        }

        // MARK: - SceneList.Item.Kind

        enum Kind {
            case windowGroup
            case singleWindow
            case custom
            case documentGroup
            case documentIntroduction
            case settings
            case stage
            case carPlay
            case clarityUI
            case externalDisplay
            case alertDialog
        }

        // MARK: - SceneList.Item.Options

        struct Options: OptionSet {
            let rawValue: UInt8

            init(rawValue: UInt8) {
                self.rawValue = rawValue
            }
        }
    }
}


// MARK: - SceneList.Key

extension SceneList {
    struct Key: PreferenceKey {
        static let defaultValue: SceneList = .init(items: [])

        static func reduce(value: inout SceneList, nextValue: () -> SceneList) {
            value.items.append(contentsOf: nextValue().items)
        }
    }
}

extension PreferencesInputs {
    @inline(__always)
    var requiresSceneList: Bool {
        get { contains(SceneList.Key.self) }
        set {
            if newValue {
                add(SceneList.Key.self)
            } else {
                remove(SceneList.Key.self)
            }
        }
    }
}

extension PreferencesOutputs {
    @inline(__always)
    var sceneList: Attribute<SceneList>? {
        get { self[SceneList.Key.self] }
        set { self[SceneList.Key.self] = newValue }
    }
}
