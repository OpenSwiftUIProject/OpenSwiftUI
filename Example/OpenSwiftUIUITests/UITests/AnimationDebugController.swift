//
//  AnimationDebugController.swift
//  OpenSwiftUIUITests

import Foundation

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
}

final class AnimationDebugController<V>: UIHostingController<V> where V: View {
    init(_ view: V) {
        super.init(rootView: view)
    }
    
    @MainActor
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func advance(interval: Double) {
        (view as! _UIHostingView<V>)._renderForTest(interval: interval)
    }

    func advanceAsync(interval: Double) -> Bool {
        (view as! _UIHostingView<V>)._renderAsyncForTest(interval: interval)
    }
}
