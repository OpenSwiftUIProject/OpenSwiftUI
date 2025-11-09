//
//  ForEachExample.swift
//  SharedExample

#if OPENSWIFTUI
import OpenObservation
import OpenSwiftUI
#else
import Observation
import SwiftUI
#endif

struct ForEachExample: View {
    var body: some View {
//        HStack {
//            ForEachOffsetExample()
//            ForEachKeyPathExample()
//        }
        ForEachDynamicView()
    }
}

struct ForEachOffsetExample: View {
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0 ..< 6) { index in
                Color.red.opacity(Double(index) / 6.0 )
            }
        }
    }
}

struct ForEachKeyPathExample: View {
    let opacities = [0, 0.2, 0.4, 0.6, 0.8, 1.0]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(opacities, id: \.self) { opacity in
                Color.red.opacity(opacity)
            }
        }
    }
}

struct ForEachDynamicView: View {
    @State private var opacities = [0, 0.5, 1.0]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(opacities, id: \.self) { opacity in
                Color.red.opacity(opacity)
            }
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.spring) {
                    opacities.insert(0.25, at: 1)
                    opacities.insert(0.75, at: 3)
                }
            }
        }
    }
}

struct ForEachNonConstantRangeView: View {
    let range = 0..<5

    var body: some View {
        // Expect to emit warning: "Non-constant range: not an integer range" in compile time using Xcode toolchain
        ForEach(range) { _ in
            EmptyView()
        }
    }
}

@Observable
private class ForEachLazyContainerNonConstantCountViewModel {
    var data: [Int] = [1, 2]
}

// TODO: LazyContainer (eg. List / LazyHVStack)
struct ForEachLazyContainerNonConstantCountView: View {
    private typealias Model = ForEachLazyContainerNonConstantCountViewModel

    @State private var model = Model()

    var body: some View {
//        List {
            ForEach(model.data, id: \.self) { i in
                if i % 2 == 0 {
                    Text(i.description)
                }
            }
//        }
    }
}
