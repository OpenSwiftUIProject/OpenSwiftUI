import Foundation
package import OpenSwiftUI

package struct ContentView: View {
    package init() {}

    package var body: some View {
        if ProcessInfo.processInfo.environment["OPENSWIFTUI_DEMO"] == "static" {
            VStack(spacing: 10) {
                Color.red
                Color.blue
            }
            .frame(width: 320, height: 480)
        } else {
            BreathingColorView()
        }
    }
}

package struct BreathingColorView: View {
    package var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSince1970
            let breathe = (sin(time) + 1.0) / 2.0

            VStack(spacing: 40.0) {
                #if !os(Android)
                Text(verbatim: "Breathing Colors")
                    .font(.title)
                    .fontWeight(.bold)
                #endif

                Color.blue.opacity(0.3 + breathe * 0.7)
                    .frame(width: 200.0, height: 200.0)
                    .scaleEffect(0.8 + breathe * 0.4)

                Color.blue
                    .frame(width: 200.0, height: 20.0)
                    .opacity(0.3 + breathe * 0.7)
                    .cornerRadius(10.0)
            }
            .padding()
        }
    }
}
