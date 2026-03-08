//
//  ViewController.swift
//  HostingExample
//
//  Created by Kyle on 2024/3/17.
//

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

#if os(iOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

#if os(iOS) || os(visionOS)
class ViewController: UINavigationController {
    override func viewDidAppear(_ animated: Bool) {
        pushViewController(EntryViewController(), animated: false)
    }
}

final class EntryViewController: UIViewController {
    override func viewDidLoad() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Push",
            style: .plain,
            target: self,
            action: #selector(pushHostingVC)
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.pushHostingVC()
        }

        #if OPENSWIFTUI || DEBUG
        // debugUIKitUpdateCycle()
        #endif
    }

    @objc
    private func pushHostingVC() {
        guard let navigationController else { return }
        let hostingVC = UIHostingController(rootView: ContentView())
        navigationController.pushViewController(hostingVC, animated: true)
    }
}
#elseif os(macOS)
final class WindowController: NSWindowController {
    init() {
        super.init(window: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var windowNibName: NSNib.Name? { "" }

    override func loadWindow() {
        window = NSWindow(contentViewController: NSHostingController(rootView: ContentView().frame(width: 500, height: 300)))
        window?.center()
    }
}
#endif
