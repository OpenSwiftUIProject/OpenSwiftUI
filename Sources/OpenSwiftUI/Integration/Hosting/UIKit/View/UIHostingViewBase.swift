//
//  UIHostingViewBase.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 529B7E967685565FD5A0228999A3F1FE (SwiftUI)

#if os(iOS)
import QuartzCore
import UIKit

import OpenGraphShims
import OpenSwiftUI_SPI
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import COpenSwiftUI

// MARK: - UIHostingViewBase [WIP]

class UIHostingViewBase {
    weak var uiView: UIView?
    weak var host: ViewRendererHost?
    weak var delegate: UIHostingViewBaseDelegate?

    struct Options: OptionSet {
        let rawValue: Int

        init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }

    let options: UIHostingViewBase.Options
    let viewGraph: ViewGraph
    let renderer: DisplayList.ViewRenderer
    let eventBindingManager: EventBindingManager
    var currentTimestamp: Time
    var propertiesNeedingUpdate: ViewRendererHostProperties
    var renderingPhase: ViewRenderingPhase
    var externalUpdateCount: Int
    var parentPhase: _GraphInputs.Phase?
    var initialInheritedEnvironment: EnvironmentValues?
    var inheritedEnvironment: EnvironmentValues?
    var environmentOverride: EnvironmentValues?
    var traitCollectionOverride: UITraitCollection?
    var displayLink: DisplayLink?
    var lastRenderTime: Time
    var nextTimerTime: Time?
    var updateTimer: Timer?
    var canAdvanceTimeAutomatically: Bool
    var pendingPreferencesUpdate: Bool
    var pendingPostDisappearPreferencesUpdate: Bool
    var allowUIKitAnimationsForNextUpdate: Bool
    var isHiddenForReuse: Bool
    var isEnteringForeground: Bool
    var isExitingForeground: Bool
    var isCapturingSnapshots: Bool
    var isRotatingWindow: Bool
    var isInSizeTransition: Bool
    private var _sceneActivationState: UIScene.ActivationState?
    var registeredForGeometryChanges: Bool
    weak var observedWindow: UIWindow?
    weak var observedScene: UIWindowScene?

    init<V>(rootViewType: V.Type, options: Options) where V: View {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - UIHostingViewBaseDelegate [WIP]

protocol UIHostingViewBaseDelegate: AnyObject {
    var shouldDisableUIKitAnimations: Bool { get }
    func sceneActivationStateDidChange()
}

// MARK: - DisplayLink

@objc
final class DisplayLink: NSObject {
    private static var asyncThread: Thread? = nil
    private static var asyncRunloop: RunLoop? = nil
    private static var asyncPending: Bool = false

    private weak var host: AnyUIHostingView? // UIHostingViewBase
    private var link: CADisplayLink?
    private var nextUpdate: Time
    private var currentUpdate: Time?
    private var interval: Double
    private var reasons: Set<UInt32>

    enum ThreadName: Hashable {
        case main
        case async
    }

    private var currentThread: ThreadName
    private var nextThread: ThreadName

    #if os(iOS)
    init(host: AnyUIHostingView, window: UIWindow) {
        _openSwiftUIUnimplementedFailure()
    }

    #elseif os(macOS)
    init(host: AnyUIHostingView, window: NSWindow) {
        _openSwiftUIUnimplementedFailure()
    }
    #endif

    func setNextUpdate(delay: Double, interval: Double, reasons: Set<UInt32>) {
        let newNextUpdate: Time
        if delay >= 0.01 {
            newNextUpdate = (currentUpdate ?? .systemUptime) + interval
        } else {
            newNextUpdate = .zero
        }

        if newNextUpdate < nextUpdate {
            nextUpdate = newNextUpdate
            link?.isPaused = false
        }
        setFrameInterval(interval, reasons: reasons)
    }

    private func setFrameInterval(_ interval: Double, reasons: Set<UInt32>) {
        if self.interval != interval {
            self.interval = interval
            link?.preferredFrameRateRange = CAFrameRateRange(interval: interval)
        }
        if self.reasons != reasons {
            self.reasons = reasons
            let count = reasons.count
            withUnsafeTuple(of: TupleType(UInt32.self), count: count) { tuple in
                let pointer = tuple.address(as: UInt32.self)
                for (index, reason) in reasons.enumerated() {
                    pointer[index] = reason
                }
                link?.setHighFrameRateReasons(pointer, count: count)
            }
        }
    }

    func invalidate() {
        Update.locked {
            if let link, link.isPaused {
                link.invalidate()
            }
            link = nil
        }
    }

    // MARK: - ObjC API

    #if canImport(ObjectiveC)
    @objc(asyncThreadWithArg:)
    #endif
    private static func asyncThread(with arg: Any?) {
        Update.lock()
        asyncRunloop = RunLoop.current
        Update.broadcast()
        while asyncPending {
            asyncPending = false
            Update.unlock()
            asyncRunloop!.schedule(
                after: RunLoop.SchedulerTimeType(Date(timeIntervalSinceNow: 1.0)),
                tolerance: RunLoop.SchedulerTimeType.Stride(0.1),
                options: nil
            ) {
                _openSwiftUIEmptyStub()
            }
            asyncRunloop!.run()
            Update.lock()
        }
        asyncRunloop = nil
        asyncThread = nil
        Update.broadcast()
        Update.unlock()
    }

    #if canImport(ObjectiveC)
    @objc(displayLinkTimer:)
    #endif
    private func displayLinkTimer(_ link: CADisplayLink) {
        Update.lock()
        if currentThread == nextThread, self.link != nil {
            let linkTime = Time(seconds: link.timestamp)
            let linkTargetTime = Time(seconds: link.targetTimestamp)
            if linkTime > nextUpdate - 1.0 / 240.0 {
                currentUpdate = linkTime
                nextUpdate = .infinity
                host?.displayLinkTimer(
                    timestamp: linkTime,
                    targetTimestamp: linkTargetTime,
                    isAsyncThread: currentThread == .async
                )
                currentUpdate = nil
                if nextUpdate == .infinity {
                    if nextThread == .async {
                        nextThread = .main
                        nextUpdate = linkTime
                    }
                }
            }
        }
        if nextThread != currentThread, let oldLink = self.link {
            if nextThread == .async {
                Self.asyncPending = true
                if Self.asyncRunloop == nil {
                    let threadName = "org.OpenSwiftUI.OpenSwiftUI.AsyncRenderer"
                    while true {
                        if Self.asyncThread == nil { // FIXME
                            let thread = Thread(
                                target: DisplayLink.self,
                                selector: #selector(DisplayLink.asyncThread(with:)),
                                object: nil
                            )
                            thread.qualityOfService = .userInteractive
                            thread.name = threadName
                            guard _NSThreadStart(thread) else {
                                nextThread = .main
                                break
                            }
                            Self.asyncThread = thread
                        }
                        Update.wait()
                        guard Self.asyncRunloop == nil else {
                            break
                        }
                    }
                }
            }
            if nextThread != currentThread {
                let runloop: RunLoop
                let isAsync: Bool
                switch nextThread {
                case .main:
                    runloop = RunLoop.main
                    isAsync = false
                case .async:
                    runloop = Self.asyncRunloop!
                    isAsync = true
                }
                oldLink.remove(from: .current, forMode: .common)
                let newLink = CADisplayLink(display: oldLink.display, target: self, selector: #selector(displayLinkTimer(_:)))
                newLink.add(to: runloop, forMode: .common)
                self.link = newLink
                let oldInterval = interval
                let oldReasons = reasons
                interval = .zero
                reasons = []
                setFrameInterval(oldInterval, reasons: oldReasons)
                currentThread = isAsync ? .async : .main
            }
        }
        if self.link != nil {
            if nextUpdate == .infinity, nextThread == currentThread {
                link.isPaused = true
            }
        } else {
            link.invalidate()
        }
        Update.unlock()
    }


    // FIXME
    var willRender: Bool {
        false
    }

    // FIXME
    func cancelAsyncRendering() {
    }
}
#endif
