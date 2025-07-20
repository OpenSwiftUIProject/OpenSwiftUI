//
//  ElasticEaseInEaseOutAnimationExample.swift
//  SharedExample

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif
import Foundation

private struct ElasticEaseInEaseOutAnimation: CustomAnimation {
    let duration: TimeInterval

    func animate<V>(value: V, time: TimeInterval, context: inout AnimationContext<V>) -> V? where V: VectorArithmetic {
        if time > duration { return nil } // The animation has finished.

        let p = time / duration
        let s = sin((20 * p - 11.125) * ((2 * Double.pi) / 4.5))
        if p < 0.5 {
            return value.scaled(by: -(pow(2, 20 * p - 10) * s) / 2)
        } else {
            return value.scaled(by: (pow(2, -20 * p + 10) * s) / 2 + 1)
        }
    }
}

extension Animation {
    static var elasticEaseInEaseOut: Animation { elasticEaseInEaseOut(duration: 0.35) }

    static func elasticEaseInEaseOut(duration: TimeInterval) -> Animation {
        Animation(ElasticEaseInEaseOutAnimation(duration: duration))
    }
}

struct ElasticEaseInEaseOutView: View {
    @State private var isActive = false

    var body: some View {
        VStack(alignment: isActive ? .trailing : .leading) {
            Color.red
                .frame(width: 100.0, height: 100.0)
                .onAppear {
                    withAnimation(.elasticEaseInEaseOut(duration: 5.0)) {
                        isActive.toggle()
                    }
                }
            Color.blue
                .frame(maxWidth: .infinity)
        }
        .padding()
    }
}
