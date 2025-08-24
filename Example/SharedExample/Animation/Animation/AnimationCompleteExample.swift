//
//  AnimationCompleteExample.swift
//  SharedExample

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct AnimationCompleteExample: View {
    var body: some View {
        VStack {
            LogicalCompletionView()
            RemovedCompletionView()
        }
    }

    struct LogicalCompletionView: View {
        @State private var showRed = false

        var body: some View {
            VStack {
                Color(platformColor: showRed ? .red : .blue)
                    .onAppear {
                        let animation = Animation.linear(duration: 5)
                            .logicallyComplete(after: 1)
                        withAnimation(animation, completionCriteria: .logicallyComplete) {
                            showRed.toggle()
                        } completion: {
                            print("Logically complete")
                        }
                    }
            }
        }
    }

    struct RemovedCompletionView: View {
        @State private var showRed = false

        var body: some View {
            VStack {
                Color(platformColor: showRed ? .red : .blue)
                    .onAppear {
                        let animation = Animation.linear(duration: 5)
                            .logicallyComplete(after: 1)
                        withAnimation(animation, completionCriteria: .removed) {
                            showRed.toggle()
                        } completion: {
                            print("Removed")
                        }
                    }
            }
        }
    }
}
