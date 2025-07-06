//
//  BenchmarkApp.swift
//  Example
//
//  Created by Kyle on 2025/6/23.
//
//  Modified from https://gist.github.com/edudnyk/74ed8d3801004a6dcaab09868b522187

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

#if os(iOS)
import UIKit
#endif

struct BenchmarkApp {
    static func main() {
        _TestApp().runBenchmarks([
            RedBenchmark(),
            BlueBenchmark(),
        ])
    }
}
#if os(iOS)
extension UIHostingController: _Test where Content == AnyView {}
extension UIHostingController: _ViewTest where Content == AnyView {
    public func initRootView() -> AnyView {
        return rootView
    }
    public func initSize() -> CGSize {
        sizeThatFits(in: UIScreen.main.bounds.size)
    }
}
#endif

struct PerformanceTest: _PerformanceTest {
    var name: String { "PerformanceTest" }

    let view: AnyView

    init(_ view: some View) {
        self.view = AnyView(view)
    }

    func runTest(host: _BenchmarkHost, options: [AnyHashable : Any]) {
        #if os(iOS)
        let test = _makeUIHostingController(view) as! UIHostingController<AnyView>
        test.setUpTest()
        test.render()
        test._forEachIdentifiedView { proxy in
            let state = test.stateForIdentifier(proxy.identifier, type: Bool.self, in: type(of: test.rootView))
            let view = test.viewForIdentifier(proxy.identifier, AnyView.self)
            print("IDENTIFIER: \(proxy)")
            print("STATE: \(state)")
            print("VIEW: \(view)")
        }
        test.tearDownTest()
        #endif
    }
}

struct RedColor: View {
    var id: String { "RedColor" }

    var body: some View {
        Color.red._identified(by: id)
    }
}

struct BlueColor: View {
    var id: String { "BlueColor" }

    var body: some View {
        Color.blue._identified(by: id)
    }
}

struct RedBenchmark: _Benchmark {
    func measure(host: _BenchmarkHost) -> [Double] {
        return [
            host.measureAction {
                PerformanceTest(RedColor()).runTest(host: host, options: [:])
            },
        ]
    }
}

struct BlueBenchmark: _Benchmark {
    func measure(host: _BenchmarkHost) -> [Double] {
        return [
            host.measureAction {
                PerformanceTest(BlueColor()).runTest(host: host, options: [:])
            },
        ]
    }
}
