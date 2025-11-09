//
//  AnimationDebugController.swift
//  OpenSwiftUIUITests

import Foundation
import UIKit
import OpenSwiftUI_SPI

struct AnimationTestModel: Hashable {
    var intervals: [Double]

    init(intervals: [Double]) {
        self.intervals = intervals
    }

    init(times: [Double]) {
        intervals = zip(times.dropFirst(), times).map { $0 - $1 }
    }

    init(duration: Double, count: Int) {
        intervals = Array(repeating: duration / Double(count), count: count)
    }

    var duration: Double {
        intervals.reduce(0, +)
    }
}

protocol AnimationTestView: View {
    static var model: AnimationTestModel { get }
}

final class AnimationDebugController<V>: PlatformHostingController<V> where V: View {
    init(_ view: V) {
        super.init(rootView: view)
    }

    @MainActor
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var host: _UIHostingView<V> {
        view as! _UIHostingView<V>
    }

    func advance(interval: Double) {
        host._renderForTest(interval: interval)
    }

    func advanceAsync(interval: Double) -> Bool {
        host._renderAsyncForTest(interval: interval)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Self.hookLayoutSubviews(type(of: host))
        Self.hookDisplayLinkTimer()
    }

    var disableLayoutSubview = false

    static func hookLayoutSubviews(_ cls: AnyClass?) {
        let originalSelector = #selector(PlatformView.layoutSubviews)
        let swizzledSelector = #selector(PlatformView.swizzled_layoutSubviews)

        guard let targetClass = cls,
              let originalMethod = class_getInstanceMethod(targetClass, originalSelector),
              let swizzledMethod = class_getInstanceMethod(targetClass, swizzledSelector)
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }

    static func hookDisplayLinkTimer() {
        #if OPENSWIFTUI
        let cls: AnyClass? = NSClassFromString("OpenSwiftUI.DisplayLink")
        #else
        let cls: AnyClass? = NSClassFromString("SwiftUI.DisplayLink")
        #endif
        let sel = NSSelectorFromString("displayLinkTimer:")
        guard let targetClass = cls,
              let originalMethod = class_getInstanceMethod(targetClass, sel),
                let swizzledMethod = class_getInstanceMethod(self, #selector(swizzled_displayLinkTimerWithLink(_:)))
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }

    @objc
    func swizzled_displayLinkTimerWithLink(_ sender: CADisplayLink) {
        sender.isPaused = true
    }
}

// Avoid generic parameter casting
private protocol AnimationDebuggableController: PlatformViewController {
    var disableLayoutSubview: Bool { get set }
}

extension AnimationDebugController: AnimationDebuggableController {}

extension PlatformView {
    @objc func swizzled_layoutSubviews() {
        guard let vc = _viewControllerForAncestor as? AnimationDebuggableController else {
            swizzled_layoutSubviews()
            return
        }
        guard !vc.disableLayoutSubview else {
            return
        }
        swizzled_layoutSubviews()
        vc.disableLayoutSubview = true
    }
}
