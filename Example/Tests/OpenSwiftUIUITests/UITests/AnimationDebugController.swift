//
//  AnimationDebugController.swift
//  OpenSwiftUIUITests

import Foundation
#if os(macOS)
import QuartzCore
#endif
import TestingHost

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
    #if os(macOS)
    private let presentationTime = NSNumber(value: CACurrentMediaTime())
    #endif

    init(_ view: V) {
        super.init(rootView: view)
    }

    @MainActor
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var host: PlatformHostingView<V> {
        view as! PlatformHostingView<V>
    }

    func advance(interval: Double) {
        host._renderForTest(interval: interval)
    }

    func advanceAsync(interval: Double) -> Bool {
        host._renderAsyncForTest(interval: interval)
    }

    func withFixedTime<Result>(_ body: () -> Result) -> Result {
        #if os(macOS)
        // Capture can update AppKit constraints. Keep those updates from adding
        // wall-clock time to the frames advanced by _renderForTest.
        CATransaction.begin()
        CATransaction.setValue(presentationTime, forKey: "NSHostingViewPresentationTime")
        defer { CATransaction.commit() }
        #endif
        return body()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        #if os(iOS) || os(visionOS)
        AnimationDebugHooks.hookLayoutSubviews(type(of: host))
        AnimationDebugHooks.hookDisplayLinkTimer()
        #endif
    }

    #if os(iOS) || os(visionOS)
    var disableLayoutSubview = false
    #endif
}

#if os(iOS) || os(visionOS)
// Avoid generic parameter casting
private protocol AnimationDebuggableController: PlatformViewController {
    var disableLayoutSubview: Bool { get set }

    func advance(interval: Double)
}

extension AnimationDebugController: AnimationDebuggableController {}

// Generic hosting view classes share one Method, so each Method is hooked once.
// Exchanging implementations again would remove the hook.
@MainActor
private enum AnimationDebugHooks {
    private static var hookedMethods: Set<OpaquePointer> = []

    // Fix swift-snapshot-testing trigger extra layoutSubviews and advance time issue
    static func hookLayoutSubviews(_ cls: AnyClass) {
        let selector = #selector(PlatformView.layoutSubviews)
        typealias LayoutSubviews = @convention(c) (PlatformView, Selector) -> Void
        hook(cls, selector) { (original: LayoutSubviews) in
            { (view: PlatformView) in
                guard let vc = view._viewControllerForAncestor as? AnimationDebuggableController else {
                    original(view, selector)
                    return
                }
                guard !vc.disableLayoutSubview else {
                    // Fix swift-snapshot-testing set initialFrame as .zero and then trigger setProposedSize(.zero) causing DisplayList layout issue (View is placed at topLeft instead of center)
                    vc.advance(interval: .zero)
                    return
                }
                original(view, selector)
                vc.disableLayoutSubview = true
            } as @convention(block) (PlatformView) -> Void
        }
    }

    static func hookDisplayLinkTimer() {
        #if OPENSWIFTUI
        let cls: AnyClass? = NSClassFromString("OpenSwiftUI.DisplayLink")
        #else
        let cls: AnyClass? = NSClassFromString("SwiftUI.DisplayLink")
        #endif
        guard let cls else { return }
        typealias DisplayLinkTimer = @convention(c) (AnyObject, Selector, CADisplayLink) -> Void
        hook(cls, NSSelectorFromString("displayLinkTimer:")) { (_: DisplayLinkTimer) in
            { (_: AnyObject, link: CADisplayLink) in
                link.isPaused = true
            } as @convention(block) (AnyObject, CADisplayLink) -> Void
        }
    }

    private static func hook<Function>(
        _ cls: AnyClass,
        _ selector: Selector,
        _ makeBlock: (Function) -> Any
    ) {
        guard let method = class_getInstanceMethod(cls, selector),
              hookedMethods.insert(method).inserted
        else { return }
        let original = unsafeBitCast(method_getImplementation(method), to: Function.self)
        method_setImplementation(method, imp_implementationWithBlock(makeBlock(original)))
    }
}
#endif
