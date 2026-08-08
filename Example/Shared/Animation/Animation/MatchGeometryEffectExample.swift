//
//  MatchGeometryEffectExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct MatchGeometryEffectExample: View {
    @State private var isVertical = true
    @Namespace private var animation
    
    var body: some View {
        VStack {
            if isVertical {
                VStack {
                    Ellipse()
                        .fill(.red)
                        .matchedGeometryEffect(id: "ellipse", in: animation)
                    Rectangle()
                        .fill(.blue)
                        .matchedGeometryEffect(id: "rectangle", in: animation, properties: .size)
                        .transition(.opacity)
                }
            } else {
                HStack {
                    Ellipse()
                        .fill(.red)
                        .matchedGeometryEffect(id: "ellipse", in: animation)
                    Rectangle()
                        .fill(.blue)
                        .matchedGeometryEffect(id: "rectangle", in: animation, properties: .size)
                        .transition(.opacity)
                }

            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2)) {
                isVertical.toggle()
            }
        }
    }
}
