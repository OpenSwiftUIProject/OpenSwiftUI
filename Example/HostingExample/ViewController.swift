//
//  ViewController.swift
//  HostingExample
//
//  Created by Kyle on 2024/3/17.
//

import UIKit
#if !OEPNSWIFTUI
import SwiftUI
#else
import OpenSwiftUI
#endif

class ViewController: UINavigationController {
    override func viewDidAppear(_ animated: Bool) {
        let vc = UIHostingController(rootView: ContentView())
        pushViewController(vc, animated: false)
    }
}

struct ContentView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        print("Update UIView")
    }
}
