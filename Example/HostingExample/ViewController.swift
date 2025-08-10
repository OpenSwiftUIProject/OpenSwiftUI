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

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

#if os(iOS)
final class ViewController: UITableViewController {
    private enum Section {
        case animation([AnimationRow])
        case view([ViewRow])
    }

    private enum AnimationRow: CaseIterable {
        case completion
        case color
        case spring
    }

    private enum ViewRow: CaseIterable {
        case conditional
        case equatable
        case namespace
    }

    private let sections: [Section] = [
        .animation(AnimationRow.allCases),
        .view(ViewRow.allCases),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    // MARK: - UITableViewDelegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let navigationController else { return }
        let hostingVC: UIViewController
        switch sections[indexPath.section] {
        case .animation(let rows):
            switch rows[indexPath.row] {
            case .completion:
                hostingVC = UIHostingController(rootView: AnimationCompleteExample())
            case .color:
                hostingVC = UIHostingController(rootView: ColorAnimationExample())
            case .spring:
                hostingVC = UIHostingController(rootView: SpringAnimationExample())
            }
        case .view(let rows):
            switch rows[indexPath.row] {
            case .conditional:
                hostingVC = UIHostingController(rootView: ConditionalContentExample())
            case .equatable:
                hostingVC = UIHostingController(rootView: EquatableDemoView(count: 1, tag: 1))
            case .namespace:
                hostingVC = UIHostingController(rootView: NamespaceExample())
            }
        }
        hostingVC.title = titleForRow(at: indexPath)
        navigationController.pushViewController(hostingVC, animated: true)
    }

    // MARK: - UITableViewDataSource
    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sections[section] {
        case .animation: "Animation"
        case .view: "View"
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .animation(let rows): rows.count
        case .view(let rows): rows.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = titleForRow(at: indexPath)
        return cell
    }

    private func titleForRow(at indexPath: IndexPath) -> String {
        switch sections[indexPath.section] {
        case .animation(let rows):
            switch rows[indexPath.row] {
            case .color: "Color Animation"
            case .completion: "Animation Completion"
            case .spring: "Spring Animation"
            }
        case .view(let rows):
            switch rows[indexPath.row] {
            case .conditional: "Conditional Content"
            case .equatable: "Equatable Demo"
            case .namespace: "Namespace Example"
            }
        }
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
        SpringAnimationExample()
    }
}
