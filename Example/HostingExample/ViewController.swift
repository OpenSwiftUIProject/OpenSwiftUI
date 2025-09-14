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
    }

    @objc
    private func pushHostingVC() {
        guard let navigationController else { return }
        let hostingVC = UIHostingController(rootView: ContentView())
        navigationController.pushViewController(hostingVC, animated: true)
    }
}
#elseif os(macOS)
class ViewController: NSViewController {
    override func loadView() {
        view = NSHostingView(rootView: ContentView())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.frame = .init(x: 0, y: 0, width: 500, height: 300)
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}
#endif

struct ContentView: View {
    var body: some View {
        TimelineView(.animation) { context in
            Color(platformColor: Bool.random() ? .red : .blue)
        }
    }
}
