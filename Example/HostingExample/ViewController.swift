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
        let vc = UIHostingController(rootView: ContentView())
        pushViewController(vc, animated: false)
    }
}

struct ContentView: View {
    var body: some View {
        AnyView(EmptyView())
    }
}
