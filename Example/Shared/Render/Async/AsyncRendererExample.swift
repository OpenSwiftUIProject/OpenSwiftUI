//
//  AsyncRendererExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct AsyncRendererExample: View {
    @State private var items = [6]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(items, id: \.self) { item in
                Color.blue.opacity(Double(item) / 6.0)
                    .frame(height: 50)
                    .transition(.slide)
            }
        }
        .animation(.easeInOut(duration: 2), value: items)
        .onAppear {
            items.removeAll { $0 == 6 }
        }
    }
}

struct AsyncRendererTransitionExample: View {
    @State private var isVisible: Bool = false

    var body: some View {
        Group {
            if isVisible {
                Color.red
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 0))
                    .transition(RenderCrashTransition())
            }
        }
        .frame(width: 200, height: 200)
        .animation(.linear(duration: 1), value: isVisible)
        .onAppear {
            guard !isVisible else {
                return
            }
            isVisible = true
        }
    }

    // This custom transition forces the async renderer to update inherited view
    // content while a transition phase is changing. It covers the path that used
    // to trip Swift's exclusivity checks in DisplayList.ViewUpdater.
    private struct RenderCrashTransition: Transition {
        func body(content: Content, phase: TransitionPhase) -> some View {
            content.opacity(phase.isIdentity ? 1 : 0.1)
        }
    }
}
