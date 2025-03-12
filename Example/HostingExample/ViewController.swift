//
//  ViewController.swift
//  HostingExample
//
//  Created by Kyle on 2024/3/17.
//

import UIKit
#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

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

struct ContentView: View {
    var body: some View {
        AppearanceActionModifierExample()
    }
}
