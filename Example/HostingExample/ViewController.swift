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

// TODO: Known issue
// 1. State toggle crash
// 2. pop - UIHostingView deinit crash / onDisappear
// 3. if else builder issue
struct ContentView: View {
    @State private var first = true
    
    var body: some View {
        if first {
            Color.red
                .onAppear {
                    print("Red appear")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        first.toggle()
                    }
                }
                .onDisappear {
                    print("Red disappear")
                }
        } else {
            Color.blue
                .onAppear {
                    print("Blue appear")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        first.toggle()
                    }
                }
                .onDisappear {
                    print("Blue disappear")
                }
        }
    }
}
