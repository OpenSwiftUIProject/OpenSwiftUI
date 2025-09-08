//
//  ViewTest.swift
//  OpenSwiftUI
//
//  Status: Complete
//  ID: 1FCA4829BCDAAC91F1E6D1FB696F6642 (SwiftUI)

public import Foundation
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
#if os(iOS) || os(visionOS)
public import UIKit
#endif

// MARK: - _ViewTest [6.4.41]

@available(OpenSwiftUI_v1_0, *)
public protocol _ViewTest: _Test {
    associatedtype RootView: View

    associatedtype RootStateType = Void

    func initRootView() -> Self.RootView

    func initSize() -> CGSize

    func setTestView<V>(_ view: V) where V: View
}

#if os(iOS) || os(visionOS)
private enum Error: Swift.Error {
    case failedToReenableAnimations(String)
    case failedToDismissPresentation(String)
}
#endif

@available(OpenSwiftUI_v1_0, *)
extension _ViewTest {
    public func setUpTest() {
        setEnvironment(EnvironmentValues())
        setSize(initSize())
        setSafeAreaInsets(.zero)
        setRootTestView(initRootView())
        withRenderOptions(.simple) {
            render()
        }
    }

    public func tearDownTest() {
        resetEvents()
        setRootTestView(EmptyView())
        #if os(iOS) || os(visionOS)
        func performRender() {
            withRenderOptions(.simple) {
                render()
            }
        }
        UIView.performWithoutAnimation {
            performRender()
        }
        #endif
    }

    @available(OpenSwiftUI_v4_4, *)
    public func tearDownTestWithError() throws {
        #if os(iOS) || os(visionOS)
        guard !UIView.areAnimationsEnabled else {
            return
        }
        UIView.setAnimationsEnabled(true)
        throw Error.failedToReenableAnimations(String(describing: self))
        #endif
    }

    public func setTestView<V>(_ view: V) where V: View {
        setRootTestView(view)
    }

    public var rootView: Self.RootView {
        withRenderIfNeeded {
            _TestApp.host!.viewForIdentifier(
                rootViewID,
                RootView.self
            )
        }!
    }

    private var rootViewID: Int {
        findState()!.wrappedValue.id
    }

    private func setRootTestView<V>(_ view: V) where V: View {
        let state = findState()!
        let host = _TestApp.host!
        if let viewRendererHost = host as? ViewRendererHost {
            viewRendererHost.currentTimestamp = Time(seconds: ceil(viewRendererHost.currentTimestamp.seconds + 1.0))
        }
        state.wrappedValue.setTestView(view)
    }

    private func findState() -> Binding<_TestApp.RootView.StateType>? {
        withRenderIfNeeded {
            _TestApp.host!.stateForIdentifier(
                _TestApp.rootViewIdentifier,
                type: _TestApp.RootView.StateType.self,
                in: _TestApp.RootView.self
            )
        }
    }

    public func viewForIdentifier<V, I>(
        _ identifier: I,
        _ type: V.Type = V.self
    ) -> V? where V: View, I: Hashable {
        withRenderIfNeeded {
            _TestApp.host!.viewForIdentifier(identifier, type)
        }
    }

    public func stateForIdentifier<I, S, V>(
        _ id: I,
        type stateType: S.Type,
        in viewType: V.Type
    ) -> Binding<S>? where I: Hashable, V: View {
        withRenderIfNeeded {
            _TestApp.host!.stateForIdentifier(id, type: stateType, in: viewType)
        }
    }

    private func withRenderIfNeeded<V>(_ body: () -> V?) -> V? {
        if let value = body() {
            return value
        } else {
            _TestApp.host!.renderForTest(interval: .zero)
            return body()
        }
    }

    public func render(seconds: Double = 1.0 / 60.0) {
        let renderOptions = _TestApp.renderOptions
        let host = renderOptions.contains(.comparison) ? _TestApp.comparisonHost! : _TestApp.host!
        render(
            host: host,
            seconds: seconds,
            options: renderOptions
        )
        let isPostRenderRunLoop = renderOptions.contains(.postRenderRunLoop)
        if isPostRenderRunLoop {
            turnRunLoopIfNeeded(host: host, seconds: seconds, options: renderOptions)
        }
    }

    @available(OpenSwiftUI_v3_0, *)
    public func renderAsync(seconds: Double = 1.0 / 60.0) -> Bool {
        render(host: _TestApp.host!, seconds: seconds, options: [.async])
    }

    @available(OpenSwiftUI_v5_0, *)
    public func renderRecursively(seconds: Double = 1.0 / 60.0) {
        render(host: _TestApp.host!, seconds: seconds, options: [.recursive])
    }

    @discardableResult
    private func render(host: any TestHost, seconds: Double, options: TestRenderOptions) -> Bool {
        let isRecursive = options.contains(.recursive)
        if isRecursive {
            var result = true
            host.forEachDescendantHost { host in
                if options.contains(.async) {
                    if !host._renderAsyncForTest(interval: seconds) {
                        result = false
                    }
                } else {
                    host.renderForTest(interval: seconds)
                }
            }
            return result
        } else {
            if options.contains(.async) {
                return host._renderAsyncForTest(interval: seconds)
            } else {
                host.renderForTest(interval: seconds)
                return true
            }
        }
    }

    public func initSize() -> CGSize {
        CGSize(width: 100, height: 100)
    }

    public func setSize(_ size: CGSize) {
        _TestApp.host!.setTestSize(size)
        _TestApp.comparisonHost?.setTestSize(size)
    }

    func setSafeAreaInsets(_ insets: EdgeInsets) {
        _TestApp.host!.setTestSafeAreaInsets(insets)
    }

    public func setEnvironment(_ environment: EnvironmentValues?) {
        _TestApp.setTestEnvironment(environment)
    }

    #if os(iOS) || os(visionOS)
    public var systemColorScheme: UIUserInterfaceStyle? {
        let view = _TestApp.host! as! UIView
        guard let window = view.window,
              let windowScene = window.windowScene else {
            return nil
        }
        return windowScene._systemUserInterfaceStyle
    }
    #endif

    public func updateEnvironment(_ body: (inout EnvironmentValues) -> Void) {
        _TestApp.updateTestEnvironment(body)
    }

    public func resetEvents() {
        _TestApp.host!.resetTestEvents()
    }

    public func loop() {
        render()
        let defaultMode = RunLoop.Mode.default
        let commonMode = RunLoop.Mode.common
        var count: UInt = 0
        let interval = 0.001
        while true {
            let date = Date(timeIntervalSinceNow: interval)
            if !RunLoop.current.run(mode: count & 1 == 0 ? defaultMode : commonMode, before: date) {
                Thread.sleep(forTimeInterval: interval)
            }
            count += 1
        }
    }

    public func turnRunloop(times: Int = 1) {
        Swift.assert(times > 0)
        let defaultMode = RunLoop.Mode.default
        let commonMode = RunLoop.Mode.common
        let interval = 0.001
        var times = times
        while times != 0 {
            times -= 1
            // let modes = [defaultMode, commonMode]
            let date = Date(timeIntervalSinceNow: interval)
            if !RunLoop.current.run(mode: defaultMode, before: date) {
                Thread.sleep(forTimeInterval: interval)
            }
        }
    }

    private func turnRunLoopIfNeeded(host: any TestHost, seconds: Double, options: TestRenderOptions) {
        guard CoreTesting.neeedsRunLoopTurn else {
            return
        }
        let defaultMode = RunLoop.Mode.default
        let commonMode = RunLoop.Mode.common
        let interval = 0.001
        var times = 17
        while CoreTesting.needsRender || CoreTesting.neeedsRunLoopTurn {
            // let modes = [defaultMode, commonMode]
            let date = Date(timeIntervalSinceNow: interval)
            if !RunLoop.current.run(mode: defaultMode, before: date) {
                Thread.sleep(forTimeInterval: interval)
            }
            render(host: host, seconds: seconds, options: options)
            times &-= 1
            if times <= 1 {
                break
            }
        }
        if CoreTesting.needsRender || CoreTesting.neeedsRunLoopTurn {
            Log.unitTests.log(level: .default, "Render or run loop turn needed after max iterations")
        }
    }
}

extension _ViewTest {
    public func rootState<S>(type: S.Type = S.self) -> Binding<S> {
        withRenderIfNeeded {
            _TestApp.host!.stateForIdentifier(
                rootViewID,
                type: type,
                in: RootView.self
            )
        }!
    }

    public func rootState<S, V>(
        type stateType: S.Type = S.self,
        in viewType: V.Type
    ) -> Binding<S> where V: View {
        withRenderIfNeeded {
            _TestApp.host!.stateForIdentifier(
                rootViewID,
                type: stateType,
                in: viewType
            )
        }!
    }
}

extension _ViewTest {
    public func set<V>(
        _ keyPath: WritableKeyPath<RootStateType, V>,
        to value: V
    ) {
        rootState(type: RootStateType.self).wrappedValue[keyPath: keyPath] = value
    }

    public func get<V>(_ keyPath: KeyPath<RootStateType, V>) -> V {
        rootState(type: RootStateType.self).wrappedValue[keyPath: keyPath]
    }
}
