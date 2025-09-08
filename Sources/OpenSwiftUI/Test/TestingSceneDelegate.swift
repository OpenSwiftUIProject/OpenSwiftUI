//
//  TestingSceneDelegate.swift
//  OpenSwiftUI
//
//  Status: Complete for iOS

#if os(iOS) || os(visionOS)
import UIKit

// MARK: - TestingSceneDelegate [6.4.41] [iOS]

class TestingSceneDelegate: DelegateBaseClass, UIWindowSceneDelegate {
    var window: UIWindow?

    var comparisonWindow: UIWindow?

    static var connectCallback: ((UIWindow, UIWindow) -> Void)?

    override init() {
        self.window = nil
        self.comparisonWindow = nil
        super.init()
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard window == nil,
              let windowScene = scene as? UIWindowScene else {
            return
        }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        let comparisonWindow = UIWindow(windowScene: windowScene)
        self.comparisonWindow = comparisonWindow
        guard let connectCallback = TestingSceneDelegate.connectCallback else {
            return
        }
        connectCallback(window, comparisonWindow)
    }
}
#endif
