//
//  AppSceneDelegate.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

#if os(iOS) || os(visionOS)
import UIKit

class AppSceneDelegate: UIResponder, UIWindowSceneDelegate {
    private lazy var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var window: UIWindow?
    private var sceneItemID: SceneID?
    private var lastVersion: DisplayList.Version
//    private var sceneBridge: SceneBridge?
    private var scenePhase: ScenePhase
    private var sceneDelegateBox: AnyFallbackDelegateBox?
//    private var sceneStorageValues: SceneStorageValues?
    private var presentationDataType: Any.Type?
    private var rawPresentationDataValue: Data?
    private var presentationDataValue: AnyHashable?
    private lazy var isDocumentViewControllerRootEnabled: Bool = Semantics.DocumentViewControllerRoot.isEnabled

    override init() {
        _openSwiftUIUnimplementedFailure()
    }
}
#endif
