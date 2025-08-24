//
//  TransactionExample.swift
//  SharedExample

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

// TODO: tracks Velocity
struct TransactionExample: View {
    @State private var flag = false

    var body: some View {
        VStack(spacing: 50) {
            HStack(spacing: 30) {
                // Text("Rotation")
                Color.red.frame(width: 30, height: 60)
                    .rotationEffect(Angle(degrees:
                        self.flag ? 360 : 0))

                // Text("Rotation\nModified")
                Color.green.frame(width: 60, height: 60)
                    .rotationEffect(Angle(degrees:
                        self.flag ? 360 : 0))
                    .transaction { view in
                        view.animation =
                            view.animation?.delay(2.0).speed(2)
                    }
                // Text("Animation\nReplaced")
                Color.blue.frame(width: 60, height: 60)
                    .rotationEffect(Angle(degrees:
                        self.flag ? 360 : 0))
                    .transaction { view in
                        view.animation = .interactiveSpring(
                            response: 0.60,
                            dampingFraction: 0.20,
                            blendDuration: 0.25,
                        )
                    }
            }
            //            Button("Animate") {
            //                withAnimation(.easeIn(duration: 2.0)) {
            //                    self.flag.toggle()
            //                }
            //            }
            .onAppear {
                toggle(first: true)
            }
        }
    }

    func toggle(first: Bool = false) {
        DispatchQueue.main.asyncAfter(deadline: .now() + (first ? 1 : 3)) {
            withAnimation(.easeIn(duration: 2.0)) {
                self.flag.toggle()
                toggle()
            } completion: {
                print("Complete")
            }
        }
    }
}
